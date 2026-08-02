import 'package:flutter/material.dart';
class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final int? oldPrice;
  final double rating;
  final int soldCount;
  final int stock;

  final String image;
  final IconData icon;
  final Color iconBgColor;
  final String description;
  final bool isFlashSale;
  final List<String> sizes;
  final String brand;
  final String gender;
  final List<String> images;
  final Map<String, String> specs;
  final String storeId;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.rating = 4.5,
    this.soldCount = 0,
    this.stock = 100,

    this.image = '',

    this.icon = Icons.image_outlined,
    this.iconBgColor = const Color(0xFFF3F3F3),

    this.description = '',
    this.isFlashSale = false,
    this.sizes = const [],
    this.brand = '',
    this.gender = 'unisex',
    this.images = const [],
    this.specs = const {},
    this.storeId = '',
  });

  int get discountPercent {
    if (oldPrice == null || oldPrice! <= price) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  bool get hasDiscount => discountPercent > 0;

  bool get hasImage => image.isNotEmpty;

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: (data['name'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      price: _toInt(data['price']),
      oldPrice: data['oldPrice'] == null ? null : _toInt(data['oldPrice']),
      rating: (data['rating'] == null) ? 4.5 : (data['rating'] as num).toDouble(),
      soldCount: _toInt(data['soldCount']),
      stock: data['stock'] == null ? 100 : _toInt(data['stock']),
      image: (data['image'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      isFlashSale: (data['isFlashSale'] ?? false) as bool,
      sizes: (data['sizes'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      brand: (data['brand'] ?? '') as String,
      gender: (data['gender'] ?? 'unisex') as String,
      images: (data['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      specs: Map<String, String>.from(data['specs'] as Map? ?? {}),
      storeId: (data['storeId'] ?? '') as String,
    );
  }

  List<String> get allImages {
    final list = <String>[
      if (image.isNotEmpty) image,
      ...images.where((e) => e.isNotEmpty && e != image),
    ];
    return list;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'soldCount': soldCount,
      'stock': stock,
      'image': image,
      'description': description,
      'isFlashSale': isFlashSale,
      'sizes': sizes,
      'brand': brand,
      'gender': gender,
      'images': images,
      'specs': specs,
      'storeId': storeId,
    };
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}