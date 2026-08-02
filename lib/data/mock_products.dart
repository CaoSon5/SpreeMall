import 'package:flutter/material.dart';
import '../models/product.dart';

class MockProducts {
  MockProducts._();

  static const List<Product> all = [
    Product(
      id: 'p_adidas_01',
      name: 'Adidas UltraBoost 22',
      category: 'Giày Chạy Bộ',
      price: 4500000,
      oldPrice: 5200000,
      image: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=500',
      description: 'Giày chạy bộ cao cấp với đệm Boost siêu êm ái, hỗ trợ hoàn trả năng lượng tối đa trên mỗi bước chạy.',
      sizes: ['38', '39', '40', '41', '42'],
    ),
    Product(
      id: 'p_nike_02',
      name: 'Nike Air Max Tavas',
      category: 'Giày Thời Trang',
      price: 3800000,
      oldPrice: 4300000,
      image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
      description: 'Phong cách cổ điển kết hợp hiện đại, mang lại sự thoải mái tối đa cho các hoạt động di chuyển hằng ngày.',
      sizes: ['38', '39', '40', '41', '42'],
    ),
    Product(
      id: 'p_puma_03',
      name: 'Puma Suede Classic',
      category: 'Giày Da Lộn',
      price: 2200000,
      oldPrice: 2600000,
      image: 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=500',
      description: 'Biểu tượng văn hóa đường phố huyền thoại với chất liệu da lộn bền bỉ và kiểu dáng không bao giờ lỗi mốt.',
      sizes: ['38', '39', '40', '41', '42'],
    ),
  ];

  static List<Product> get featured => all;
  static List<Product> get flashSale => all;

  static Product byId(String id) {
    return all.firstWhere(
      (product) => product.id == id,
      orElse: () => const Product(
        id: 'empty',
        name: 'Chưa có dữ liệu',
        category: '',
        price: 0,
        image: '',
        description: '',
      ),
    );
  }
}
