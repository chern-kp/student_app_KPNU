// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/ClassSchedulePage/class_schedule_page.dart';
import 'courses_schedule_page.dart';
import 'personal_information_page.dart';
import 'record_book_page.dart';

import '../class/database_service.dart';
import '../components/my_dropdownmenu.dart';
import '../components/my_button.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  late Future<List<String>> facultyList =
      DatabaseService.getSemesterList(user.email);

  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  final user = FirebaseAuth.instance
      .currentUser!; //user here is the instance of class User from firebase auth package. To get the email address itself we use "user.email".

  void tempPersonalInfoPage(BuildContext context) {
    //todo delete - debug
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonalInformationPage()),
    );
  }

  void coursesSchedulePageButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CoursesSchedulePage()),
    );
  }

  void recordBookPageButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecordBookPage()),
    );
  }

  void classSchedulePageButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClassSchedulePage()),
    );
  }

  //sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(
          children: [
            Text(user.email!),
            SizedBox(height: 25),
            Text('Choose the current semester:'),
            MyDropdownMenu(
                listOfData: facultyList,
                chosenValueInDatabase: selectedSemester,
                chosenField: 'Current Semester'),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyButton(
                onTap: () => coursesSchedulePageButton(context),
                text: 'Індивідуальний Навчальний План',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyButton(
                onTap: () => recordBookPageButton(context),
                text: 'Залікова Книжка Студента',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyButton(
                onTap: () => classSchedulePageButton(context),
                text: 'Графік Освітнього Процесу',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
