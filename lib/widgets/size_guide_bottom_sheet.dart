import 'package:flutter/material.dart';

class SizeGuideBottomSheet extends StatelessWidget {
  final bool isShoeProduct;
  const SizeGuideBottomSheet({super.key, required this.isShoeProduct});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isShoeProduct ? 'Bảng Chọn Size Giày Chuẩn' : 'Bảng Chọn Kích Cỡ Áo Quần', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            // Bê nguyên phần Table phức tạp của bạn vào đây...
          ),
        ],
      ),
    );
  }
}