import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spreemall/controllers/checkout_controller.dart';
import 'package:spreemall/controllers/cart_controller.dart';
import 'package:spreemall/controllers/role_controller.dart';
import 'package:spreemall/controllers/address_controller.dart';
import 'package:spreemall/controllers/store_controller.dart';
import 'package:spreemall/controllers/profile_controller.dart';
import 'package:spreemall/data/mock_products.dart';
import 'firebase_options.dart';

import 'config/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox<String>(cartHiveBoxName);

  await autoUploadDataToFirebase();

  await autoSeedProductsToFirebase();

  Get.put(CheckoutController());
  Get.put(CartController());
  Get.put(RoleController());
  Get.put(AddressController());
  Get.put(StoreController());

  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user == null) {

      RoleController.instance.reset();
      CartController.instance.clearLocalOnly();
      UserProfileController.instance.clearProfile();
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = userDoc.data();

      await RoleController.instance.fetchRole(user.uid);

      await CartController.instance.loadCart(user.uid);

      if (data != null) {
        UserProfileController.instance.update(
          name: (data['name'] ?? '') as String,
          email: (data['email'] ?? user.email ?? '') as String,
          phone: (data['phone'] ?? '') as String,
          gender: (data['gender'] ?? '') as String,
          birthday: (data['birthday'] ?? '') as String,
        );
      }
    } catch (e) {

      print('Lỗi khi đồng bộ dữ liệu tài khoản sau authStateChanges: $e');
    }
  });

  runApp(const ShopMateApp());
}

Future<void> autoSeedProductsToFirebase() async {
  try {
    final seedFlagRef = FirebaseFirestore.instance.collection('_meta').doc('seed_products');
    final seedFlagDoc = await seedFlagRef.get();

    if (seedFlagDoc.exists) {
      print("✅ [Auto-Seed Products] Đã seed từ trước rồi, bỏ qua (Admin có toàn quyền sửa/xoá 3 sản phẩm demo).");
      return;
    }

    print("🔄 [Auto-Seed Products] Lần đầu mở app - seed ${MockProducts.all.length} sản phẩm demo...");

    final productsRef = FirebaseFirestore.instance.collection('products');
    for (int i = 0; i < MockProducts.all.length; i++) {
      final product = MockProducts.all[i];
      final data = product.toMap();
      data['isFlashSale'] = i < 2;
      await productsRef.doc(product.id).set(data);
    }

    await seedFlagRef.set({'seeded': true, 'seededAt': FieldValue.serverTimestamp()});

    print("🎉 [Auto-Seed Products] Seed lần đầu hoàn tất! Các lần mở app sau sẽ không seed lại nữa.");
  } catch (e) {
    print("❌ [Auto-Seed Products] Gặp lỗi: $e");
  }
}

Future<void> autoUploadDataToFirebase() async {
  print("🔄 [Firebase Auto-Sync] Đang kích hoạt phương thức đồng bộ an toàn...");

  try {
    List<String> allBanners = [
      'assets/images/banners/banner1.png',
      'assets/images/banners/banner2.png',
      'assets/images/banners/banner3.png',
      'assets/images/banners/banner4.png',
    ];

    print("📊 Danh sách chuẩn bị đồng bộ: ${allBanners.length} banners.");

    final CollectionReference bannersRef = FirebaseFirestore.instance.collection('banners');

    final existingBannersSnapshot = await bannersRef.get();
    final List<String> firebaseBannerUrls = existingBannersSnapshot.docs
        .map((doc) => doc['url'] as String)
        .toList();

    for (String path in allBanners) {
      if (!firebaseBannerUrls.contains(path)) {
        await bannersRef.add({
          'url': path,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("🆕 [Auto-Banner] Đã đồng bộ thành công lên Firebase: $path");
      } else {
        print("✅ [Auto-Banner] Đường dẫn đã tồn tại trên Firebase, bỏ qua: $path");
      }
    }

    print("🎉 [Firebase Auto-Sync] Tất cả dữ liệu Banner đã được đồng bộ hoàn tất!");
  } catch (e) {
    print("❌ [Firebase Auto-Sync] Gặp lỗi: $e");
  }
}

class ShopMateApp extends StatelessWidget {
  const ShopMateApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpreeMall',
      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}