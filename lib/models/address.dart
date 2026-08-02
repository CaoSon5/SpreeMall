
class Address {
  final String id;
  final String name;
  final String phone;
  final String detail;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.detail,
    this.isDefault = false,
  });

  factory Address.fromMap(String id, Map<String, dynamic> data) {
    return Address(
      id: id,
      name: (data['name'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      detail: (data['detail'] ?? '') as String,
      isDefault: (data['isDefault'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'detail': detail,
      'isDefault': isDefault,
    };
  }

  Address copyWith({String? name, String? phone, String? detail, bool? isDefault}) {
    return Address(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
