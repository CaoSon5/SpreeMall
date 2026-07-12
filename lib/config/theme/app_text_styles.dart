import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Các kiểu chữ dùng chung cho toàn bộ app.
/// Dùng font "Be Vietnam Pro" từ Google Fonts vì hỗ trợ tiếng Việt tốt
/// và có nhiều độ đậm (weight), phù hợp phong cách app thương mại điện tử.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.beVietnamPro();

  // Tiêu đề lớn (VD: tên sản phẩm trong trang chi tiết)
  static TextStyle heading1 = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Tiêu đề vừa (VD: tên section trong Home: "Flash Sale", "Danh mục")
  static TextStyle heading2 = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Tiêu đề nhỏ (VD: tên card sản phẩm)
  static TextStyle heading3 = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Nội dung thường
  static TextStyle bodyRegular = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Nội dung phụ, mờ hơn (VD: mô tả ngắn, ngày giờ)
  static TextStyle bodySecondary = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Chữ nhỏ (caption, label phụ)
  static TextStyle caption = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // Giá tiền (nhấn mạnh, màu primary)
  static TextStyle price = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  // Chữ trên nút bấm
  static TextStyle button = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}
