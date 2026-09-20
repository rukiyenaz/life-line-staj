import 'package:flutter/material.dart';
import 'package:life_line/features/auth/presentation/pages/signin_page.dart';
import 'package:life_line/features/auth/presentation/pages/signup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isSignIn = true;

  void toggleAuthMode() {
    setState(() {
      isSignIn = !isSignIn;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isSignIn) {
      return SigninPage(onToggle: toggleAuthMode);
    } else {
      return SignupPage(onToggle: toggleAuthMode);
    }
  }
}