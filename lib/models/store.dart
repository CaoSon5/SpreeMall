
enum StoreStatus { pending, approved, rejected }

StoreStatus storeStatusFromString(String? raw) {
  return StoreStatus.values.firstWhere(
    (e) => e.name == raw,
    orElse: () => StoreStatus.pending,
  );
}

extension StoreStatusX on StoreStatus {
  String get value => name;

  String get label {
    switch (this) {
      case StoreStatus.pending:
        return 'Chờ duyệt';
      case StoreStatus.approved:
        return 'Đã duyệt';
      case StoreStatus.rejected:
        return 'Bị từ chối';
    }
  }
}

class Store {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String bannerUrl;
  final String ownerUid;
  final String ownerEmail;
  final List<String> categoryIds;
  final StoreStatus status;
  final String? rejectReason;

  const Store({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    this.bannerUrl = '',
    required this.ownerUid,
    required this.ownerEmail,
    required this.categoryIds,
    required this.status,
    this.rejectReason,
  });

  factory Store.fromMap(String id, Map<String, dynamic> data) {
    return Store(
      id: id,
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      logoUrl: (data['logoUrl'] ?? '') as String,
      bannerUrl: (data['bannerUrl'] ?? '') as String,
      ownerUid: (data['ownerUid'] ?? '') as String,
      ownerEmail: (data['ownerEmail'] ?? '') as String,
      categoryIds: (data['categoryIds'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      status: storeStatusFromString(data['status'] as String?),
      rejectReason: data['rejectReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'ownerUid': ownerUid,
      'ownerEmail': ownerEmail,
      'categoryIds': categoryIds,
      'status': status.value,
      'rejectReason': rejectReason,
    };
  }
}
