import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/components/my_texfield.dart';
import 'package:student_app/components/my_button.dart';
import 'package:student_app/class/database_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onTap});

  final Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //textField controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

// Sign user up method. Creating student firestore document called from here (the function itself - below)
  void signUserUp(BuildContext context) async {
    try {
      // check if passwords match with confirm password
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await DatabaseService.createStudentDocument(
            emailController.text); // in database_service class
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Паролі не збігаються!"),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Помилка реєстрації! Введіть коректні e-mail та пароль!"),
        ),
      );
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
                  const Text("Реєстрація",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: emailController,
                    hintText: "E-mail",
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                      controller: passwordController,
                      hintText: "Пароль",
                      obscureText: true),
                  const SizedBox(height: 25),
                  //confirm password
                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Підтвердіть пароль",
                      obscureText: true),
                  const SizedBox(height: 25),
                  //register button
                  MyButton(
                    onTap: () => signUserUp(context),
                    text: 'Зареєструватись',
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Увійти',
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
