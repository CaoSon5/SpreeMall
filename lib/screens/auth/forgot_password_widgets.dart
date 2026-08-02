import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

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
            Icons.lock_reset_rounded,
            color: Colors.white,
            size: 48,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Quên mật khẩu?',
          style: AppTextStyles.heading1,
        ),

        const SizedBox(height: 8),

        Text(
          'Nhập email đã đăng ký, chúng tôi sẽ gửi\nhướng dẫn đặt lại mật khẩu cho bạn',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  final TextEditingController controller;

  const ForgotPasswordForm({
    super.key,
    required this.controller,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      hintText: 'Email hoặc số điện thoại',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
    );
  }
}

class ForgotPasswordButton extends StatefulWidget {
  final TextEditingController controller;

  const ForgotPasswordButton({
    super.key,
    required this.controller,
  });

  @override
  State<ForgotPasswordButton> createState() => _ForgotPasswordButtonState();
}

class _ForgotPasswordButtonState extends State<ForgotPasswordButton> {
  bool _isLoading = false;
  bool _sent = false;

  Future<void> _handleSubmit() async {
    final value = widget.controller.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập email hoặc số điện thoại'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _sent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gửi hướng dẫn đặt lại mật khẩu tới "$value" (Mock)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: _sent ? 'Gửi lại yêu cầu' : 'Gửi yêu cầu',
          isLoading: _isLoading,
          onPressed: _handleSubmit,
        ),

        if (_sent) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Yêu cầu đã được gửi. Vui lòng kiểm tra email của bạn.',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class ForgotPasswordFooter extends StatelessWidget {
  const ForgotPasswordFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đã nhớ mật khẩu?',
            style: AppTextStyles.bodySecondary,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại đăng nhập'),
          ),
        ],
      ),
    );
  }
}
