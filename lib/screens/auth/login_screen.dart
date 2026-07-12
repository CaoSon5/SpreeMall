import 'package:flutter/material.dart';

import 'login_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                LoginHeader(),
                LoginForm(),
                SizedBox(height: 24),
                LoginButton(),
                SocialLogin(),
                LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}