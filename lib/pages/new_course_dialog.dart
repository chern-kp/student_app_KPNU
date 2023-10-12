// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/class/database_data.dart';

class NewCourseDialog extends StatelessWidget {
  NewCourseDialog({super.key});

  final user = FirebaseAuth.instance.currentUser!;
  final nameFieldController = TextEditingController();
  final semesterFieldController = TextEditingController();
  final hoursLectionsFieldController = TextEditingController();
  final hoursPracticesFieldController = TextEditingController();
  final hoursLabsFieldController = TextEditingController();
  final hoursCourseworkFieldController = TextEditingController();
  final hoursInClassTotalFieldController = TextEditingController();
  final hoursIndividualTotalFieldController = TextEditingController();
  final hoursOverallTotalFieldController = TextEditingController();
  final creditsOverallTotalFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Course'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Content of the dialog'),
          TextField(
            controller: nameFieldController,
            decoration: InputDecoration(
              hintText: 'Course name',
            ),
          ),
          TextField(
            controller: hoursLectionsFieldController,
            decoration: InputDecoration(
              hintText: 'Lection hours',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Course...',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            Course course = Course(
              nameField: nameFieldController.text,
              hoursLectionsField: int.parse(
                  hoursLectionsFieldController.text), //todo error checks
            );
            DatabaseService.createNewCourse(user.email, course);
          },
        ),
      ],
    );
  }
}
