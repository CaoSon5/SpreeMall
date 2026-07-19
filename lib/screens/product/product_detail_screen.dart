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
  late String _selectedSize; // Sẽ khởi tạo động trong initState
  late List<String> _sizes;  // Danh sách kích cỡ động theo loại sản phẩm

  Product get product => widget.product;

  // Kiểm tra xem sản phẩm có phải giày dép hay không dựa vào category (hoặc name)
  bool get _isShoeProduct {
    final categoryLower = product.category.toLowerCase();
    final nameLower = product.name.toLowerCase();
    
    return categoryLower.contains('shoe') || 
           categoryLower.contains('giày') || 
           categoryLower.contains('dép') ||
           categoryLower.contains('sneaker') ||
           // Các thương hiệu giày phổ biến nếu bạn lưu category theo hãng
           categoryLower.contains('adidas') || 
           categoryLower.contains('nike') || 
           categoryLower.contains('puma') ||
           nameLower.contains('giày') ||
           nameLower.contains('dép');
  }

  @override
  void initState() {
    super.initState();
    // Tự động phân loại danh sách kích cỡ khi mở màn hình chi tiết
    if (_isShoeProduct) {
      _sizes = ['38', '39', '40', '41', '42'];
      _selectedSize = '40'; // Size giày mặc định
    } else {
      _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
      _selectedSize = 'M';  // Size quần áo mặc định
    }
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
    CartController.instance.addProduct(product, quantity: _quantity);
    if (showMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.success,
          duration: const Duration(milliseconds: 1500),
          content: Text(
            '🎉 Đã thêm $_quantity x "${product.name}" (Size $_selectedSize) vào giỏ hàng',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Đặt hàng thành công', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Bạn đã đặt mua thành công số lượng $_quantity sản phẩm "${product.name}" - Size $_selectedSize.\n\nHệ thống đang xử lý đơn hàng của bạn.',
          style: AppTextStyles.bodyRegular.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Tuyệt vời', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Hàm mở Bottom Sheet hiển thị Hướng dẫn chọn Size dựa vào loại sản phẩm
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
    final isNetworkImage = product.image.startsWith('http://') || product.image.startsWith('https://');

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khối hình ảnh sản phẩm lớn
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: product.iconBgColor ?? Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                        child: Hero(
                          tag: 'product_${product.id}',
                          child: product.image.isNotEmpty
                              ? (isNetworkImage
                                  ? Image.network(product.image, fit: BoxFit.contain)
                                  : Image.asset(product.image, fit: BoxFit.contain))
                              : Icon(product.icon, size: 140, color: AppColors.primary),
                        ),
                      ),
                      if (product.hasDiscount)
                        Positioned(
                          top: 110,
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

                // Khối thông tin chi tiết dạng Card xếp lớp
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
                        // Hãng sản xuất
                        Text(
                          product.category.toUpperCase(),
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tên sản phẩm
                        Text(
                          product.name,
                          style: AppTextStyles.heading1.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Giá tiền + Đánh giá sao
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
                                    '${product.rating}',
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
                            Text('🔥 Đã bán ${product.soldCount}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            const SizedBox(width: 16),
                            Container(width: 1.5, height: 14, color: Colors.grey[300]),
                            const SizedBox(width: 16),
                            Text('📦 Kho còn: ${product.stock}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),

                        // --- SPREEMALL ĐẢM BẢO ---
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

                        // --- CHỌN KÍCH CỠ & HƯỚNG DẪN CHỌN SIZE ---
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

                        // Chọn số lượng
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

                        // Khối Chính sách mua hàng
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

                        // --- THÔNG SỐ KỸ THUẬT ---
                        Text('Thông số sản phẩm', style: AppTextStyles.heading3.copyWith(fontSize: 17)),
                        const SizedBox(height: 10),
                        _buildSpecificationRow('Thương hiệu', product.category.toUpperCase()),
                        _buildSpecificationRow('Chất liệu', _isShoeProduct ? 'Da cao cấp, Cao su tổng hợp' : 'Cotton cao cấp & Polyester'),
                        _buildSpecificationRow('Xuất xứ', 'Chính hãng'),
                        _buildSpecificationRow('Kiểu dáng', _isShoeProduct ? 'Thể thao năng động' : 'Thời trang ôm phom thoải mái'),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xfff1f3f5), thickness: 1.5),
                        ),

                        // Khối Mô tả sản phẩm
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

                        // --- KHỐI ĐÁNH GIÁ SẢN PHẨM ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Đánh giá sản phẩm', style: AppTextStyles.heading3.copyWith(fontSize: 17)),
                            Text('Xem tất cả (${product.soldCount > 5 ? '12' : '0'}) >', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildReviewItem(
                          username: 'nguyenvana***',
                          rating: 5,
                          date: '10-03-2026',
                          comment: _isShoeProduct 
                            ? 'Giày đi êm chân lắm, đế bám tốt dã man. Giao hàng cực nhanh, tư vấn chọn size chuẩn chỉnh luôn!' 
                            : 'Sản phẩm vải mặc siêu mát, giao hàng nhanh chóng tầm 2 ngày là nhận được rồi. Shop tư vấn size rất vừa vặn nhé!',
                        ),
                        const SizedBox(height: 12),
                        _buildReviewItem(
                          username: 'tranthib***',
                          rating: 4,
                          date: '02-03-2026',
                          comment: 'Hàng chuẩn Mall đóng gói rất cẩn thận, lên dáng đẹp, tuy nhiên shipper giao hơi trễ tí nhưng tổng quan vẫn rất hài lòng.',
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Khối AppBar trong suốt phía trên cùng
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
                        AnimatedBuilder(
                          animation: FavoritesController.instance,
                          builder: (context, _) {
                            final isFav = FavoritesController.instance.isFavorite(product.id);
                            return CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: IconButton(
                                onPressed: () => FavoritesController.instance.toggle(product),
                                icon: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav ? Colors.redAccent : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
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

      // Thanh Bottom mua hàng nổi dưới đáy
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

  // Widget dòng thông số kỹ thuật
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

  // Widget hiển thị từng item review của khách hàng
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

  // Widget phụ trợ vẽ khối dòng chính sách
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