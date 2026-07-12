import 'package:flutter/material.dart';

/// Bảng màu chính của ứng dụng.
/// Toàn bộ màu sắc trong app PHẢI lấy từ đây, không hard-code màu trực tiếp
/// trong widget để dễ đổi theme sau này.
class AppColors {
  AppColors._(); // Không cho phép khởi tạo instance

  // Màu thương hiệu (cảm hứng từ Shopee: cam - đỏ)
  static const Color primary = Color(0xFFEE4D2D);
  static const Color primaryDark = Color(0xFFD73211);
  static const Color primaryLight = Color(0xFFFF6B4A);

  // Màu phụ trợ
  static const Color secondary = Color(0xFFF53D2D);
  static const Color accent = Color(0xFFFFC107);

  // Nền
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Chữ
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Trạng thái
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);

  // Đường viền / phân cách
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFEEEEEE);
}
