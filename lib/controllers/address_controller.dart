import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/address.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find<AddressController>();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _ref {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('addresses');
  }

  Stream<List<Address>> watchAddresses() {
    final ref = _ref;
    if (ref == null) return const Stream.empty();
    return ref.snapshots().map(
          (snap) => snap.docs.map((d) => Address.fromMap(d.id, d.data())).toList()
            ..sort((a, b) => b.isDefault ? 1 : -1),
        );
  }

  Future<void> addAddress({
    required String name,
    required String phone,
    required String detail,
    bool isDefault = false,
  }) async {
    final ref = _ref;
    if (ref == null) return;

    if (isDefault) {
      await _clearOtherDefaults(ref);
    }

    final existing = await ref.limit(1).get();
    final shouldBeDefault = isDefault || existing.docs.isEmpty;

    await ref.add({
      'name': name,
      'phone': phone,
      'detail': detail,
      'isDefault': shouldBeDefault,
    });
  }

  Future<void> updateAddress(
    String addressId, {
    required String name,
    required String phone,
    required String detail,
  }) async {
    final ref = _ref;
    if (ref == null) return;
    await ref.doc(addressId).update({
      'name': name,
      'phone': phone,
      'detail': detail,
    });
  }

  Future<void> deleteAddress(String addressId) async {
    final ref = _ref;
    if (ref == null) return;
    await ref.doc(addressId).delete();
  }

  Future<void> setDefault(String addressId) async {
    final ref = _ref;
    if (ref == null) return;
    await _clearOtherDefaults(ref);
    await ref.doc(addressId).update({'isDefault': true});
  }

  Future<void> _clearOtherDefaults(CollectionReference<Map<String, dynamic>> ref) async {
    final snapshot = await ref.where('isDefault', isEqualTo: true).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  Future<Address?> fetchDefaultAddress() async {
    final ref = _ref;
    if (ref == null) return null;

    final defaultSnap = await ref.where('isDefault', isEqualTo: true).limit(1).get();
    if (defaultSnap.docs.isNotEmpty) {
      final doc = defaultSnap.docs.first;
      return Address.fromMap(doc.id, doc.data());
    }

    final anySnap = await ref.limit(1).get();
    if (anySnap.docs.isNotEmpty) {
      final doc = anySnap.docs.first;
      return Address.fromMap(doc.id, doc.data());
    }

    return null;
  }
}
