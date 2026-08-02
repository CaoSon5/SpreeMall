import 'package:flutter/material.dart';
import 'category_products_screen.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      "id": "dien_thoai",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/186/186239.png",
      "title": "Điện thoại",
    },
    {
      "id": "laptop",
      "iconUrl": "https://cdn-icons-png.flaticon.com/512/428/428001.png",
      "title": "Laptop",
    },
    {
      "id": "dong_ho",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/9413/9413719.png",
      "title": "Đồng hồ",
    },
    {
      "id": "tai_nghe",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/6191/6191093.png",
      "title": "Tai nghe",
    },
    {
      "id": "thoi_trang_nam",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/4715/4715310.png",
      "title": "Thời trang nam",
    },
    {
      "id": "thoi_trang_nu",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/3534/3534312.png",
      "title": "Thời trang nữ",
    },
    {
      "id": "giay_dep_nam",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/15619/15619938.png",
      "title": "Giày dép nam",
    },
    {
      "id": "giay_dep_nu",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/17023/17023709.png",
      "title": "Giày dép nữ",
    },
    {
      "id": "nha_bep",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/1566/1566914.png",
      "title": "Nhà bếp",
    },
    {
      "id": "tv",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/3800/3800088.png",
      "title": "TV",
    },
    {
      "id": "khac",
      "iconUrl": "https://cdn-icons-png.flaticon.com/128/11825/11825276.png",
      "title": "Khác",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            "Danh mục",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 5),

        SizedBox(
          height: 115,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 15, right: 5),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];

              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsScreen(
                          categoryName: item["title"] ?? "Danh mục",
                          categoryId: item["id"] ?? "",
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 75,
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              item["iconUrl"],
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported, color: Colors.orange, size: 20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item["title"],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}