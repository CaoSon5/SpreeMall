import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

const String cartHiveBoxName = 'cart_box';

class CartItem {
  final Product product;
  int quantity;
  bool selected;
  final String? size;

  CartItem({
    required this.product,
    required this.quantity,
    this.selected = true,
    this.size,
  });

  int get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'quantity': quantity,
        'selected': selected,
        'size': size,
        'product': product.toMap(),
      };

  static CartItem fromJson(Map<String, dynamic> json) {
    final productId = json['productId'] as String;
    final productMap = Map<String, dynamic>.from(json['product'] as Map);
    return CartItem(
      product: Product.fromMap(productId, productMap),
      quantity: (json['quantity'] ?? 1) as int,
      selected: (json['selected'] ?? true) as bool,
      size: json['size'] as String?,
    );
  }
}

class CartController extends GetxController {
  static CartController get instance => Get.find<CartController>();

  final List<CartItem> _items = [];

  bool _isLoading = false;

  Box<String> get _box => Hive.box<String>(cartHiveBoxName);

  String _keyFor(String uid) => 'cart_$uid';

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  int get selectedCount => _items.where((i) => i.selected).length;

  bool get isAllSelected => _items.isNotEmpty && _items.every((i) => i.selected);

  int get selectedTotalPrice => _items.where((i) => i.selected).fold(0, (sum, i) => sum + i.totalPrice);

  bool _sameLine(CartItem item, String productId, String? size) {
    return item.product.id == productId && item.size == size;
  }

  bool contains(String productId, {String? size}) => _items.any((i) => _sameLine(i, productId, size));

  void addProduct(Product product, {int quantity = 1, String? size}) {
    final index = _items.indexWhere((i) => _sameLine(i, product.id, size));
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity, size: size));
    }
    update();
    _saveCart();
  }

  void buyNow(Product product, {int quantity = 1, String? size}) {
    for (final item in _items) {
      item.selected = false;
    }
    final index = _items.indexWhere((i) => _sameLine(i, product.id, size));
    if (index >= 0) {
      _items[index].quantity += quantity;
      _items[index].selected = true;
    } else {
      _items.add(CartItem(product: product, quantity: quantity, selected: true, size: size));
    }
    update();
    _saveCart();
  }

  void removeItem(String productId, {String? size}) {
    _items.removeWhere((i) => _sameLine(i, productId, size));
    update();
    _saveCart();
  }

  void increaseQuantity(String productId, {String? size}) {
    final index = _items.indexWhere((i) => _sameLine(i, productId, size));
    if (index >= 0) {
      _items[index].quantity++;
      update();
      _saveCart();
    }
  }

  void decreaseQuantity(String productId, {String? size}) {
    final index = _items.indexWhere((i) => _sameLine(i, productId, size));
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].quantity--;
      }
      update();
      _saveCart();
    }
  }

  void toggleSelected(String productId, {String? size}) {
    final index = _items.indexWhere((i) => _sameLine(i, productId, size));
    if (index >= 0) {
      _items[index].selected = !_items[index].selected;
      update();
      _saveCart();
    }
  }

  void toggleSelectAll(bool value) {
    for (final item in _items) {
      item.selected = value;
    }
    update();
    _saveCart();
  }

  void checkoutSelected() {
    _items.removeWhere((i) => i.selected);
    update();
    _saveCart();
  }

  void clear() {
    _items.clear();
    update();
    _saveCart();
  }

  void clearLocalOnly() {
    _items.clear();
    update();
  }

  void _saveCart() {
    if (_isLoading) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final jsonList = _items.map((i) => i.toJson()).toList();
      _box.put(_keyFor(uid), jsonEncode(jsonList));
    } catch (e) {

      print('Lỗi khi lưu giỏ hàng vào Hive: $e');
    }
  }

  Future<void> loadCart(String uid) async {
    _isLoading = true;
    try {
      _items.clear();

      final raw = _box.get(_keyFor(uid));
      if (raw == null || raw.isEmpty) {
        update();
        return;
      }

      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final entry in decoded) {
        try {
          _items.add(CartItem.fromJson(Map<String, dynamic>.from(entry as Map)));
        } catch (_) {

        }
      }

      update();
    } catch (e) {

      print('Lỗi khi tải giỏ hàng từ Hive: $e');
    } finally {
      _isLoading = false;
    }
  }
}
