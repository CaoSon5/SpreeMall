import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_role.dart';

class RoleController extends GetxController {
  static RoleController get instance => Get.find<RoleController>();

  final Rx<UserRole> role = UserRole.user.obs;

  final RxBool isLoadingRole = false.obs;

  String? _currentUid;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roleSubscription;

  bool get isAdmin => role.value.isAdmin;
  bool get isUser => !isAdmin;

  Future<UserRole> fetchRole(String uid) async {
    isLoadingRole.value = true;
    try {

      await _roleSubscription?.cancel();

      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

      final doc = await docRef.get();
      final resolvedRole = userRoleFromString(doc.data()?['role'] as String?);

      role.value = resolvedRole;
      _currentUid = uid;

      _roleSubscription = docRef.snapshots().listen((snapshot) {
        final liveRole = userRoleFromString(snapshot.data()?['role'] as String?);
        if (liveRole != role.value) {
          role.value = liveRole;
        }
      });

      return resolvedRole;
    } catch (e) {

      role.value = UserRole.user;
      return UserRole.user;
    } finally {
      isLoadingRole.value = false;
    }
  }

  void setRole(UserRole newRole) {
    role.value = newRole;
  }

  void reset() {
    _roleSubscription?.cancel();
    _roleSubscription = null;
    role.value = UserRole.user;
    _currentUid = null;
  }

  String? get currentUid => _currentUid;

  @override
  void onClose() {
    _roleSubscription?.cancel();
    super.onClose();
  }
}
