// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/components/my_texfield.dart';
import 'package:student_app/components/my_button.dart';
import 'package:student_app/class/database_service.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key, required this.onTap});

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
          SnackBar(
            content: Text("Passwords do not match!"),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration error! Write valid e-mail and password!"),
        ),
      );
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration error! Write valid e-mail and password!"),
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
                  SizedBox(height: 50),
                  MyTextField(
                    controller: emailController,
                    hintText: "E-mail",
                    obscureText: false,
                  ),
                  SizedBox(height: 25),
                  MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true),
                  SizedBox(height: 25),
                  //confirm password
                  MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true),
                  SizedBox(height: 25),
                  //register button
                  MyButton(onTap: () => signUserUp(context), text: 'Sign Up'),
                  SizedBox(height: 25),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Log In Now',
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
