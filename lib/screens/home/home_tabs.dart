import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../utils/formatters.dart';
import '../product/product_detail_screen.dart';
import 'product_grid_section.dart';

/// Khung chung cho trạng thái rỗng (icon lớn + tiêu đề + mô tả)
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

/// ===============================
/// TAB YÊU THÍCH
/// ===============================
class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FavoritesController.instance,
      builder: (context, _) {
        final items = FavoritesController.instance.items;

        if (items.isEmpty) {
          return const EmptyStateView(
            icon: Icons.favorite_border,
            title: 'Chưa có sản phẩm yêu thích',
            message:
                'Nhấn biểu tượng trái tim trên sản phẩm để lưu vào đây.',
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${items.length} sản phẩm yêu thích',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(product: items[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ===============================
/// TAB GIỎ HÀNG
/// ===============================
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
            // Hàng chọn tất cả
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

            // Danh sách sản phẩm trong giỏ
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
                          onChanged: (_) => cart.toggleSelected(product.id),
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
                                          onTap: () => cart.decreaseQuantity(product.id),
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
                                          onTap: () => cart.increaseQuantity(product.id),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.add, size: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => cart.removeItem(product.id),
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

            // Thanh tổng tiền + đặt hàng
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
                        : () => _showCheckoutDialog(context, cart),
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

  void _showCheckoutDialog(BuildContext context, CartController cart) {
    final total = cart.selectedTotalPrice;
    final count = cart.selectedCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Đặt hàng thành công'),
          ],
        ),
        content: Text(
          'Đã đặt $count sản phẩm với tổng tiền ${formatVnd(total)}. '
          'Đây là mô phỏng giao diện, chưa kết nối hệ thống thanh toán thật.',
          style: AppTextStyles.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.checkoutSelected();
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
