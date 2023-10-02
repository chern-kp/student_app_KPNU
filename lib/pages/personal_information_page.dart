import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/components/my_button.dart';
import 'package:student_app/components/my_texfield.dart';

void main() {
  runApp(PersonalInformationPage());
}

class PersonalInformationPage extends StatelessWidget {
  PersonalInformationPage({Key? key}) : super(key: key);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  //textField controllers
  final user = FirebaseAuth.instance.currentUser!;

  Future sendInformation() async {
    await FirebaseFirestore.instance.collection("student").doc(user.email).set({
      "FirstName": firstNameController.text,
      "LastName": lastNameController.text
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 25),
            Text("Your first name:"),
            MyTextField(controller: firstNameController),
            SizedBox(height: 25),
            Text("Your last name:"),
            MyTextField(controller: lastNameController),
            SizedBox(height: 25),
            MyButton(onTap: sendInformation, text: 'Send information'),
          ],
        ),
      ),
    );
  }
}
