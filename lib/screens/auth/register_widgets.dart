import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// ===============================
/// REGISTER HEADER
/// ===============================
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

/// ===============================
/// REGISTER FORM
/// ===============================
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        CustomTextField(
          hintText: 'Họ và tên',
          prefixIcon: Icons.person_outline,
        ),

        const SizedBox(height: 18),

        CustomTextField(
          hintText: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 18),

        CustomTextField(
          hintText: 'Số điện thoại',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 18),

        CustomTextField(
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

/// ===============================
/// REGISTER BUTTON
/// ===============================
class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Đăng ký',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công (Mock)!'),
          ),
        );

        Navigator.pop(context);
      },
    );
  }
}

/// ===============================
/// REGISTER FOOTER
/// ===============================
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