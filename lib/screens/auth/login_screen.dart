import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';
import 'login_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // 🆕 Tạo một GlobalKey để đứng từ LoginScreen truy cập dữ liệu bên trong LoginForm
  static final GlobalKey<LoginFormState> _formKey = GlobalKey<LoginFormState>();

  // Hàm xử lý nạp dữ liệu User động khi Đăng Nhập thành công
  Future<void> _onLoginSuccess(BuildContext context, String uid, String email) async {
    try {
      // 1. Lấy dữ liệu profile thật từ Firestore collection 'users' dựa theo UID
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        
        // 2. Cập nhật dữ liệu thật vào Profile Controller để kích hoạt thay đổi UI
        // Sửa lại thành phương thức updateProfile tương thích với Controller của bạn
        UserProfileController.instance.update(
          name: data['name'] ?? 'Người dùng SpreeMall',
          email: email,
          phone: data['phone'] ?? '',
          gender: data['gender'] ?? 'Nam',
          birthday: data['birthday'] ?? '',
        );
      } else {
        // Trường hợp tài khoản có trên Auth nhưng chưa tạo doc dưới Firestore
        UserProfileController.instance.update(
          name: 'Tài khoản mới',
          email: email,
        );
      }

      // 3. Chuyển hướng vào màn hình chính (Home/Dashboard) sau khi đã nạp xong data
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed(AppRoutes.home); 

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
                
                // 🆕 Truyền key vào LoginForm để LoginButton bên dưới có thể trích xuất dữ liệu nhập vào
                LoginForm(key: _formKey),
                
                const SizedBox(height: 24),
                
                // Nút LoginButton nhận hàm callback khi xác thực thành công
                LoginButton(
                  onPressed: () async {
                    // Lấy trạng thái form hiện tại
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

                      // --- LOGIC XÁC THỰC FIREBASE CHẠY THẬT ---
                      try {
                        // Hiển thị vòng tròn loading trong lúc chờ Firebase phản hồi
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );

                        // Thực hiện đăng nhập bằng Firebase Auth
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        // Tắt vòng tròn loading khi có kết quả
                        if (context.mounted) Navigator.of(context).pop();

                        if (credential.user != null) {
                          // Đồng bộ dữ liệu từ Firestore và chuyển vào Home
                          await _onLoginSuccess(
                            context, 
                            credential.user!.uid, 
                            credential.user!.email ?? email,
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        // Tắt vòng tròn loading nếu lỗi
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
                        // Tắt vòng tròn loading nếu lỗi hệ thống khác
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