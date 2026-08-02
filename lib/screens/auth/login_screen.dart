import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spreemall/models/user_role.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/role_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../routes/app_routes.dart';
import 'login_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static final GlobalKey<LoginFormState> _formKey = GlobalKey<LoginFormState>();

  Future<void> _onLoginSuccess(BuildContext context, String uid, String email) async {
    try {

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;

        UserProfileController.instance.update(
          name: data['name'] ?? 'Người dùng SpreeMall',
          email: email,
          phone: data['phone'] ?? '',
          gender: data['gender'] ?? 'Nam',
          birthday: data['birthday'] ?? '',
        );
      } else {

        UserProfileController.instance.update(
          name: 'Tài khoản mới',
          email: email,
        );
      }

      final role = await RoleController.instance.fetchRole(uid);

      await CartController.instance.loadCart(uid);

      if (!context.mounted) return;
      if (role.isAdmin) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }

    } catch (e) {
      print("Lỗi khi đồng bộ dữ liệu Profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải thông tin cá nhân. Vui lòng thử lại!')),
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
                const LoginHeader(),

                LoginForm(key: _formKey),

                const SizedBox(height: 24),

                LoginButton(
                  onPressed: () async {

                    final formState = _formKey.currentState;
                    if (formState != null) {
                      final email = formState.emailText;
                      final password = formState.passwordText;

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đầy đủ email và mật khẩu')),
                        );
                        return;
                      }

                      try {

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        if (context.mounted) Navigator.of(context).pop();

                        if (credential.user != null) {

                          await _onLoginSuccess(
                            context,
                            credential.user!.uid,
                            credential.user!.email ?? email,
                          );
                        }
                      } on FirebaseAuthException catch (e) {

                        if (context.mounted) Navigator.of(context).pop();

                        String message = 'Đăng nhập thất bại';
                        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
                          message = 'Tài khoản hoặc mật khẩu không chính xác.';
                        } else if (e.code == 'invalid-email') {
                          message = 'Định dạng email không hợp lệ.';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      } catch (e) {

                        if (context.mounted) Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xảy ra lỗi hệ thống. Vui lòng thử lại!')),
                        );
                      }
                    }
                  },
                ),

                const SocialLogin(),
                const LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }}