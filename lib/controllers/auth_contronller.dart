import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../routes/app_routes.dart';

class AuthController {
  static Future<void> registerUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          'uid': firebaseUser.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'gender': 'Nam',
          'birthday': '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        UserProfileController.instance.update(
          name: name,
          email: email,
          phone: phone,
          gender: 'Nam',
          birthday: '',
        );

        if (context.mounted) Navigator.of(context).pop();

        Get.snackbar(
          'Thành công',
          'Tài khoản của bạn đã được tạo thành công!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      String message = 'Đăng ký thất bại';
      if (e.code == 'weak-password') message = 'Mật khẩu quá yếu.';
      if (e.code == 'email-already-in-use') message = 'Email đã tồn tại.';
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi hệ thống. Vui lòng thử lại!')),
      );
    }
  }
}