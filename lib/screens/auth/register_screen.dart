import 'package:flutter/material.dart';

import 'register_widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              children: [
                RegisterHeader(),

                RegisterForm(),

                SizedBox(height: 24),

                RegisterButton(),

                RegisterFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}