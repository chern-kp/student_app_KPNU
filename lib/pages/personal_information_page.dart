// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/components/my_button.dart';
import 'package:student_app/components/my_dropdownmenu.dart';
import 'package:student_app/components/my_texfield.dart';
import 'package:student_app/class/database_service.dart';

void main() {
  runApp(PersonalInformationPage());
}

class PersonalInformationPage extends StatefulWidget {
  PersonalInformationPage({Key? key}) : super(key: key);

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final user = FirebaseAuth.instance
      .currentUser!; //user here is the instance of class User from firebase auth package. To get the email address itself we use "user.email".

  //textField controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  //dropdown menu controllers
  late Future<String> selectedFaculty = DatabaseService.getStudentFaculty(user
      .email); //we are using keyword "late" here because we firstly have to wait for code to get async value "user"
  final Future<List<String>> facultyList = DatabaseService.getFacultyList();

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
            MyButton(onTap: sendInformation, text: 'Send information'),
            SizedBox(height: 25),
            MyDropdownMenu(
              facultyList: facultyList,
              selectedFaculty: selectedFaculty,
            ),
          ],
        ),
      ),
    );
  }
}
