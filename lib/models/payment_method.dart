import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';

enum PaymentMethod {
  cod,
  bankTransfer,
  momo,
  zalopay,
  card,
}

extension PaymentMethodX on PaymentMethod {
  String get value => name;

  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'Thanh toán khi nhận hàng (COD)';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản ngân hàng';
      case PaymentMethod.momo:
        return 'Ví MoMo';
      case PaymentMethod.zalopay:
        return 'ZaloPay';
      case PaymentMethod.card:
        return 'Thẻ tín dụng / Ghi nợ';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethod.cod:
        return 'Thanh toán bằng tiền mặt khi nhận hàng';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản qua tài khoản ngân hàng';
      case PaymentMethod.momo:
        return 'Liên kết và thanh toán qua ví MoMo';
      case PaymentMethod.zalopay:
        return 'Liên kết và thanh toán qua ví ZaloPay';
      case PaymentMethod.card:
        return 'Visa, Mastercard, JCB...';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cod:
        return Icons.local_shipping_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.momo:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethod.zalopay:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethod.card:
        return Icons.credit_card_outlined;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.cod:
        return AppColors.success;
      case PaymentMethod.bankTransfer:
        return const Color(0xFF2196F3);
      case PaymentMethod.momo:
        return const Color(0xFFD82D8B);
      case PaymentMethod.zalopay:
        return const Color(0xFF0068FF);
      case PaymentMethod.card:
        return AppColors.primary;
    }
  }
}

PaymentMethod paymentMethodFromString(String? raw) {
  return PaymentMethod.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => PaymentMethod.cod,
  );
}
