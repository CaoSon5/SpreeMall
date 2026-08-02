import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

enum OrderStatus {
  pending,
  confirmed,
  shipping,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {

  String get value => name;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã huỷ';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3);
      case OrderStatus.shipping:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.fact_check_outlined;
      case OrderStatus.shipping:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  bool get canBeCancelledByCustomer => this == OrderStatus.pending;
}

OrderStatus orderStatusFromString(String? raw) {
  return OrderStatus.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => OrderStatus.pending,
  );
}
