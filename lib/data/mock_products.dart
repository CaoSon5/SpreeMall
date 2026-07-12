import 'package:flutter/material.dart';

import '../models/product.dart';


class MockProducts {
  MockProducts._();

  static const List<Product> all = [
   Product(
  id: 'p001',
  name: 'Điện thoại thông minh X1',
  category: 'Điện thoại',
  price: 4990000,
  oldPrice: 5990000,
  rating: 4.8,
  soldCount: 1200,

  image: 'assets/images/iphone15.png',

  icon: Icons.smartphone,
  iconBgColor: Color(0xFFE3F2FD),
  description:
      'Điện thoại thông minh X1 sở hữu màn hình sắc nét, camera đa năng '
      'và pin trâu cho cả ngày dài sử dụng. Hiệu năng mạnh mẽ, phù hợp '
      'cho công việc lẫn giải trí.',
),
    Product(
  id: 'p002',
  name: 'Laptop mỏng nhẹ Pro',
  category: 'Laptop',
  price: 15990000,
  rating: 4.7,
  soldCount: 356,

  image: 'assets/images/macbook_air_m2.png',

  icon: Icons.laptop_mac,
  iconBgColor: Color(0xFFEDE7F6),
  description:
      'Laptop mỏng nhẹ Pro với thiết kế sang trọng, chip xử lý thế hệ mới '
      'và thời lượng pin lên đến 12 giờ, lý tưởng cho dân văn phòng và '
      'sinh viên.',
),
    Product(
  id: 'p003',
  name: 'Giày sneaker năng động',
  category: 'Thời trang',
  price: 590000,
  oldPrice: 790000,
  rating: 4.6,
  soldCount: 2103,

  image: 'assets/images/nike_running.png',

  icon: Icons.sports_baseball_outlined,
  iconBgColor: Color(0xFFFFF3E0),
  description:
      'Giày sneaker năng động với chất liệu thoáng khí, đế êm chân, '
      'phù hợp cho việc đi bộ, tập luyện hoặc phối đồ hàng ngày.',
),
    Product(
  id: 'p004',
  name: 'Nồi chiên không dầu',
  category: 'Gia dụng',
  price: 890000,
  rating: 4.5,
  soldCount: 987,

  image: 'assets/images/airfryer.png',

  icon: Icons.kitchen_outlined,
  iconBgColor: Color(0xFFFFEBEE),
  description:
      'Nồi chiên không dầu giúp chế biến món ăn nhanh chóng, giảm dầu mỡ, '
      'tốt cho sức khoẻ. Dung tích lớn phù hợp cho gia đình 3-4 người.',
),
   Product(
  id: 'p005',
  name: 'Bàn phím cơ RGB',
  category: 'Phụ kiện',
  price: 690000,
  oldPrice: 890000,
  rating: 4.9,
  soldCount: 540,

  image: 'assets/images/keyboard_mechanical.png',

  icon: Icons.keyboard_outlined,
  iconBgColor: Color(0xFFE8F5E9),
  description:
      'Bàn phím cơ RGB với switch nảy tốt, đèn nền tuỳ chỉnh nhiều hiệu ứng, '
      'phù hợp cho game thủ và người dùng văn phòng yêu thích gõ phím.',
),  
    Product(
  id: 'p006',
  name: 'Túi xách thời trang',
  category: 'Thời trang',
  price: 450000,
  rating: 4.4,
  soldCount: 764,

  image: 'assets/images/handbag.png',

  icon: Icons.shopping_bag_outlined,
  iconBgColor: Color(0xFFFCE4EC),
  description:
      'Túi xách thời trang thiết kế trẻ trung, chất liệu da PU cao cấp, '
      'nhiều ngăn tiện lợi, phù hợp đi làm và đi chơi.',
),
   Product(
  id: 'p007',
  name: 'Tai nghe Bluetooth',
  category: 'Phụ kiện',
  price: 199000,
  oldPrice: 399000,
  rating: 4.3,
  soldCount: 3021,

  image: 'assets/images/airpods_pro.png',

  icon: Icons.headphones,
  iconBgColor: Color(0xFFE1F5FE),
  description:
      'Tai nghe Bluetooth nhỏ gọn, kết nối ổn định, âm thanh rõ ràng, '
      'thời lượng pin lên đến 20 giờ khi dùng kèm hộp sạc.',
),
    Product(
  id: 'p008',
  name: 'Áo thun basic',
  category: 'Thời trang',
  price: 89000,
  oldPrice: 159000,
  rating: 4.2,
  soldCount: 5210,

  image: 'assets/images/adidas_sneaker.png',

  icon: Icons.checkroom,
  iconBgColor: Color(0xFFF1F8E9),
  description:
      'Áo thun basic chất liệu cotton co giãn, thấm hút mồ hôi tốt, '
      'dễ phối đồ, có nhiều màu sắc để lựa chọn.',
),
   Product(
  id: 'p009',
  name: 'Đồng hồ thể thao',
  category: 'Đồng hồ',
  price: 349000,
  oldPrice: 599000,
  rating: 4.6,
  soldCount: 421,

  image: 'assets/images/watch.png',

  icon: Icons.watch_outlined,
  iconBgColor: Color(0xFFEFEBE9),
  description:
      'Đồng hồ thể thao chống nước, theo dõi nhịp tim và bước chân, '
      'màn hình hiển thị rõ ràng cả khi trời nắng gắt.',
),
    Product(
  id: 'p010',
  name: 'Balo laptop',
  category: 'Phụ kiện',
  price: 259000,
  oldPrice: 450000,
  rating: 4.5,
  soldCount: 812,

  image: 'assets/images/backpack.png',

  icon: Icons.backpack_outlined,
  iconBgColor: Color(0xFFE0F2F1),
  description:
      'Balo laptop chống sốc, chống nước nhẹ, nhiều ngăn chứa đồ, '
      'phù hợp cho việc đi học, đi làm hoặc du lịch ngắn ngày.',
),
  ];
  static  List<Product> featured = [
    all[0],
    all[1],
    all[2],
    all[3],
    all[4],
    all[5],
  ];
  static List<Product> get flashSale =>
      all.where((p) => p.hasDiscount).toList();

  static Product byId(String id) => all.firstWhere((p) => p.id == id);
}
