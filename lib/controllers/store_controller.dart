import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/store.dart';

class StoreController extends GetxController {
  static StoreController get instance => Get.find<StoreController>();

  CollectionReference<Map<String, dynamic>> get _storesRef => FirebaseFirestore.instance.collection('stores');

  Stream<Store?> watchMyStore() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _storesRef.where('ownerUid', isEqualTo: uid).snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return Store.fromMap(doc.id, doc.data());
    });
  }

  Future<String?> requestStore({
    required String name,
    required String description,
    required String logoUrl,
    String bannerUrl = '',
    required List<String> categoryIds,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Vui lòng đăng nhập trước.';

    final existingSnap = await _storesRef.where('ownerUid', isEqualTo: user.uid).get();

    if (existingSnap.docs.isNotEmpty) {
      final existing = Store.fromMap(existingSnap.docs.first.id, existingSnap.docs.first.data());
      if (existing.status != StoreStatus.rejected) {
        return 'Tài khoản của bạn đã có 1 cửa hàng (${existing.status.label}). Mỗi tài khoản chỉ được mở 1 cửa hàng.';
      }

      await _storesRef.doc(existingSnap.docs.first.id).update({
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'bannerUrl': bannerUrl,
        'categoryIds': categoryIds,
        'status': StoreStatus.pending.value,
        'rejectReason': null,
      });
      return null;
    }

    await _storesRef.add({
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'ownerUid': user.uid,
      'ownerEmail': user.email ?? '',
      'categoryIds': categoryIds,
      'status': StoreStatus.pending.value,
      'rejectReason': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return null;
  }

  Future<String?> createStoreForUser({
    required String ownerEmail,
    required String name,
    required String description,
    required String logoUrl,
    String bannerUrl = '',
    required List<String> categoryIds,
  }) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final userSnap = await usersRef.where('email', isEqualTo: ownerEmail.trim()).limit(1).get();

    if (userSnap.docs.isEmpty) {
      return 'Không tìm thấy tài khoản nào với email "$ownerEmail". Tài khoản đó phải đăng ký trước.';
    }

    final ownerDoc = userSnap.docs.first;
    final ownerUid = ownerDoc.id;

    final existingStore = await _storesRef.where('ownerUid', isEqualTo: ownerUid).get();
    if (existingStore.docs.isNotEmpty) {
      final existing = Store.fromMap(existingStore.docs.first.id, existingStore.docs.first.data());
      return 'Tài khoản này đã sở hữu cửa hàng "${existing.name}" (${existing.status.label}) rồi. Mỗi tài khoản chỉ được 1 cửa hàng.';
    }

    final storeDoc = await _storesRef.add({
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'ownerUid': ownerUid,
      'ownerEmail': ownerEmail.trim(),
      'categoryIds': categoryIds,
      'status': StoreStatus.approved.value,
      'rejectReason': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await usersRef.doc(ownerUid).update({'storeId': storeDoc.id});

    final brandsRef = FirebaseFirestore.instance.collection('brands');
    final existingBrand = await brandsRef.where('name', isEqualTo: name).limit(1).get();
    if (existingBrand.docs.isEmpty) {
      await brandsRef.add({'name': name, 'url': logoUrl, 'categoryIds': categoryIds});
    } else {
      await existingBrand.docs.first.reference.update({'url': logoUrl, 'categoryIds': categoryIds});
    }

    return null;
  }

  Future<void> approveStore(Store store) async {
    final batch = FirebaseFirestore.instance.batch();

    batch.update(_storesRef.doc(store.id), {'status': StoreStatus.approved.value, 'rejectReason': null});
    batch.update(FirebaseFirestore.instance.collection('users').doc(store.ownerUid), {'storeId': store.id});

    await batch.commit();

    final brandsRef = FirebaseFirestore.instance.collection('brands');
    final existingBrand = await brandsRef.where('name', isEqualTo: store.name).limit(1).get();

    if (existingBrand.docs.isEmpty) {
      await brandsRef.add({
        'name': store.name,
        'url': store.logoUrl,
        'categoryIds': store.categoryIds,
      });
    } else {
      await existingBrand.docs.first.reference.update({
        'url': store.logoUrl,
        'categoryIds': store.categoryIds,
      });
    }
  }

  Future<void> updateStoreInfo({
    required String storeId,
    required String description,
    required String logoUrl,
    required String bannerUrl,
    required List<String> categoryIds,
  }) async {
    await _storesRef.doc(storeId).update({
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'categoryIds': categoryIds,
    });

    final storeSnap = await _storesRef.doc(storeId).get();
    final storeName = storeSnap.data()?['name'] as String?;
    if (storeName != null) {
      final brandsRef = FirebaseFirestore.instance.collection('brands');
      final brandSnap = await brandsRef.where('name', isEqualTo: storeName).limit(1).get();
      if (brandSnap.docs.isNotEmpty) {
        await brandSnap.docs.first.reference.update({'url': logoUrl, 'categoryIds': categoryIds});
      }
    }
  }

  Future<void> rejectStore(Store store, {String? reason}) async {
    await _storesRef.doc(store.id).update({
      'status': StoreStatus.rejected.value,
      'rejectReason': reason ?? 'Không đáp ứng yêu cầu của sàn.',
    });

    await FirebaseFirestore.instance.collection('users').doc(store.ownerUid).update({'storeId': FieldValue.delete()});
  }

  Stream<List<Store>> watchAllStores() {
    return _storesRef.snapshots().map((snap) => snap.docs.map((d) => Store.fromMap(d.id, d.data())).toList());
  }
}
