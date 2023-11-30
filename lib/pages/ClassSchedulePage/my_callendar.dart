// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_app/class/course_class.dart';

import '../../class/event_class.dart';
import 'calendar_dialog.dart';

class MyCalendar extends StatefulWidget {
  final List<Course> courses;
  final List<EventSchedule> events;

  MyCalendar({required this.courses, required this.events});

  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color getHighlightColor(DateTime date) {
    Color highlightColor = getHighlightColorForCourses(date);
    if (highlightColor == Colors.transparent) {
      highlightColor = getHighlightColorForEvents(date);
    }
    return highlightColor;
  }

  Color getHighlightColorForCourses(DateTime date) {
    for (var course in widget.courses) {
      if (isSameDay(course.recordBookSelectedDateField!, date)) {
        switch (course.scoringTypeField) {
          case 'Exam':
            return Colors.red;
          case 'Scoring':
            return Colors.yellow;
          default:
            return Colors.green;
        }
      }
    }
    return Colors.transparent;
  }

  Color getHighlightColorForEvents(DateTime date) {
    for (var event in widget.events) {
      if (isSameDay(event.eventDateStart!, date) ||
          isSameDay(event.eventDateEnd!, date)) {
        switch (event.eventType) {
          case 'Exam':
            return Colors.red;
          case 'Scoring':
            return Colors.yellow;
          default:
            return Colors.green;
        }
      }
    }
    return Colors.transparent;
  }

  List<EventSchedule> getEventsForDate(DateTime date) {
    List<EventSchedule> eventsForDate = [];
    for (var event in widget.events) {
      if (event.eventDateStart!.isBefore(date) &&
          event.eventDateEnd!.isAfter(date)) {
        eventsForDate.add(event);
      }
    }
    return eventsForDate;
  }

  Widget buildDotsInBetween(BuildContext context, DateTime date, List events,
      Function getEventsForDate) {
    List<EventSchedule> eventsForDate = getEventsForDate(date);
    List<Color> dotColors = [];
    bool hasExam = false;
    bool hasScoring = false;
    bool hasOther = false;

    for (var event in eventsForDate) {
      if (event.eventType == 'Exam' && !hasExam) {
        dotColors.add(Colors.red);
        hasExam = true;
      } else if (event.eventType == 'Scoring' && !hasScoring) {
        dotColors.add(Colors.yellow);
        hasScoring = true;
      } else if (!hasOther) {
        dotColors.add(Colors.green);
        hasOther = true;
      }

      if (dotColors.length == 3) {
        break;
      }
    }

    return Positioned(
      bottom: 1,
      child: Row(
        children: dotColors
            .map((color) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CalendarDialog(
              selectedDate: selectedDay,
              courses: widget.courses,
              events: widget.events,
            );
          },
        );
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
        markerBuilder: (context, date, events) =>
            buildDotsInBetween(context, date, events, getEventsForDate),
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
