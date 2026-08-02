import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/cart_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';
import '../product/product_detail_screen.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class CartTab extends StatelessWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        final items = cart.items;

        if (items.isEmpty) {
          return const EmptyStateView(
            icon: Icons.shopping_cart_outlined,
            title: 'Giỏ hàng của bạn đang trống',
            message: 'Hãy quay lại Trang chủ và thêm sản phẩm vào giỏ hàng.',
          );
        }

        return Column(
          children: [

            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    value: cart.isAllSelected,
                    activeColor: AppColors.primary,
                    onChanged: (value) => cart.toggleSelectAll(value ?? false),
                  ),
                  const Text('Chọn tất cả'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: cart.clear,
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    label: const Text(
                      'Xoá tất cả',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final product = item.product;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: item.selected,
                          activeColor: AppColors.primary,
                          onChanged: (_) => cart.toggleSelected(product.id, size: item.size),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
                            ),
                          ),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: product.iconBgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(product.icon, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.heading3,
                              ),
                              if (item.size != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Size: ${item.size}',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                formatVnd(product.price),
                                style: AppTextStyles.price,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => cart.decreaseQuantity(product.id, size: item.size),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.remove, size: 14),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 22,
                                          child: Text(
                                            '${item.quantity}',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.bodyRegular,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => cart.increaseQuantity(product.id, size: item.size),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.add, size: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => cart.removeItem(product.id, size: item.size),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng cộng (${cart.selectedCount} sp)', style: AppTextStyles.bodySecondary),
                        Text(
                          formatVnd(cart.selectedTotalPrice),
                          style: AppTextStyles.price.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: cart.selectedCount == 0
                        ? null
                        : () {

                            _navigateToCheckout(cart);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Đặt hàng'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCheckout(CartController cart) {

    Get.toNamed(
      AppRoutes.checkout,
      arguments: {
        'totalPrice': cart.selectedTotalPrice,
        'selectedCount': cart.selectedCount,
      },
    );

  }
}