// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_app/class/database_service.dart';
import '../class/course_class.dart';
import '../components/my_datepicker.dart';
import '../components/dropdownmenu_choose_semester.dart';

class NewCourseDialog extends StatefulWidget {
  NewCourseDialog({
    this.isEdit = false,
    this.isEditFilling = false,
    this.course,
    this.isRecordBook = false,
    this.filledNewRecordBook = false,
    this.filledCourseSchedule = false,
    this.currentSemester,
    Key? key,
  }) : super(key: key);

  bool isEdit;
  bool isEditFilling;
  bool isRecordBook;
  bool filledNewRecordBook;
  bool filledCourseSchedule;
  final Course? course;
  final String? currentSemester;

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
  final scoringTypeFieldController = TextEditingController();
  final recordBookTeacherFieldController = TextEditingController();
  final recordBookScoreFieldController = TextEditingController();

  DateTime? selectedDate;
  String? selectedSemesterPage;
  bool isEvent = false;

  @override
  void initState() {
    super.initState();
    selectedSemesterPage = widget.currentSemester;
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
      scoringTypeFieldController.text =
          widget.course!.scoringTypeField.toString();
      recordBookTeacherFieldController.text =
          widget.course!.recordBookTeacherField.toString();
      recordBookScoreFieldController.text =
          widget.course!.recordBookScoreField.toString();
      selectedDate = widget.course!.recordBookSelectedDateField;
      isEvent = widget.course!.isEvent ?? false;
    } else {
      scoringTypeFieldController.text = 'Екзамен';
    }
  }

  bool getIsScheduleFilled() {
    if (widget.isEdit == true && widget.isEditFilling == false) {
      return widget.filledCourseSchedule;
    } else {
      if (widget.isEdit == false && widget.isRecordBook == false) {
        return true;
      } else {
        return widget.filledCourseSchedule;
      }
    }
  }

  bool getIsRecordBookFilled() {
    if (widget.isEdit == true && widget.isEditFilling == true) {
      if (widget.isRecordBook == true) {
        return true;
      } else {
        return widget.filledNewRecordBook;
      }
    } else {
      if (widget.isEdit == false && widget.isRecordBook == true) {
        return true;
      } else {
        return widget.filledNewRecordBook;
      }
    }
  }

  TextButton _saveButton(BuildContext context) {
    return TextButton(
      child: Text('Save'),
      onPressed: () async {
        try {
          Course newCourse = Course(
            isScheduleFilled: getIsScheduleFilled(),
            isRecordBookFilled: getIsRecordBookFilled(),
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
            scoringTypeField: scoringTypeFieldController.text,
            recordBookTeacherField: recordBookTeacherFieldController.text,
            recordBookScoreField:
                int.tryParse(recordBookScoreFieldController.text) ?? 0,
            recordBookSelectedDateField: selectedDate,
            //If the date is default course always will save with isEvent = false.
            isEvent: selectedDate != null &&
                    !selectedDate!.isAtSameMomentAs(
                        DateTime.fromMillisecondsSinceEpoch(978307200000,
                            isUtc: true))
                ? isEvent
                : false,
          );
          if (widget.isEdit &&
              widget.course != null &&
              widget.course!.nameField != nameFieldController.text) {
            await DatabaseService.deleteCourse(
                user.email!, widget.course!.nameField!);
          }
          await DatabaseService.createOrUpdateCourse(
              user.email, newCourse, selectedSemesterPage!);
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

  Widget _coursesScheduleFields() {
    return Column(
      children: <Widget>[
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
      ],
    );
  }

  Widget _recordBookFields() {
    return Column(children: <Widget>[
      TextField(
          controller: recordBookTeacherFieldController,
          decoration: InputDecoration(
            labelText: 'Teacher',
          )),
      TextField(
          controller: recordBookScoreFieldController,
          decoration: InputDecoration(
            labelText: 'Score',
          )),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              DateTime? date = await selectDate(context);
              setState(() {
                selectedDate = date;
              });
            },
            child: Text('Select date'),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                selectedDate = DateTime.fromMillisecondsSinceEpoch(978307200000,
                    isUtc: true);
              });
            },
          ),
        ],
      ),
      //display date in "YYYY-MM-DD HH:MM" format
      Text(selectedDate != null &&
              !selectedDate!.isAtSameMomentAs(
                  DateTime.fromMillisecondsSinceEpoch(978307200000,
                      isUtc: true))
          ? '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}'
          : ''),
      CheckboxListTile(
        title: Text("Is Event"),
        value: isEvent,
        onChanged: selectedDate != null &&
                !selectedDate!.isAtSameMomentAs(
                    DateTime.fromMillisecondsSinceEpoch(978307200000,
                        isUtc: true))
            ? (newValue) {
                setState(() {
                  isEvent = newValue!;
                });
              }
            : null,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Додати '),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Content of the dialog'),
            Visibility(
              visible: !widget.isEdit,
              child: DropdownMenuChooseSemester(
                initialSemester: widget.currentSemester,
                onSelectedItemChanged: (selectedItem) {
                  setState(() {
                    selectedSemesterPage = selectedItem;
                  });
                },
              ),
            ),
            TextField(
              controller: nameFieldController,
              decoration: InputDecoration(
                labelText: 'Course name',
              ),
            ),
            Visibility(
              visible: !widget.isRecordBook,
              child: _coursesScheduleFields(),
            ),
            DropdownButton<String>(
              value: scoringTypeFieldController.text.isEmpty
                  ? null
                  : scoringTypeFieldController.text,
              onChanged: (String? newValue) {
                setState(() {
                  scoringTypeFieldController.text = newValue!;
                });
              },
              items: <String>['Екзамен', 'Залік', 'Інше']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Visibility(
              visible: widget.isRecordBook,
              child: _recordBookFields(),
            ),
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
        _saveButton(context),
      ],
    );
  }
}
