import 'package:flutter/material.dart';

import 'forgot_password_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                const ForgotPasswordHeader(),
                ForgotPasswordForm(controller: _controller),
                const SizedBox(height: 24),
                ForgotPasswordButton(controller: _controller),
                const ForgotPasswordFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
