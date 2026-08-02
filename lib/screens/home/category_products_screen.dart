import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spreemall/controllers/brand_controller.dart';
import '../../models/product.dart';
import 'brand_products_screen.dart';
import 'product_grid_section.dart';

bool _productMatchesCategoryId(Product p, String categoryId) {
  final cat = p.category.toLowerCase();
  final gender = p.gender;

  switch (categoryId) {
    case 'dien_thoai':
      return cat.contains('điện thoại');
    case 'laptop':
      return cat.contains('laptop');
    case 'dong_ho':
      return cat.contains('đồng hồ');
    case 'tai_nghe':
      return cat.contains('tai nghe');
    case 'thoi_trang_nam':
      return (cat.contains('thời trang') || cat.contains('áo') || cat.contains('quần') || cat.contains('váy')) &&
          (gender == 'nam' || gender == 'unisex');
    case 'thoi_trang_nu':
      return (cat.contains('thời trang') || cat.contains('áo') || cat.contains('quần') || cat.contains('váy')) &&
          (gender == 'nu' || gender == 'unisex');
    case 'giay_dep_nam':
      return (cat.contains('giày') || cat.contains('dép')) && (gender == 'nam' || gender == 'unisex');
    case 'giay_dep_nu':
      return (cat.contains('giày') || cat.contains('dép')) && (gender == 'nu' || gender == 'unisex');
    case 'nha_bep':
      return cat.contains('bếp') || cat.contains('nồi') || cat.contains('chảo');
    case 'tv':
      return cat.contains('tv') || cat.contains('tivi');
    default:
      return false;
  }
}

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final int _seed = DateTime.now().millisecondsSinceEpoch;

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
              hintText: 'Tìm kiếm trong ${widget.categoryName} Mall',
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
                    future: BrandController().getBrandsByCategoryId(widget.categoryId),
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
                        height: 130,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: brands.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.55,
                          ),
                          itemBuilder: (context, index) {
                            final brand = brands[index];

                            String originalUrl = brand['logoUrl'] ?? '';
                            String displayUrl = '';

                            if (originalUrl.isNotEmpty) {
                              displayUrl = 'https://images.weserv.nl/?url=$originalUrl&w=200&h=100&fit=contain&bg=white';
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BrandProductsScreen(
                                      brandName: (brand['name'] ?? '').toString(),
                                      brandLogoUrl: displayUrl,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
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
                                              errorBuilder: (context, error, stackTrace) => _BrandFallback(name: (brand['name'] ?? '').toString()),
                                            ),
                                          ),
                                        )
                                      : _BrandFallback(name: (brand['name'] ?? '').toString()),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final allProducts = (snapshot.data?.docs ?? [])
                      .map((d) => Product.fromMap(d.id, d.data()))
                      .toList();

                  var related = allProducts
                      .where((p) => _productMatchesCategoryId(p, widget.categoryId))
                      .toList();

                  if (related.isEmpty) {
                    related = allProducts
                        .where((p) => p.category.toLowerCase().contains(widget.categoryName.toLowerCase()))
                        .toList();
                  }

                  related.shuffle(Random(_seed));
                  final suggested = related.take(8).toList();

                  if (suggested.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'Chưa có sản phẩm nào ở danh mục này.',
                          style: TextStyle(color: Colors.black38, fontSize: 13),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: suggested.length,
                    itemBuilder: (context, index) => ProductCard(product: suggested[index]),
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

class _BrandFallback extends StatelessWidget {
  final String name;

  const _BrandFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storefront_outlined, color: Colors.grey, size: 20),
          const SizedBox(height: 2),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
