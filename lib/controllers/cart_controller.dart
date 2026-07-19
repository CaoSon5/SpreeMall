import 'package:get/get.dart'; // 🆕 Thêm GetX thay vì foundation.dart
import '../models/product.dart';

/// Một dòng sản phẩm trong giỏ hàng.
class CartItem {
  final Product product;
  int quantity;            
  bool selected; // 🆕 Sửa lại lỗi khai báo thiếu ở đoạn code cũ của bạn

  CartItem({
    required this.product,
    required this.quantity,
    this.selected = true,
  });

  int get totalPrice => product.price * quantity;
}


/// Quản lý giỏ hàng toàn app sử dụng GetxController
class CartController extends GetxController { 
  // 🆕 Cách lấy instance chuẩn GetX. Khi các màn hình khác gọi `CartController.instance`,
  // GetX sẽ tự động tìm kiếm controller đã được nạp trong bộ nhớ.
  static CartController get instance => Get.find<CartController>();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  int get selectedCount => _items.where((i) => i.selected).length;

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((i) => i.selected);

  int get selectedTotalPrice => _items
      .where((i) => i.selected)
      .fold(0, (sum, i) => sum + i.totalPrice);

  bool contains(String productId) =>
      _items.any((i) => i.product.id == productId);

  void addProduct(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    update(); // 🆕 Thay thế notifyListeners() bằng update() của GetX
  }
  /// 🆕 Xử lý tính năng "Mua ngay" từ trang chi tiết sản phẩm
  void buyNow(Product product, {int quantity = 1}) {
    // 1. Tự động bỏ chọn tất cả các sản phẩm đang có sẵn trong giỏ
    for (final item in _items) {
      item.selected = false;
    }

    // 2. Tìm xem sản phẩm bấm mua ngay đã tồn tại trong giỏ chưa
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      // Nếu đã có sẵn, cộng dồn số lượng và bắt buộc tích chọn nó
      _items[index].quantity += quantity;
      _items[index].selected = true;
    } else {
      // Nếu chưa có, thêm mới hoàn toàn vào giỏ với trạng thái selected = true
      _items.add(CartItem(product: product, quantity: quantity, selected: true));
    }
    update();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    update(); // 🆕 Cập nhật giao diện
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      update();
    }
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].quantity--;
      }
      update();
    }
  }

  void toggleSelected(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].selected = !_items[index].selected;
      update();
    }
  }

  void toggleSelectAll(bool value) {
    for (final item in _items) {
      item.selected = value;
    }
    update();
  }

  /// Xoá các sản phẩm đã chọn khỏi giỏ (dùng sau khi "đặt hàng" thành công).
  void checkoutSelected() {
    _items.removeWhere((i) => i.selected);
    update();
  }

  void clear() {
    _items.clear();
    update();
  }
}