// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/my_texfield.dart';
import 'package:student_app/components/my_button.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key, required this.onTap});

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
        SnackBar(
          content: Text("Error! Wrong e-mail or password!"),
        ),
      );
    }
  }

  void checkDoesStudentDocumentExists() async {
    var user = emailController.text;
    if (await DatabaseService.checkStudentDocument(user)) {
      print("Document exists!");
    } else {
      print("Document does not exist, creating...");
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
                  SizedBox(height: 50),
                  MyTextField(
                    controller: emailController,
                    hintText: "E-mail",
                    obscureText: false,
                  ),
                  SizedBox(height: 50),
                  MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true),
                  SizedBox(height: 25),
                  //sign in button
                  MyButton(onTap: () => signUserIn(context), text: 'Login'),
                  SizedBox(height: 25),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Register New Account',
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
