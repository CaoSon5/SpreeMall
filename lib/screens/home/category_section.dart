import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  final List<Map<String, dynamic>> categories = const [

    {
      "icon": Icons.phone_android,
      "title": "Điện thoại",
    },

    {
      "icon": Icons.laptop,
      "title": "Laptop",
    },

    {
      "icon": Icons.watch,
      "title": "Đồng hồ",
    },

    {
      "icon": Icons.headphones,
      "title": "Tai nghe",
    },

    {
      "icon": Icons.checkroom,
      "title": "Thời trang",
    },

    {
      "icon": Icons.sports_esports,
      "title": "Game",
    },

    {
      "icon": Icons.tv,
      "title": "TV",
    },

    {
      "icon": Icons.more_horiz,
      "title": "Khác",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Danh mục",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          GridView.builder(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            itemCount: categories.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,

              childAspectRatio: .9,
            ),

            itemBuilder: (_, index) {

              final item = categories[index];

              return Column(
                children: [

                  CircleAvatar(
                    radius: 28,

                    backgroundColor: Colors.orange.shade100,

                    child: Icon(
                      item["icon"],
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    item["title"],
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}