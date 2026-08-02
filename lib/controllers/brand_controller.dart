import 'package:cloud_firestore/cloud_firestore.dart';

class BrandController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBrandsByCategoryId(String categoryId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('brands')
          .where('categoryIds', arrayContains: categoryId)
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'name': data['name']?.toString() ?? 'Không tên',

          'logoUrl': data['url']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print("Lỗi khi lấy brand: $e");
      return [];
    }
  }
}