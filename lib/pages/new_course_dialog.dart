// ignore_for_file: must_be_immutable, use_build_context_synchronously

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
    this.isRecordBook = false,
    this.filledNewRecordBook = false,
    this.filledCourseSchedule = false,
    this.course,
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
      child: const Text(
        'Зберегти',
        style: TextStyle(color: Colors.brown),
      ),
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
          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Помилка'),
                content: Text(e.toString()),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'Закрити',
                      style: TextStyle(color: Colors.brown),
                    ),
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
          decoration: const InputDecoration(
            labelText: 'Лекції (год.)',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ),
        TextField(
          controller: hoursPracticesFieldController,
          decoration: const InputDecoration(
            labelText: 'Практичні/Семінарські (год.)',
          ),
        ),
        TextField(
          controller: hoursLabsFieldController,
          decoration: const InputDecoration(
            labelText: 'Лабораторні (год.)',
          ),
        ),
        TextField(
          controller: hoursCourseworkFieldController,
          decoration: const InputDecoration(
            labelText: 'Курсові (год.)',
          ),
        ),
        TextField(
          controller: hoursIndividualTotalFieldController,
          decoration: const InputDecoration(
            labelText: 'Самостійна робота студента',
          ),
        ),
      ],
    );
  }

  Widget _recordBookFields() {
    return Column(children: <Widget>[
      TextField(
          controller: recordBookTeacherFieldController,
          decoration: const InputDecoration(
            labelText: 'Викладач',
          )),
      TextField(
          controller: recordBookScoreFieldController,
          decoration: const InputDecoration(
            labelText: 'Оцінка',
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
            child: const Text('Обрати дату'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
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
        title: const Text("Додати як подію?"),
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.isEdit
                ? 'Змінити освітній елемент'
                : 'Додати новий освітній елемент'),
            const SizedBox(height: 5),
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
              decoration: const InputDecoration(
                labelText: 'Назва освітнього елементу',
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
          child: const Text(
            'Закрити',
            style: TextStyle(color: Colors.brown),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        _saveButton(context),
      ],
    );
  }
}
