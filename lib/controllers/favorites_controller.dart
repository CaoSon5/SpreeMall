import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// Quản lý danh sách sản phẩm yêu thích toàn app (in-memory).
class FavoritesController extends ChangeNotifier {
  FavoritesController._internal();
  static final FavoritesController instance = FavoritesController._internal();

  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get count => _items.length;

  bool isFavorite(String productId) =>
      _items.any((p) => p.id == productId);

  void toggle(Product product) {
    if (isFavorite(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
 