import 'dart:convert'; // Bắt buộc phải có để dùng json.decode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Bắt buộc phải có để dùng rootBundle quét thư mục assets
import 'package:firebase_core/firebase_core.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm thư viện kết nối Firestore
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

  runApp(const ShopMateApp());
}

// ====================================================================
// HÀM TỰ ĐỘNG QUÉT THƯ MỤC VÀ ĐỒNG BỘ LÊN FIREBASE 100% TỰ ĐỘNG
// ====================================================================
Future<void> autoUploadDataToFirebase() async {
  print("🔄 [Firebase Auto-Sync] Đang kích hoạt phương thức đồng bộ an toàn...");

  try {
    // Khai báo trực tiếp danh sách các file banner bạn đang có trong thư mục
    List<String> allBanners = [
      'assets/images/banners/banner1.png',
      'assets/images/banners/banner2.png',
      'assets/images/banners/banner3.png',
      'assets/images/banners/banner4.png',
    ];

    print("📊 Danh sách chuẩn bị đồng bộ: ${allBanners.length} banners.");

    // Kết nối tới bảng 'banners' trên Firebase
    final CollectionReference bannersRef = FirebaseFirestore.instance.collection('banners');
    
    // Lấy dữ liệu hiện tại trên Firebase về để kiểm tra trùng lặp
    final existingBannersSnapshot = await bannersRef.get();
    final List<String> firebaseBannerUrls = existingBannersSnapshot.docs
        .map((doc) => doc['url'] as String)
        .toList();

    // Tiến hành nạp dữ liệu lên Firebase nếu chưa tồn tại
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpreeMall', // Đã sửa lại chính tả SpreeMall cho chuẩn chỉnh
      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}