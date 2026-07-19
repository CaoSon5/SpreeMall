import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';
import 'register_widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  // 🆕 Tạo GlobalKey để đứng từ ngoài RegisterScreen truy cập dữ liệu bên trong RegisterForm
  static final GlobalKey<RegisterFormState> _formKey = GlobalKey<RegisterFormState>();

  // 🆕 Hàm xử lý logic Đăng ký tài khoản trực tiếp lên Firebase Auth & Firestore
  Future<void> _onRegister(BuildContext context, {
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Hiển thị vòng tròn Loading để người dùng không bấm lung tung khi đang tạo dữ liệu
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Tạo tài khoản đăng nhập trên Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Tự động lưu thông tin cá nhân bổ sung xuống Cloud Firestore collection 'users'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          'uid': firebaseUser.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'gender': 'Nam', // Mặc định khi đăng ký mới
          'birthday': '',   // Mặc định khi đăng ký mới
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. Đồng bộ ngay vào Profile Controller nội bộ để hiển thị trên giao diện ProfileScreen
        UserProfileController.instance.update(
          name: name,
          email: email,
          phone: phone,
          gender: 'Nam',
          birthday: '',
        );

        // Đóng hộp thoại Loading
        if (context.mounted) Navigator.of(context).pop();

        // Hiện thông báo chào mừng
        Get.snackbar(
          'Thành công',
          'Tài khoản đã được đăng ký thành công!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        // 4. Đưa thẳng người dùng vào màn hình chính (Home)
        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Đóng Loading
      
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
      if (context.mounted) Navigator.of(context).pop(); // Đóng Loading
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

                // 🆕 Gán key vào Form để tí nữa Button lôi dữ liệu ra
                RegisterForm(key: _formKey),

                const SizedBox(height: 24),

                // 🆕 Truyền hành động bấm nút Đăng ký vào RegisterButton
                RegisterButton(
                  onPressed: () {
                    final formState = _formKey.currentState;
                    if (formState != null) {
                      // Trích xuất chuỗi chữ nhập từ các ô TextField bên trong Form
                      final name = formState.nameText;
                      final email = formState.emailText;
                      final phone = formState.phoneText;
                      final password = formState.passwordText;

                      // Kiểm tra cơ bản xem điền đủ thông tin chưa trước khi bắn lên Firebase
                      if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng điền đầy đủ tất cả các trường dữ liệu!')),
                        );
                        return;
                      }

                      // Kích hoạt hàm xử lý đăng ký thật
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