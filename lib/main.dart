import 'dart:convert'; // Bắt buộc phải có để dùng json.decode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Bắt buộc phải có để dùng rootBundle quét thư mục assets
import 'package:firebase_core/firebase_core.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm thư viện kết nối Firestore
import 'package:get/get.dart'; // 🆕 THÊM IMPORT GETX
import 'package:spreemall/controllers/checkout_controller.dart';
import 'package:spreemall/controllers/cart_controller.dart'; // 🆕 IMPORT THÊM CART CONTROLLER
import 'firebase_options.dart';         

import 'config/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // KÍCH HOẠT: Tự động quét và đồng bộ ảnh từ assets lên Firebase khi mở app
  await autoUploadDataToFirebase();
  
  // ====================================================================
  // NẠP CONTROLLER VÀO HỆ THỐNG GETX
  // ====================================================================
  Get.put(CheckoutController());
  Get.put(CartController()); // 🆕 THÊM DÒNG NÀY ĐỂ HẾT LỖI ĐỎ KHI BẤM ĐẶT HÀNG

  runApp(const ShopMateApp());
}

// ====================================================================
// HÀM TỰ ĐỘNG QUÉT THƯ MỤC VÀ ĐỒNG BỘ LÊN FIREBASE 100% TỰ ĐỘNG
// ====================================================================
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
    // 🆕 ĐỔI THÀNH GetMaterialApp và thay cấu hình route
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpreeMall',
      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes, 
    );
  }
}