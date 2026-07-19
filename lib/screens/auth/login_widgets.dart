import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../controllers/profile_controller.dart'; // 🆕 IMPORT CONTROLLER CỦA BẠN
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'SpreeMall',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 8),
        Text(
          'Chào mừng bạn quay trở lại',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để tiếp tục mua sắm',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

/// ===============================
/// LOGIN FORM (Cập nhật để expose dữ liệu ra ngoài qua Key)
/// ===============================
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState(); // Đổi từ _LoginFormState thành LoginFormState (xóa dấu gạch dưới)
}

class LoginFormState extends State<LoginForm> { // Xóa dấu gạch dưới để public class
  bool _obscurePassword = true;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 🆕 Dùng getter để LoginScreen bên ngoài có thể lấy text
  String get emailText => _emailController.text.trim();
  String get passwordText => _passwordController.text.trim();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: 'Email hoặc số điện thoại',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Mật khẩu',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Get.toNamed(AppRoutes.forgotPassword);
            },
            child: const Text("Quên mật khẩu?"),
          ),
        ),
      ],
    );
  }
}

/// ===============================
/// LOGIN BUTTON (Nhận sự kiện onPressed trực tiếp từ Screen)
/// ===============================
class LoginButton extends StatelessWidget {
  final VoidCallback onPressed; // 🆕 Thay đổi nhận sự kiện bấm từ bên ngoài

  const LoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Đăng nhập',
      onPressed: onPressed,
    );
  }
}

/// ===============================
/// SOCIAL LOGIN
/// ===============================
class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Hoặc',
                style: AppTextStyles.bodySecondary,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              // 🆕 Logic Đăng nhập bằng Google tương lai
              // Sau khi đăng nhập thành công, bạn cũng gọi:
              // UserProfileController.instance.updateProfile(name: googleName, email: googleEmail);
            },
            icon: const Icon(
              Icons.g_mobiledata,
              size: 34,
            ),
            label: const Text(
              'Đăng nhập với Google',
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================
/// LOGIN FOOTER
/// ===============================
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chưa có tài khoản?',
            style: AppTextStyles.bodySecondary,
          ),
          TextButton(
            onPressed: () {
              Get.toNamed(AppRoutes.register);
            },
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }
}