import 'package:flutter/foundation.dart';

/// Thông tin hồ sơ người dùng (in-memory, không kết nối Firebase/Database).
/// Dùng để màn hình "Chỉnh sửa hồ sơ" cập nhật và các màn khác đọc lại.
class UserProfileController extends ChangeNotifier {
  UserProfileController._internal();
  static final UserProfileController instance =
      UserProfileController._internal();

  String name = 'Nguyễn Văn A';
  String email = 'guest@spereemall.vn';
  String phone = '0901 234 567';
  String gender = 'Nam';
  String birthday = '01/01/2000';

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
}
