import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/role_controller.dart';
import '../routes/app_routes.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final isAdmin = RoleController.instance.isAdmin;

    if (!isAdmin) {
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}
