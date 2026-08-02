import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../config/theme/app_text_styles.dart';
import '../models/product.dart';
import '../screens/home/product_grid_section.dart';

class RecommendedProductsSection extends StatelessWidget {
  final int limit;
  final EdgeInsetsGeometry padding;

  const RecommendedProductsSection({
    super.key,
    this.limit = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 15),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox.shrink();

        final shuffled = List.of(docs)..shuffle(Random());
        final products = shuffled.take(limit).map((d) => Product.fromMap(d.id, d.data())).toList();

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✨ Có thể bạn sẽ thích', style: AppTextStyles.heading3.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              GridView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) => ProductCard(product: products[index]),
              ),
            ],
          ),
        );
      },
    );
  }
}
