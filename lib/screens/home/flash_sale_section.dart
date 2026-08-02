import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/product.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_section_title.dart';
import '../product/product_detail_screen.dart';

class FlashSaleSection extends StatelessWidget {
  const FlashSaleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSectionTitle(
            title: "⚡ Flash Sale",
            onSeeAll: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang cập nhật trang Flash Sale...'),
                ),
              );
            },
          ),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('isFlashSale', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              final items = docs.map((d) => Product.fromMap(d.id, d.data())).toList();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 190,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (items.isEmpty) {
                return const SizedBox(
                  height: 60,
                  child: Center(child: Text('Chưa có sản phẩm Flash Sale nào')),
                );
              }

              return SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: item),
                          ),
                        );
                      },
                      child: Container(
                        width: 130,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 90,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: item.iconBgColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: item.image.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: item.image.startsWith('http')
                                                ? Image.network(
                                                    item.image,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (_, __, ___) => Icon(item.icon, size: 36, color: AppColors.primary),
                                                  )
                                                : Image.asset(
                                                    item.image,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (_, __, ___) => Icon(item.icon, size: 36, color: AppColors.primary),
                                                  ),
                                          )
                                        : Icon(
                                            item.icon,
                                            size: 36,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "-${item.discountPercent}%",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyRegular.copyWith(fontSize: 12.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatVnd(item.price),
                              style: AppTextStyles.price.copyWith(fontSize: 14),
                            ),
                            Text(
                              formatVnd(item.oldPrice ?? item.price),
                              style: AppTextStyles.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
