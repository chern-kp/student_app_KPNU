import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_app/class/course_class.dart';

class MyCalendar extends StatefulWidget {
  final List<Course> courses;

  MyCalendar({required this.courses});

  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color getHighlightColor(DateTime date) {
    Color highlightColor = Colors.transparent;

    for (var course in widget.courses) {
      if (isSameDay(course.recordBookSelectedDateField!, date)) {
        switch (course.scoringTypeField) {
          case 'Exam':
            return Colors.red; // Highest priority, no need to check further
          case 'Scoring':
            if (highlightColor != Colors.red) {
              highlightColor = Colors.yellow;
            }
            break;
          case 'Other':
            if (highlightColor != Colors.red &&
                highlightColor != Colors.yellow) {
              highlightColor = Colors.green;
            }
            break;
          default:
            if (highlightColor == Colors.transparent) {
              highlightColor = Colors.blue;
            }
        }
      }
    }

    return highlightColor;
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> highlightedDates = widget.courses
        .map((course) => course.recordBookSelectedDateField!)
        .toList();

    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          Color highlightColor = getHighlightColor(date);

          if (highlightColor != Colors.transparent) {
            return Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(color: Colors.white),
                ),
              ),
            );
          }
          return Center(
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
              ),
            ),
          );
        },
      ),
    );
  }
}

class Event {
  final String title;

  Event(this.title);
}
