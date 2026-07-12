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
  });

  int get discountPercent {
    if (oldPrice == null || oldPrice! <= price) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  bool get hasDiscount => discountPercent > 0;


  bool get hasImage => image.isNotEmpty;
}