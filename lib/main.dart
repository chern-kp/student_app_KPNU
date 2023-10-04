// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/auth_page.dart';

import "firebase_options.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //initialize flutter engine
  await Firebase.initializeApp(
    //initializes a connection between Flutter app and Firebase project
    options: DefaultFirebaseOptions
        .currentPlatform, //detects platform in firebase_options.dart file
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //turns off debug banner
      home: AuthPage(), //First page we are getting to after app was launched
    );
  }
}
