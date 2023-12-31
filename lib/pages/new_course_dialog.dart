// ignore_for_file: use_build_context_synchronously, must_be_immutable

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
    this.isClassSchedule = false,
    this.course,
    this.currentSemester,
    Key? key,
  }) : super(key: key);

  final Course? course;
  final String? currentSemester;
  bool filledCourseSchedule;
  bool filledNewRecordBook;
  bool isClassSchedule;
  bool isEdit;
  bool isEditFilling;
  bool isRecordBook;

  @override
  State<NewCourseDialog> createState() => _NewCourseDialogState();
}

class _NewCourseDialogState extends State<NewCourseDialog> {
  final creditsOverallTotalFieldController = TextEditingController();
  final hoursCourseworkFieldController = TextEditingController();
  final hoursInClassTotalFieldController = TextEditingController();
  final hoursIndividualTotalFieldController = TextEditingController();
  final hoursLabsFieldController = TextEditingController();
  final hoursLectionsFieldController = TextEditingController();
  final hoursOverallTotalFieldController = TextEditingController();
  final hoursPracticesFieldController = TextEditingController();
  bool isEvent = false;
  final nameFieldController = TextEditingController();
  final recordBookScoreFieldController = TextEditingController();
  final recordBookTeacherFieldController = TextEditingController();
  final scoringTypeFieldController = TextEditingController();
  DateTime? selectedDate;
  String? selectedSemesterPage;
  final user = FirebaseAuth.instance.currentUser!;

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
      if (widget.isEdit == false &&
          widget.isRecordBook == false &&
          widget.isClassSchedule == false) {
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
      if (widget.isEdit == false &&
          widget.isRecordBook == true &&
          widget.isClassSchedule == false) {
        return true;
      } else {
        return widget.filledNewRecordBook;
      }
    }
  }

  bool getIsEvent() {
    if (!widget.isEdit && widget.isClassSchedule) {
      return true;
    } else if (selectedDate != null &&
        !selectedDate!.isAtSameMomentAs(
            DateTime.fromMillisecondsSinceEpoch(978307200000, isUtc: true))) {
      return isEvent;
    } else {
      return false;
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
            isEvent: getIsEvent(),
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
        SizedBox(
          width: 250,
          child: TextField(
            controller: hoursLectionsFieldController,
            decoration: const InputDecoration(
              labelText: 'Лекції (год.)',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: hoursPracticesFieldController,
            decoration: const InputDecoration(
              labelText: 'Практичні/Семінарські (год.)',
            ),
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: hoursLabsFieldController,
            decoration: const InputDecoration(
              labelText: 'Лабораторні (год.)',
            ),
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: hoursCourseworkFieldController,
            decoration: const InputDecoration(
              labelText: 'Курсові (год.)',
            ),
          ),
        ),
        SizedBox(
          width: 250,
          child: TextField(
            controller: hoursIndividualTotalFieldController,
            decoration: const InputDecoration(
              labelText: 'Самостійна робота студента',
            ),
          ),
        ),
      ],
    );
  }

  Widget _recordBookFields() {
    return Column(children: <Widget>[
      SizedBox(
        width: 250,
        child: TextField(
          controller: recordBookTeacherFieldController,
          decoration: const InputDecoration(
            labelText: 'Викладач',
          ),
        ),
      ),
      SizedBox(
        width: 250,
        child: TextField(
          controller: recordBookScoreFieldController,
          decoration: const InputDecoration(
            labelText: 'Оцінка',
          ),
        ),
      ),
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
                ? 'Змінити освіtній елемент'
                : 'Додати новий освіtній елемент'),
            const SizedBox(height: 5),
            if (!widget.isEdit) ...[
              DropdownMenuChooseSemester(
                initialSemester: widget.currentSemester,
                onSelectedItemChanged: (selectedItem) {
                  setState(() {
                    selectedSemesterPage = selectedItem;
                  });
                },
              ),
            ],
            SizedBox(
              width: 250,
              child: TextField(
                controller: nameFieldController,
                decoration: const InputDecoration(
                  labelText: 'Назва освітнього елементу',
                ),
              ),
            ),
            if (!widget.isClassSchedule) ...[
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
            if (widget.isClassSchedule) ...[
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
                        selectedDate = DateTime.fromMillisecondsSinceEpoch(
                            978307200000,
                            isUtc: true);
                      });
                    },
                  ),
                ],
              ),
              Text(selectedDate != null &&
                      !selectedDate!.isAtSameMomentAs(
                          DateTime.fromMillisecondsSinceEpoch(978307200000,
                              isUtc: true))
                  ? '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')} ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}'
                  : ''),
            ],
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
