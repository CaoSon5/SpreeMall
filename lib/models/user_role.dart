
enum UserRole {
  user,
  admin,
}

extension UserRoleX on UserRole {

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
    }
  }

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.user:
        return 'Khách hàng';
    }
  }

  bool get isAdmin => this == UserRole.admin;
}

UserRole userRoleFromString(String? raw) {
  switch (raw) {
    case 'admin':
      return UserRole.admin;
    case 'user':
      return UserRole.user;
    default:
      return UserRole.user;
  }
}
