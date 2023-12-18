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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await DatabaseService.createStudentDocument(emailController.text);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Паролі не збігаються!"),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Помилка! Користувач вже існує!';
          break;
        case 'invalid-email':
          errorMessage = 'Помилка! Неправельний e-mail!';
          break;
        default:
          errorMessage = 'Невідома помилка!';
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Невідома помилка!"),
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
                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Підтвердіть пароль",
                      obscureText: true),
                  const SizedBox(height: 25),
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
