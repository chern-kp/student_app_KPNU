import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/components/my_button.dart';
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
  List<String> faculty = ['Fizmat', 'History', 'Economy'];

  String? selectedFaculty;
  late final tempTestString = DatabaseService.getStudentFaculty(user.email);

  Widget _tempTestButton() {
    return ElevatedButton(
        onPressed: () {
          print(tempTestString);
        },
        child: Text('test'));
  }

  Future sendInformation() async {
    await FirebaseFirestore.instance.collection("student").doc(user.email).set({
      "FirstName": firstNameController.text,
      "LastName": lastNameController.text
    }, SetOptions(merge: true));
  }

  Widget _facultyDropdownMenu() {
    return DropdownButton<String>(
      value: selectedFaculty,
      hint: Text(selectedFaculty ?? 'Select Faculty'),
      onChanged: (String? newValue) {
        //when a new value is selected dropdown menu widget gets rebuilt
        setState(() {
          selectedFaculty = newValue;
        });
      },
      items: faculty.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
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
            _facultyDropdownMenu(),
            _tempTestButton()
          ],
        ),
      ),
    );
  }
}
