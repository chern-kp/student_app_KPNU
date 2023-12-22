import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:student_app/class/course_class.dart';

import '../../class/event_class.dart';
import 'calendar_dialog.dart';

class MyCalendar extends StatefulWidget {
  final List<Course> courses;
  final List<EventSchedule> events;
  final String? selectedSemester;

  const MyCalendar(
      {super.key,
      required this.courses,
      required this.events,
      this.selectedSemester});

  @override
  MyCalendarState createState() => MyCalendarState();
}

class MyCalendarState extends State<MyCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color getHighlightColor(DateTime date) {
    for (var course in widget.courses) {
      if (isSameDay(course.recordBookSelectedDateField!, date) &&
          course.isEvent == true) {
        switch (course.scoringTypeField) {
          case 'Екзамен':
            return Colors.red;
          case 'Залік':
            return Colors.yellow[800]!;
          default:
            return Colors.green;
        }
      }
    }

    for (var event in widget.events) {
      if (isSameDay(event.eventDateStart!, date) ||
          isSameDay(event.eventDateEnd!, date)) {
        switch (event.eventType) {
          case 'Екзамен':
            return Colors.red;
          case 'Залік':
            return Colors.yellow[800]!;
          default:
            return Colors.green;
        }
      }
    }

    return Colors.transparent;
  }

  Widget buildDotsInBetween(BuildContext context, DateTime date, List events,
      Function getEventsForDate) {
    List<EventSchedule> eventsForDate = getEventsForDate(date);
    Set<String> eventTypes =
        eventsForDate.map((e) => e.eventType).whereType<String>().toSet();
    List<Color> dotColors = [];
    if (eventTypes.contains('Екзамен')) {
      dotColors.add(Colors.red);
    }
    if (eventTypes.contains('Залік')) {
      dotColors.add(Colors.yellow[800]!);
    }
    if (eventTypes.length > dotColors.length) {
      dotColors.add(Colors.green);
    }
    return Positioned(
      bottom: 1,
      child: Row(
        children: dotColors
            .map((color) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
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

  List<EventSchedule> getEventsForDate(DateTime date) {
    List<EventSchedule> eventsForDate = [];
    for (var event in widget.events) {
      if (event.eventDateStart!.isBefore(date) &&
          event.eventDateEnd!.isAfter(date.add(const Duration(days: 1)))) {
        eventsForDate.add(event);
      }
    }
    return eventsForDate;
  }

  Widget? defaultBuilderFunction(
      BuildContext context, DateTime start, DateTime end) {
    Color highlightColor = getHighlightColor(start);

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
            '${start.day}',
            style: const TextStyle().copyWith(color: Colors.white),
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
          '${start.day}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'uk_UA',
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      availableCalendarFormats: const {
        CalendarFormat.month: 'Місяць',
        CalendarFormat.twoWeeks: '2 Тижні',
        CalendarFormat.week: 'Тиждень',
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
              selectedSemester: widget.selectedSemester,
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
        defaultBuilder: defaultBuilderFunction,
      ),
    );
  }
}

class Event {
  final String title;

  Event(this.title);
}
