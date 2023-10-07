// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/my_dropdownmenu.dart';

class CoursesSchedulePage extends StatelessWidget {
  CoursesSchedulePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);
  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('CoursesSchedulePage'),
        ),
        body: Container(
            child: Column(
          children: [
            //todo change the onChange
            MyDropdownMenu(
                listOfData: semesterList,
                chosenValueInDatabase: selectedSemester,
                chosenField: 'Current Semester'),
          ],
        )));
  }
}
