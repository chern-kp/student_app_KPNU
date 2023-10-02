import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/home_page.dart';
import 'package:student_app/pages/login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //if user logged in he will be redirected to home page
          if (snapshot.hasData) {
            return HomePage();
          }
          //if user not logged
          return LoginOrRegisterPage();
        },
      ),
    );
  }
}
