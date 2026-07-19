import 'package:cloud_firestore/cloud_firestore.dart';

class BrandController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Hàm này nhận vào ID danh mục nào thì sẽ tự động lọc ra thương hiệu của danh mục đó
  Future<List<Map<String, dynamic>>> getBrandsByCategoryId(String categoryId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('brands')
          .where('categoryIds', arrayContains: categoryId) // Hàm thần thánh giúp lọc trong mảng
          .get();
          
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        
        return {
          'id': doc.id,
          'name': data['name']?.toString() ?? 'Không tên',
          // 🌟 ĐÃ SỬA TẠI ĐÂY: Chuyển trường 'url' từ Firebase thành key 'logoUrl' để giao diện đọc được
          'logoUrl': data['url']?.toString() ?? '', 
        };
      }).toList();
    } catch (e) {
      print("Lỗi khi lấy brand: $e");
      return [];
    }
  }
}