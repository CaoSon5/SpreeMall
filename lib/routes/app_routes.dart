import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_product_management_screen.dart';
import '../screens/admin/admin_order_management_screen.dart';
import '../screens/admin/admin_user_management_screen.dart';
import '../middleware/admin_middleware.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = "/";
  static const String login = "/login";
  static const String register = "/register";
  static const String forgotPassword = "/forgot-password";
  static const String home = "/home";
  static const String checkout = "/checkout";

  static const String adminDashboard = "/admin";
  static const String adminProducts = "/admin/products";
  static const String adminOrders = "/admin/orders";
  static const String adminUsers = "/admin/users";

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
      page: () => const CheckoutScreen(),
    ),

    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: adminProducts,
      page: () => const AdminProductManagementScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: adminOrders,
      page: () => const AdminOrderManagementScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: adminUsers,
      page: () => const AdminUserManagementScreen(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}