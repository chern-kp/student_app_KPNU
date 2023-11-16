// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/class/database_service.dart';

import '../class/course_class.dart';
import '../components/my_dropdownmenu_semeter.dart';

class NewCourseDialog extends StatefulWidget {
  NewCourseDialog({super.key, this.isEdit = false, this.course});
  bool isEdit;
  final Course? course;

  @override
  State<NewCourseDialog> createState() => _NewCourseDialogState();
}

class _NewCourseDialogState extends State<NewCourseDialog> {
  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.course != null) {
      nameFieldController.text = widget.course!.nameField ?? '';
      hoursLectionsFieldController.text =
          widget.course!.hoursLectionsField.toString();
      hoursPracticesFieldController.text =
          widget.course!.hoursPracticesField.toString();
      hoursLabsFieldController.text = widget.course!.hoursLabsField.toString();
      hoursCourseworkFieldController.text =
          widget.course!.hoursCourseworkField.toString();
      hoursInClassTotalFieldController.text =
          widget.course!.hoursInClassTotalField.toString();
      hoursIndividualTotalFieldController.text =
          widget.course!.hoursIndividualTotalField.toString();
      hoursOverallTotalFieldController.text =
          widget.course!.hoursOverallTotalField.toString();
      creditsOverallTotalFieldController.text =
          widget.course!.creditsOverallTotalField.toString();
      scoringTypeController.text = widget.course!.scoringTypeField.toString();
    }
  }

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
  final scoringTypeController = TextEditingController();

  String? selectedSemesterPage;
  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  TextButton saveButton(BuildContext context) {
    return TextButton(
      child: Text('Save'),
      onPressed: () async {
        try {
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
            hoursIndividualTotalField:
                int.tryParse(hoursIndividualTotalFieldController.text) ?? 0,
            scoringTypeField: scoringTypeController.text,
            //todo error checks
          );
          // ...and here send it to database method:
          if (widget.isEdit && widget.course != null) {
            await DatabaseService.createOrUpdateCourse(
                user.email,
                course,
                selectedSemesterPage == null
                    ? await selectedSemester
                    : selectedSemesterPage!);
          } else {
            await DatabaseService.createOrUpdateCourse(
                user.email,
                course,
                selectedSemesterPage == null
                    ? await selectedSemester
                    : selectedSemesterPage!);
          }
          Navigator.of(context).pop(true);
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(e.toString()),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Course'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Content of the dialog'),
            Visibility(
              visible: !widget.isEdit,
              child:
                  MyDropdownMenuSemester(onSelectedItemChanged: (selectedItem) {
                setState(() {
                  selectedSemesterPage = selectedItem;
                });
              }),
            ),
            TextField(
              controller: nameFieldController,
              decoration: InputDecoration(
                labelText: 'Course name',
              ),
            ),
            TextField(
              controller: hoursLectionsFieldController,
              decoration: InputDecoration(
                labelText: 'Lection hours',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            TextField(
              controller: hoursPracticesFieldController,
              decoration: InputDecoration(
                labelText: 'Practice hours',
              ),
            ),
            TextField(
              controller: hoursLabsFieldController,
              decoration: InputDecoration(
                labelText: 'Lab hours',
              ),
            ),
            TextField(
              controller: hoursCourseworkFieldController,
              decoration: InputDecoration(
                labelText: 'Coursework hours',
              ),
            ),
            TextField(
              controller: hoursIndividualTotalFieldController,
              decoration: InputDecoration(
                labelText: 'Individual total hours',
              ),
            ),
            TextField(
                controller: scoringTypeController,
                decoration: InputDecoration(
                  labelText: 'Scoring type',
                ))
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        saveButton(context),
      ],
    );
  }
}
