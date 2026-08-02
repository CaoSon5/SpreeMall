import 'package:flutter/foundation.dart';

import 'package:flutter/foundation.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController._internal();
  static final UserProfileController instance = UserProfileController._internal();

  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  String birthday = '';

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

  void clearProfile() {
    name = '';
    email = '';
    phone = '';
    gender = '';
    birthday = '';
    notifyListeners();
  }

}
