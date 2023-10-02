// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/personal_information_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance
      .currentUser!; //user here is the instance of class User from firebase auth package. To get the email address itself we use "user.email".

  void tempPersonalInfoPage(BuildContext context) {
    //todo delete - debug
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonalInformationPage()),
    );
  }

  //sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(
          children: [
            Text(user.email!),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => tempPersonalInfoPage(context),
              child: Text('tempPersonalInfoPage'),
            ),
          ],
        ),
      ),
    );
  }
}
