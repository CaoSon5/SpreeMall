import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../models/product.dart';
import '../../utils/formatters.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  Product get product => widget.product;

  void _increase() {
    setState(() {
      if (_quantity < product.stock) _quantity++;
    });
  }

  void _decrease() {
    setState(() {
      if (_quantity > 1) _quantity--;
    });
  }

  void _addToCart({bool showMessage = true}) {
    CartController.instance.addProduct(product, quantity: _quantity);
    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1200),
          content: Text('Đã thêm $_quantity "${product.name}" vào giỏ hàng'),
        ),
      );
    }
  }

  void _buyNow() {
    _addToCart(showMessage: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Đặt hàng thành công'),
          ],
        ),
        content: Text(
          'Bạn đã đặt mua $_quantity "${product.name}". '
          'Đơn hàng sẽ sớm được xử lý (đây là mô phỏng, chưa kết nối hệ thống thanh toán thật).',
          style: AppTextStyles.bodyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // đóng dialog
              Navigator.of(context).pop(); // quay lại màn trước
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product.category,
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        actions: [
          AnimatedBuilder(
            animation: FavoritesController.instance,
            builder: (context, _) {
              final isFav = FavoritesController.instance.isFavorite(product.id);
              return IconButton(
                onPressed: () => FavoritesController.instance.toggle(product),
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép liên kết sản phẩm')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Container(
              height: 260,
              width: double.infinity,
              color: product.iconBgColor,
              child: Stack(
                children: [
                  Center(
                    child: product.image.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Image.asset(
                              product.image,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(product.icon, size: 120, color: AppColors.primary),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Giảm ${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên + giá
                  Text(product.name, style: AppTextStyles.heading1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(formatVnd(product.price), style: AppTextStyles.price.copyWith(fontSize: 22)),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          formatVnd(product.oldPrice!),
                          style: AppTextStyles.bodySecondary.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Rating + đã bán
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 18),
                      const SizedBox(width: 4),
                      Text('${product.rating}', style: AppTextStyles.bodyRegular),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 14, color: AppColors.divider),
                      const SizedBox(width: 12),
                      Text(
                        'Đã bán ${product.soldCount}',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 14, color: AppColors.divider),
                      const SizedBox(width: 12),
                      Text(
                        'Kho: ${product.stock}',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Chọn số lượng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Số lượng', style: AppTextStyles.heading3),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _decrease,
                              icon: const Icon(Icons.remove, size: 18),
                            ),
                            SizedBox(
                              width: 28,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyRegular,
                              ),
                            ),
                            IconButton(
                              onPressed: _increase,
                              icon: const Icon(Icons.add, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Chính sách
                  const _PolicyRow(
                    icon: Icons.local_shipping_outlined,
                    text: 'Miễn phí vận chuyển cho đơn hàng từ 200.000đ',
                  ),
                  const SizedBox(height: 10),
                  const _PolicyRow(
                    icon: Icons.verified_user_outlined,
                    text: 'Bảo hành chính hãng 12 tháng',
                  ),
                  const SizedBox(height: 10),
                  const _PolicyRow(
                    icon: Icons.replay_outlined,
                    text: 'Đổi trả miễn phí trong 7 ngày',
                  ),

                  const Divider(height: 32),

                  // Mô tả
                  Text('Mô tả sản phẩm', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Đang cập nhật mô tả cho sản phẩm này.',
                    style: AppTextStyles.bodyRegular.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                child: OutlinedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Thêm vào giỏ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _buyNow,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Mua ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PolicyRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: AppTextStyles.bodyRegular),
        ),
      ],
    );
  }
}
