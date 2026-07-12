import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// Một dòng sản phẩm trong giỏ hàng.
class CartItem {
  final Product product;
  int quantity;
  bool selected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selected = true,
  });

  int get totalPrice => product.price * quantity;
}

/// Quản lý giỏ hàng toàn app (in-memory, không lưu database/Firebase).
/// Dùng singleton + ChangeNotifier để mọi màn hình cùng lắng nghe thay đổi.
class CartController extends ChangeNotifier {
  CartController._internal();
  static final CartController instance = CartController._internal();

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
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final item = _items.firstWhere((i) => i.product.id == productId);
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final item = _items.firstWhere((i) => i.product.id == productId);
    if (item.quantity <= 1) {
      removeItem(productId);
    } else {
      item.quantity--;
      notifyListeners();
    }
  }

  void toggleSelected(String productId) {
    final item = _items.firstWhere((i) => i.product.id == productId);
    item.selected = !item.selected;
    notifyListeners();
  }

  void toggleSelectAll(bool value) {
    for (final item in _items) {
      item.selected = value;
    }
    notifyListeners();
  }

  /// Xoá các sản phẩm đã chọn khỏi giỏ (dùng sau khi "đặt hàng" thành công).
  void checkoutSelected() {
    _items.removeWhere((i) => i.selected);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
