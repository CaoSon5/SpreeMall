import 'package:flutter/material.dart';

import 'config/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const ShopMateApp());
}

class ShopMateApp extends StatelessWidget {
  const ShopMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpereeMall',
      theme: AppTheme.lightTheme,

      // Chạy vào Splash trước
      initialRoute: AppRoutes.splash,

      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}