import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/my_texfield.dart';
import 'package:student_app/components/my_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onTap});

  final Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //textField controllers
  final passwordController = TextEditingController();

  final emailController = TextEditingController();

// sign user in method
  void signUserIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      checkDoesStudentDocumentExists();
    } catch (error) {
      // Display error message
      print(error);
      // Show a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Помилка! Неправельний логін або пароль!"),
        ),
      );
    }
  }

  void checkDoesStudentDocumentExists() async {
    var user = emailController.text;
    if (await DatabaseService.checkStudentDocument(user)) {
    } else {
      await DatabaseService.createStudentDocument(
          user); //in database_service class
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text("Вхід",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: emailController,
                    hintText: "E-mail",
                    obscureText: false,
                  ),
                  const SizedBox(height: 50),
                  MyTextField(
                      controller: passwordController,
                      hintText: "Пароль",
                      obscureText: true),
                  const SizedBox(height: 25),
                  //sign in button
                  MyButton(onTap: () => signUserIn(context), text: 'Увійти'),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Створити новий аккаунт',
                      style: TextStyle(color: Colors.blue[800], fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
