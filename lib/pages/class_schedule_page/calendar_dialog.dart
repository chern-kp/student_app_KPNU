import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../class/course_class.dart';
import '../../class/event_class.dart';

//TODO edit
class CalendarDialog extends StatelessWidget {
  final DateTime selectedDate;
  final List<Course> courses;
  final List<EventSchedule> events;

  const CalendarDialog({
    Key? key,
    required this.selectedDate,
    required this.courses,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      title: const Text('Selected Date'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            for (var course in selectedCourses)
              ListTile(
                title: Text(course.nameField!),
                subtitle: Text(
                    'Record Book Selected Date: ${DateFormat.yMMMd().format(course.recordBookSelectedDateField!)}\nScoring Type: ${course.scoringTypeField!}'),
              ),
            for (var event in selectedEvents)
              ListTile(
                title: Text(event.eventName!),
                subtitle: Text(
                    'Event Type: ${event.eventType!}\nStart Date: ${DateFormat.yMMMd().format(event.eventDateStart!)}\nEnd Date: ${DateFormat.yMMMd().format(event.eventDateEnd!)}'),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
