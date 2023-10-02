import 'package:flutter/material.dart';
import 'package:student_app/pages/login_page.dart';
import 'package:student_app/pages/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  // firstly show login page
  bool showLoginPage = true;

  //toggle between login and register page
  void toggleScreens() {
    setState(() {
      showLoginPage =
          !showLoginPage; //makes login page bool the opposite of what it was
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: toggleScreens,
      );
    } else {
      return RegisterPage(onTap: toggleScreens);
    }
  }
}
