// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/class/database_data.dart';

import '../components/my_dropdownmenu_semeter.dart';

class NewCourseDialog extends StatefulWidget {
  NewCourseDialog({super.key});

  @override
  State<NewCourseDialog> createState() => _NewCourseDialogState();
}

class _NewCourseDialogState extends State<NewCourseDialog> {
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

  String? selectedSemesterPage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Course'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Content of the dialog'),
          MyDropdownMenuSemester(onSelectedItemChanged: (selectedItem) {
            setState(() {
              selectedSemesterPage = selectedItem;
            });
          }),
          TextField(
            // todo disallow user to create new course with the same name that exist
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
              controller: hoursPracticesFieldController,
              decoration: InputDecoration(
                hintText: 'Practice hours',
              )),
          TextField(
              controller: hoursLabsFieldController,
              decoration: InputDecoration(
                hintText: 'Lab hours',
              )),
          TextField(
              controller: hoursCourseworkFieldController,
              decoration: InputDecoration(
                hintText: 'Coursework hours',
              ))
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
            // here we get info to course instance...:
            Course course = Course(
              nameField: nameFieldController.text,
              hoursLectionsField:
                  int.tryParse(hoursLectionsFieldController.text) ?? 0,
              hoursPracticesField:
                  int.tryParse(hoursPracticesFieldController.text) ?? 0,
              hoursLabsField: int.tryParse(hoursLabsFieldController.text) ?? 0,
              hoursCourseworkField:
                  int.tryParse(hoursCourseworkFieldController.text) ?? 0,
              //todo error checks
            );
            // ...and here send it to database method:
            DatabaseService.createNewCourse(
                user.email, course, selectedSemesterPage!);
          },
        ),
      ],
    );
  }
}
