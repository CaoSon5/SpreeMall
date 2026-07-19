import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spreemall/controllers/brand_controller.dart'; 

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final String categoryId; 

  const CategoryProductsScreen({
    super.key, 
    required this.categoryName,
    required this.categoryId,
  });

  // Hàm này tạm thời không dùng nữa vì bạn đang gọi trực tiếp qua BrandController().getBrandsByCategoryId(categoryId) ở dưới
  Future<List<Map<String, dynamic>>> _getBrandsFromFirebase(String category) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('brands')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name']?.toString() ?? 'Không tên',
          'logoUrl': data['url']?.toString() ?? '', 
        };
      }).toList();
    } catch (e) {
      print("Lỗi khi tải dữ liệu từ Firebase: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm trong $categoryName Mall',
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Khung THƯƠNG HIỆU ƯA CHUỘNG (Đã đổi thành lưới chữ nhật 2 hàng)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'THƯƠNG HIỆU ƯA CHUỘNG',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Text('Xem tất cả', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black54),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: BrandController().getBrandsByCategoryId(categoryId), 
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Không có thương hiệu nào thuộc danh mục này.',
                              style: TextStyle(color: Colors.black38, fontSize: 13),
                            ),
                          ),
                        );
                      }

                      final brands = snapshot.data!;

                      return SizedBox(
                        // Tăng chiều cao lên 130 để chứa vừa vặn 2 hàng ô chữ nhật
                        height: 130, 
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal, // Cuộn theo chiều ngang
                          itemCount: brands.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,          // Chia làm 2 hàng cố định
                            mainAxisSpacing: 8,         // Khoảng cách giữa các ô nằm ngang
                            crossAxisSpacing: 8,        // Khoảng cách giữa hàng trên và hàng dưới
                            childAspectRatio: 0.55,     // Tỷ lệ khung hình chữ nhật (Chiều rộng = khoảng 1.8 lần chiều cao)
                          ),
                          itemBuilder: (context, index) {
                            final brand = brands[index];
                            
                            String originalUrl = brand['logoUrl'] ?? '';
                            String displayUrl = '';

                            // Sử dụng proxy để tối ưu kích thước chữ nhật 200x100 và tự tạo nền trắng
                            if (originalUrl.isNotEmpty) {
                              displayUrl = 'https://images.weserv.nl/?url=$originalUrl&w=200&h=100&fit=contain&bg=white';
                            }

                            return GestureDetector(
                              onTap: () {
                                print("Đã chọn thương hiệu: ${brand['name']}");
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle, // Khung hình chữ nhật
                                  borderRadius: BorderRadius.circular(2), // Bo góc nhẹ tinh tế
                                  border: Border.all(
                                    color: Colors.grey.shade200, // Viền xám mảnh bao quanh ô
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: displayUrl.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                          child: Center(
                                            child: Image.network(
                                              displayUrl,
                                              fit: BoxFit.contain,
                                              filterQuality: FilterQuality.high,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.broken_image, color: Colors.grey, size: 20),
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.broken_image, color: Colors.grey, size: 20),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 2. Khung GỢI Ý HÔM NAY 
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'GỢI Ý HÔM NAY',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 4, 
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD32F2F),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  'Mall',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sản phẩm cao cấp chuyên về $categoryName chất lượng',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '549.000đ',
                                style: TextStyle(color: Color(0xFFD32F2F), fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}