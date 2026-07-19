import 'package:flutter/foundation.dart';

/// Thông tin hồ sơ người dùng (in-memory, không kết nối Firebase/Database).
/// Dùng để màn hình "Chỉnh sửa hồ sơ" cập nhật và các màn khác đọc lại.
import 'package:flutter/foundation.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController._internal();
  static final UserProfileController instance = UserProfileController._internal();

  // Mặc định để rỗng để khi chưa đăng nhập hoặc đang tải sẽ không bị lộ thông tin cũ
  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  String birthday = '';

  // Hàm cập nhật từ giao diện (khi sửa hồ sơ) hoặc khi vừa đăng nhập xong
  void update({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? birthday,
  }) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (gender != null) this.gender = gender;
    if (birthday != null) this.birthday = birthday;
    notifyListeners();
  }

  // Hàm xóa sạch dữ liệu khi Đăng xuất
  void clearProfile() {
    name = '';
    email = '';
    phone = '';
    gender = '';
    birthday = '';
    notifyListeners();
  }

}
