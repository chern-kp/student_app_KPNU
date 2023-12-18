import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../class/course_class.dart';
import '../../class/event_class.dart';
import 'class_list_view_builder.dart';

class CalendarDialog extends StatelessWidget {
  final DateTime selectedDate;
  final List<Course> courses;
  final List<EventSchedule> events;
  final String? selectedSemester;

  const CalendarDialog({
    Key? key,
    required this.selectedDate,
    required this.courses,
    required this.events,
    this.selectedSemester,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    List<Course> selectedCourses = courses.where((course) {
      return course.recordBookSelectedDateField!.day == selectedDate.day &&
          course.recordBookSelectedDateField!.month == selectedDate.month &&
          course.recordBookSelectedDateField!.year == selectedDate.year &&
          course.isEvent == true;
    }).toList();

    List<EventSchedule> selectedEvents = events.where((event) {
      return (event.eventDateStart!.day == selectedDate.day &&
              event.eventDateStart!.month == selectedDate.month &&
              event.eventDateStart!.year == selectedDate.year) ||
          (event.eventDateEnd!.day == selectedDate.day &&
              event.eventDateEnd!.month == selectedDate.month &&
              event.eventDateEnd!.year == selectedDate.year);
    }).toList();

    return AlertDialog(
      title: Text(
          'Події для дати: ${DateFormat('dd.MM.yyyy').format(selectedDate)}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            ClassListView(
              combinedList: [...selectedCourses, ...selectedEvents],
              updateState: () {},
              user: user,
              selectedSemester: selectedSemester,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Зберегти', style: TextStyle(color: Colors.brown)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
