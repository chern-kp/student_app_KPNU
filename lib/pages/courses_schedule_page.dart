// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/my_dropdownmenu.dart';

import 'new_course_dialog.dart';

class CoursesSchedulePage extends StatelessWidget {
  CoursesSchedulePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);
  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  Widget _addNewCourseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog();
          },
        );
      },
      child: Text("Add New Course"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('CoursesSchedulePage'),
        ),
        body: Container(
            child: Center(
          child: Column(
            children: [
              //todo change the onChange
              MyDropdownMenu(
                  listOfData: semesterList,
                  chosenValueInDatabase: selectedSemester,
                  chosenField: 'Current Semester'),
              SizedBox(height: 25),
              _addNewCourseButton(context),
            ],
          ),
        )));
  }
}
