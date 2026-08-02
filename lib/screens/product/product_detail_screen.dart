import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/product.dart';
import '../../models/order_status.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';
import '../home/brand_products_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String? _selectedSize;
  late List<String> _sizes;
  int _currentImageIndex = 0;
  late final PageController _imagePageController;
  bool _checkingReviewEligibility = true;
  bool _canReview = false;

  Product get product => widget.product;

  bool get _hasSizes => _sizes.isNotEmpty;

  bool get _isShoeProduct {
    if (_sizes.isEmpty) return false;
    return num.tryParse(_sizes.first) != null;
  }

  @override
  void initState() {
    super.initState();

    _sizes = product.sizes;
    _selectedSize = _sizes.isNotEmpty ? _sizes.first : null;
    _imagePageController = PageController();
    _checkReviewEligibility();
  }

  Future<void> _checkReviewEligibility() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _checkingReviewEligibility = false);
      return;
    }

    try {
      final ordersSnap = await FirebaseFirestore.instance
          .collection('orders')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: OrderStatus.delivered.value)
          .get();

      bool purchased = false;
      for (final doc in ordersSnap.docs) {
        final items = (doc.data()['items'] as List<dynamic>? ?? []);
        for (final raw in items) {
          final item = raw as Map<String, dynamic>;
          if (item['productId'] == product.id) {
            purchased = true;
            break;
          }
        }
        if (purchased) break;
      }

      if (mounted) {
        setState(() {
          _canReview = purchased;
          _checkingReviewEligibility = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _checkingReviewEligibility = false);
    }
  }

  void _openReviewDialog() {
    int rating = 5;
    final commentCtrl = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Đánh giá sản phẩm'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn số sao:'),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        onPressed: () => setDialogState(() => rating = starValue),
                        icon: Icon(
                          starValue <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Chia sẻ cảm nhận của bạn về sản phẩm...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          final ok = await _submitReview(rating, commentCtrl.text.trim());
                          if (context.mounted) Navigator.pop(context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(ok ? '✅ Cảm ơn bạn đã đánh giá!' : '❌ Có lỗi, vui lòng thử lại')),
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _submitReview(int rating, String comment) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final name = UserProfileController.instance.name;
      await FirebaseFirestore.instance.collection('reviews').doc('${uid}_${product.id}').set({
        'productId': product.id,
        'uid': uid,
        'userName': name.isNotEmpty ? name : 'Người dùng ẩn danh',
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final allReviews = await FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: product.id)
          .get();

      if (allReviews.docs.isNotEmpty) {
        final total = allReviews.docs.fold<int>(0, (sum, d) => sum + ((d.data()['rating'] ?? 0) as int));
        final average = total / allReviews.docs.length;

        await FirebaseFirestore.instance.collection('products').doc(product.id).update({
          'rating': double.parse(average.toStringAsFixed(1)),
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

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
    CartController.instance.addProduct(product, quantity: _quantity, size: _selectedSize);
    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.success,
          duration: const Duration(milliseconds: 1500),
          content: Text(
            _selectedSize != null
                ? '🎉 Đã thêm $_quantity x "${product.name}" (Size $_selectedSize) vào giỏ hàng'
                : '🎉 Đã thêm $_quantity x "${product.name}" vào giỏ hàng',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  void _buyNow() {

    CheckoutController.instance.startQuickBuy(product, quantity: _quantity, size: _selectedSize);
    Get.toNamed(AppRoutes.checkout);
  }

  void _showSizeGuide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isShoeProduct ? 'Bảng Chọn Size Giày Chuẩn' : 'Bảng Hướng Dẫn Chọn Kích Cỡ Áo Quần',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!, width: 1, borderRadius: BorderRadius.circular(8)),
              children: _isShoeProduct
                ? [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      children: const [
                        Padding(padding: EdgeInsets.all(10), child: Text('Size EU', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(10), child: Text('Chiều dài chân (cm)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(10), child: Text('Size US', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('38', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('23.5 - 24.0', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('6.0', textAlign: TextAlign.center)),
                    ]),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('39', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('24.0 - 24.5', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('6.5', textAlign: TextAlign.center)),
                    ]),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('40', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('24.5 - 25.0', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('7.5', textAlign: TextAlign.center)),
                    ]),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('41', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('25.0 - 25.5', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('8.5', textAlign: TextAlign.center)),
                    ]),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('42', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('25.5 - 26.0', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('9.0', textAlign: TextAlign.center)),
                    ]),
                  ]
                : [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      children: const [
                        Padding(padding: EdgeInsets.all(10), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(10), child: Text('Chiều cao (cm)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Padding(padding: EdgeInsets.all(10), child: Text('Cân nặng (kg)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('S', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('150 - 160', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('40 - 50', textAlign: TextAlign.center)),
                    ]),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('M', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('160 - 167', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('50 - 60', textAlign: TextAlign.center)),
                    ]),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('L', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('167 - 172', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('60 - 70', textAlign: TextAlign.center)),
                    ]),
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.all(10), child: Text('XL', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('172 - 185', textAlign: TextAlign.center)),
                      Padding(padding: EdgeInsets.all(10), child: Text('70 - 85', textAlign: TextAlign.center)),
                    ]),
                  ],
            ),
            const SizedBox(height: 16),
            Text(
              '* Lưu ý: Bảng kích cỡ chỉ mang tính chất tham khảo tương đối. Hãy chat trực tiếp với cửa hàng để được tư vấn chính xác nhất.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                              child: Hero(
                                tag: 'product_${product.id}',
                                child: product.allImages.isEmpty
                                    ? Icon(product.icon, size: 140, color: AppColors.primary)
                                    : PageView.builder(
                                        controller: _imagePageController,
                                        itemCount: product.allImages.length,
                                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                                        itemBuilder: (context, index) {
                                          final imgUrl = product.allImages[index];
                                          final isNetwork = imgUrl.startsWith('http://') || imgUrl.startsWith('https://');
                                          return isNetwork
                                              ? Image.network(
                                                  imgUrl,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) => Icon(product.icon, size: 140, color: AppColors.primary),
                                                )
                                              : Image.asset(
                                                  imgUrl,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) => Icon(product.icon, size: 140, color: AppColors.primary),
                                                );
                                        },
                                      ),
                              ),
                            ),

                            if (product.allImages.length > 1) ...[
                              Positioned(
                                left: 4,
                                child: _ImageNavButton(
                                  icon: Icons.chevron_left_rounded,
                                  visible: _currentImageIndex > 0,
                                  onTap: () => _imagePageController.previousPage(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                child: _ImageNavButton(
                                  icon: Icons.chevron_right_rounded,
                                  visible: _currentImageIndex < product.allImages.length - 1,
                                  onTap: () => _imagePageController.nextPage(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                            ],
                            if (product.hasDiscount)
                              Positioned(
                                top: 8,
                                left: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    'Giảm ${product.discountPercent}%',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      if (product.allImages.length > 1) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: product.allImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final imgUrl = product.allImages[index];
                              final isNetwork = imgUrl.startsWith('http://') || imgUrl.startsWith('https://');
                              final isActive = index == _currentImageIndex;

                              return GestureDetector(
                                onTap: () => _imagePageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isActive ? AppColors.primary : Colors.grey[300]!,
                                      width: isActive ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: isNetwork
                                        ? Image.network(
                                            imgUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(product.icon, size: 20, color: AppColors.primary),
                                          )
                                        : Image.asset(
                                            imgUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(product.icon, size: 20, color: AppColors.primary),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -15),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          product.category.toUpperCase(),
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          product.name,
                          style: AppTextStyles.heading1.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('products').doc(product.id).snapshots(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data();
                            final liveRating = data != null ? (data['rating'] ?? product.rating) : product.rating;
                            final liveSold = data != null ? (data['soldCount'] ?? product.soldCount) : product.soldCount;
                            final liveStock = data != null ? (data['stock'] ?? product.stock) : product.stock;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formatVnd(product.price),
                                          style: AppTextStyles.price.copyWith(fontSize: 26, color: AppColors.primary, fontWeight: FontWeight.bold),
                                        ),
                                        if (product.hasDiscount) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            formatVnd(product.oldPrice!),
                                            style: AppTextStyles.bodySecondary.copyWith(
                                              decoration: TextDecoration.lineThrough,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xfffff9db),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            (liveRating as num).toStringAsFixed(1),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffe67e22)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text('🔥 Đã bán $liveSold', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                    const SizedBox(width: 16),
                                    Container(width: 1.5, height: 14, color: Colors.grey[300]),
                                    const SizedBox(width: 16),
                                    Text('📦 Kho còn: $liveStock', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red[50]?.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red[100]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    children: [
                                      TextSpan(text: 'SpreeMall Đảm Bảo: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                                      const TextSpan(text: 'Nhận hàng đúng hẹn hoặc nhận Thẻ voucher 20.000đ.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xfff1f3f5), thickness: 1.5),
                        ),

                        if (_hasSizes) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Chọn kích cỡ', style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                              TextButton.icon(
                                onPressed: _showSizeGuide,
                                icon: const Icon(Icons.straighten_rounded, size: 16, color: Colors.blue),
                                label: const Text('Hướng dẫn chọn size', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 42,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _sizes.length,
                              itemBuilder: (context, index) {
                                final size = _sizes[index];
                                final isSelected = _selectedSize == size;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedSize = size),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : const Color(0xfff1f3f5),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: Color(0xfff1f3f5), thickness: 1.5),
                          ),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Chọn số lượng', style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xfff1f3f5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: _decrease,
                                    icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.black54),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    onPressed: _increase,
                                    icon: const Icon(Icons.add_circle_outline, size: 22, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xfff1f3f5), thickness: 1.5),
                        ),

                        _buildPolicyCard(
                          icon: Icons.local_shipping_rounded,
                          title: 'Miễn phí vận chuyển',
                          subtitle: 'Cho mọi đơn hàng từ 200.000đ trên toàn quốc.',
                        ),
                        const SizedBox(height: 12),
                        _buildPolicyCard(
                          icon: Icons.verified_user_rounded,
                          title: 'Bảo hành chính hãng',
                          subtitle: 'Cam kết bảo hành 12 tháng tại các store.',
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xfff1f3f5), thickness: 1.5),
                        ),

                        Text('Thông số sản phẩm', style: AppTextStyles.heading3.copyWith(fontSize: 17)),
                        const SizedBox(height: 10),
                        if (product.brand.isNotEmpty) _buildSpecificationRow('Thương hiệu', product.brand),
                        _buildSpecificationRow('Danh mục', product.category),
                        ...product.specs.entries.map((e) => _buildSpecificationRow(e.key, e.value)),
                        if (product.brand.isEmpty && product.specs.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Đang cập nhật thêm thông số cho sản phẩm này.',
                              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xfff1f3f5), thickness: 1.5),
                        ),

                        Text('Mô tả sản phẩm', style: AppTextStyles.heading3.copyWith(fontSize: 17)),
                        const SizedBox(height: 10),
                        Text(
                          product.description.isNotEmpty ? product.description : 'Đang cập nhật mô tả chi tiết cho dòng sản phẩm thời trang cao cấp này.',
                          style: TextStyle(height: 1.6, color: Colors.grey[700], fontSize: 14.5),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xfff1f3f5), thickness: 1.5),
                        ),

                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('reviews')
                              .where('productId', isEqualTo: product.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final docs = (snapshot.data?.docs ?? []).toList()
                              ..sort((a, b) {
                                final aTime = a.data()['createdAt'];
                                final bTime = b.data()['createdAt'];
                                if (aTime is Timestamp && bTime is Timestamp) return bTime.compareTo(aTime);
                                return 0;
                              });

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Đánh giá sản phẩm', style: AppTextStyles.heading3.copyWith(fontSize: 17)),
                                    Text('${docs.length} đánh giá', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                if (_checkingReviewEligibility)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                  )
                                else if (_canReview)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: OutlinedButton.icon(
                                      onPressed: _openReviewDialog,
                                      icon: const Icon(Icons.rate_review_outlined, size: 18),
                                      label: const Text('Viết đánh giá của bạn'),
                                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      '🔒 Mua và nhận hàng sản phẩm này để có thể đánh giá.',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12.5, fontStyle: FontStyle.italic),
                                    ),
                                  ),

                                if (docs.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text('Chưa có đánh giá nào cho sản phẩm này.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  )
                                else
                                  ...docs.map((doc) {
                                    final data = doc.data();
                                    final createdAt = data['createdAt'];
                                    final dateLabel = createdAt is Timestamp
                                        ? '${createdAt.toDate().day.toString().padLeft(2, '0')}-${createdAt.toDate().month.toString().padLeft(2, '0')}-${createdAt.toDate().year}'
                                        : 'Vừa xong';

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildReviewItem(
                                        username: (data['userName'] ?? 'Người dùng ẩn danh') as String,
                                        rating: (data['rating'] ?? 5) as int,
                                        date: dateLabel,
                                        comment: (data['comment'] ?? '') as String,
                                      ),
                                    );
                                  }),
                              ],
                            );
                          },
                        ),

                        if (product.brand.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _ShopVisitCard(product: product),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 6, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black87,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🔗 Đã sao chép liên kết sản phẩm')),
                              );
                            },
                            icon: const Icon(Icons.share_rounded, color: Colors.black87, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 12,
          top: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: _addToCart,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Icon(Icons.add_shopping_cart_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Mua ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({required String username, required int rating, required String date, required String comment}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                Icons.star_rounded,
                size: 14,
                color: index < rating ? Colors.amber : Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(comment, style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff8f9fa),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12.5, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageNavButton extends StatelessWidget {
  final IconData icon;
  final bool visible;
  final VoidCallback onTap;

  const _ImageNavButton({required this.icon, required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(width: 36);

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white.withOpacity(0.85),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.black87, size: 22),
        onPressed: onTap,
      ),
    );
  }
}

class _ShopVisitCard extends StatelessWidget {
  final Product product;
  const _ShopVisitCard({required this.product});

  void _goToShop(BuildContext context, String? logoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrandProductsScreen(brandName: product.brand, brandLogoUrl: logoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('brands').where('name', isEqualTo: product.brand).limit(1).snapshots(),
      builder: (context, brandSnapshot) {
        final logoUrl = brandSnapshot.data?.docs.isNotEmpty == true ? (brandSnapshot.data!.docs.first.data()['url'] as String?) : null;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productsSnapshot) {
            final allDocs = productsSnapshot.data?.docs ?? [];
            final shopProducts = allDocs
                .map((d) => Product.fromMap(d.id, d.data()))
                .where((p) => p.brand.trim().toLowerCase() == product.brand.trim().toLowerCase())
                .toList();

            final otherProducts = shopProducts.where((p) => p.id != product.id).toList();
            final avgRating = shopProducts.isEmpty ? 0.0 : shopProducts.fold<double>(0, (sum, p) => sum + p.rating) / shopProducts.length;
            final totalSold = shopProducts.fold<int>(0, (sum, p) => sum + p.soldCount);

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _goToShop(context, logoUrl),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: (logoUrl != null && logoUrl.isNotEmpty)
                                  ? Image.network(
                                      logoUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Center(child: Text(product.brand.isNotEmpty ? product.brand[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                    )
                                  : Center(child: Text(product.brand.isNotEmpty ? product.brand[0].toUpperCase() : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.brand, style: AppTextStyles.heading3),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(avgRating > 0 ? avgRating.toStringAsFixed(1) : '—', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 10),
                                    Text('${shopProducts.length} sản phẩm', style: AppTextStyles.caption),
                                    const SizedBox(width: 10),
                                    Text('Đã bán $totalSold', style: AppTextStyles.caption),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _goToShop(context, logoUrl),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                            child: const Text('Xem Shop'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (otherProducts.isNotEmpty) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                      child: Text('Sản phẩm khác của shop', style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                        itemCount: otherProducts.length > 8 ? 8 : otherProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final p = otherProducts[index];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                            ),
                            child: Container(
                              width: 118,
                              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                      child: p.hasImage
                                          ? Image.network(p.image, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Icon(p.icon, color: AppColors.primary))
                                          : Icon(p.icon, color: AppColors.primary),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                                        Text(formatVnd(p.price), style: AppTextStyles.price.copyWith(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
