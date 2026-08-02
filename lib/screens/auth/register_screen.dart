import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';
import 'register_widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static final GlobalKey<RegisterFormState> _formKey = GlobalKey<RegisterFormState>();

  Future<void> _onRegister(BuildContext context, {
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
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
          'Tài khoản đã được đăng ký thành công!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.of(context).pop();

      String message = 'Đăng ký thất bại';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu (Tối thiểu 6 ký tự).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng cho tài khoản khác.';
      } else if (e.code == 'invalid-email') {
        message = 'Định dạng email không hợp lệ.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      print("Lỗi hệ thống đăng ký: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi hệ thống. Vui lòng thử lại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              children: [
                const RegisterHeader(),

                RegisterForm(key: _formKey),

                const SizedBox(height: 24),

                RegisterButton(
                  onPressed: () {
                    final formState = _formKey.currentState;
                    if (formState != null) {

                      final name = formState.nameText;
                      final email = formState.emailText;
                      final phone = formState.phoneText;
                      final password = formState.passwordText;

                      if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng điền đầy đủ tất cả các trường dữ liệu!')),
                        );
                        return;
                      }

                      _onRegister(
                        context,
                        email: email,
                        password: password,
                        name: name,
                        phone: phone,
                      );
                    }
                  },
                ),

                const RegisterFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}