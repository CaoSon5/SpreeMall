import 'package:flutter/material.dart';
import '../models/product.dart';

class MockProducts {
  MockProducts._();

  // Biến toàn bộ danh sách thành rỗng để không bị lỗi "Unable to load asset" nữa
  static const List<Product> all = [];
  static List<Product> featured = [];
  static List<Product> get flashSale => [];

  static Product byId(String id) {
    return const Product(
      id: 'empty',
      name: 'Chưa có dữ liệu',
      category: '',
      price: 0,
      image: '',
      description: '',
    );
  }
}