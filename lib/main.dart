// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import "firebase_options.dart";

import 'pages/auth/auth_page.dart';

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
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Color(0xFFbc653f), // Change this to your desired color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                Colors.brown), // Change this to your desired button color
          ),
        ),
      ),
    );
  }
}
