// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';

class NewCourseDialog extends StatelessWidget {
  NewCourseDialog({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Course'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Content of the dialog'),
          TextField(
            decoration: InputDecoration(
              hintText: 'Course name',
            ),
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
            DatabaseService.createNewCourse(user.email);
          },
        ),
      ],
    );
  }
}
