import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/checkout/checkout_screen.dart'; // File checkout bạn đã import sẵn

class AppRoutes {
  AppRoutes._();

  // ===============================
  // Tên Route (Đường dẫn trang)
  // ===============================
  static const String splash = "/";
  static const String login = "/login";
  static const String register = "/register";
  static const String forgotPassword = "/forgot-password";
  static const String home = "/home";
  static const String checkout = "/checkout"; // 🆕 Định nghĩa đường dẫn cho trang thanh toán

  // ===============================
  // Danh sách trang quản lý bằng GetX
  // ===============================
  static final List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: checkout,
      page: () => const CheckoutScreen(), // 🆕 Khai báo trang thanh toán vào hệ thống GetX
    ),
  ];
}