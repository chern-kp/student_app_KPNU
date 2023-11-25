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
          if (highlightedDates.any((d) => isSameDay(d, date))) {
            return Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.red,
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
