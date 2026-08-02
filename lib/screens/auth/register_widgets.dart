import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

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
          'SpereeMall',
          style: AppTextStyles.heading1,
        ),

        const SizedBox(height: 8),

        Text(
          'Tạo tài khoản mới',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String get nameText => _nameController.text.trim();
  String get emailText => _emailController.text.trim();
  String get phoneText => _phoneController.text.trim();
  String get passwordText => _passwordController.text.trim();

  @override
  void dispose() {

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          hintText: 'Họ và tên',
          prefixIcon: Icons.person_outline,
        ),

        const SizedBox(height: 18),

        CustomTextField(
          controller: _emailController,
          hintText: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 18),

        CustomTextField(
          controller: _phoneController,
          hintText: 'Số điện thoại',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 18),

        CustomTextField(
          controller: _passwordController,
          hintText: 'Mật khẩu',
          prefixIcon: Icons.lock_outline,
          obscureText: _hidePassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _hidePassword = !_hidePassword;
              });
            },
            icon: Icon(
              _hidePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),

        const SizedBox(height: 18),

        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'Xác nhận mật khẩu',
          prefixIcon: Icons.lock_outline,
          obscureText: _hideConfirmPassword,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _hideConfirmPassword = !_hideConfirmPassword;
              });
            },
            icon: Icon(
              _hideConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Đăng ký',
      onPressed: onPressed,
    );
  }
}

class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đã có tài khoản?',
            style: AppTextStyles.bodySecondary,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.login,
              );
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}