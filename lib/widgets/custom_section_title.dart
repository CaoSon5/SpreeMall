import 'package:flutter/material.dart';

import '../config/theme/app_text_styles.dart';

class CustomSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const CustomSectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.heading2,
          ),

          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text("Xem tất cả"),
            ),
        ],
      ),
    );
  }
}