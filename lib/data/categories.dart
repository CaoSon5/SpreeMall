
class AppCategories {
  AppCategories._();

  static const List<Map<String, String>> all = [
    {'id': 'dien_thoai', 'title': 'Điện thoại'},
    {'id': 'laptop', 'title': 'Laptop'},
    {'id': 'dong_ho', 'title': 'Đồng hồ'},
    {'id': 'tai_nghe', 'title': 'Tai nghe'},
    {'id': 'thoi_trang_nam', 'title': 'Thời trang nam'},
    {'id': 'thoi_trang_nu', 'title': 'Thời trang nữ'},
    {'id': 'giay_dep_nam', 'title': 'Giày dép nam'},
    {'id': 'giay_dep_nu', 'title': 'Giày dép nữ'},
    {'id': 'nha_bep', 'title': 'Nhà bếp'},
    {'id': 'tv', 'title': 'TV'},
    {'id': 'khac', 'title': 'Khác'},
  ];

  static String titleOf(String id) {
    return all.firstWhere((c) => c['id'] == id, orElse: () => {'title': id})['title'] ?? id;
  }
}
