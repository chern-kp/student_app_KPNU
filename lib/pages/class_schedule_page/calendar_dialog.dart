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
      title: Text(
          'Події для дати: ${DateFormat('dd.MM.yyyy').format(selectedDate)}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            for (var course in selectedCourses)
              _buildListItemDesign(
                course.nameField!,
                'Дата і час: ${DateFormat('yyyy-MM-dd HH:mm').format(course.recordBookSelectedDateField!)}\nТип: ${course.scoringTypeField!}',
              ),
            for (var event in selectedEvents)
              _buildListItemDesign(
                event.eventName!,
                'Тип: ${event.eventType!}\nДата і час початку: ${DateFormat('yyyy-MM-dd HH:mm').format(event.eventDateStart!)}\nДата і час кінця: ${DateFormat('yyyy-MM-dd HH:mm').format(event.eventDateEnd!)}',
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

  Widget _buildListItemDesign(String title, String subtitle) {
    BorderRadius borderRadius = BorderRadius.circular(8.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        elevation: 5.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[700]!,
              width: 2,
            ),
            borderRadius: borderRadius,
          ),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
          ),
        ),
      ),
    );
  }
}
