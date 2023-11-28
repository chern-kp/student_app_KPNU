// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:student_app/class/course_class.dart';
import 'package:student_app/class/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_app/class/event_class.dart';
import 'package:student_app/components/my_dropdownmenu_semeter.dart';
import 'package:student_app/pages/ClassSchedulePage/my_callendar.dart';
import 'package:intl/intl.dart';
import 'package:student_app/pages/ClassSchedulePage/new_event_dialog.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({Key? key}) : super(key: key);

  @override
  _ClassSchedulePageState createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Future<String>? selectedSemesterOfUser;
  String? selectedSemester;
  Future<List<Course>>? coursesFuture;
  Future<List<EventSchedule>>? eventsFuture;
  Future<List<dynamic>>? allDataFuture;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      selectedSemesterOfUser =
          DatabaseService.getStudentField(user!.email!, 'Current Semester');
      selectedSemesterOfUser?.then((value) => selectedSemester = value);
      allDataFuture = initializeData();
    }
  }

  void updateState() {
    setState(() {
      allDataFuture = initializeData();
    });
  }

  bool isDefaultDate(DateTime? date) {
    return date!.millisecondsSinceEpoch == 978307200000;
  }

  Future<List<dynamic>> initializeData() async {
    String selectedSemester = await selectedSemesterOfUser!;
    return Future.wait([
      fetchCourses(selectedSemester),
      fetchEvents(selectedSemester),
    ]);
  }

  Future<List<Course>> fetchCourses(String semester) async {
    if (user!.email == null) {
      throw Exception('User email is null');
    }
    List<Course> courses =
        await DatabaseService.getAllCourses(user!.email!, semester);
    courses.sort((a, b) => a.nameField!.compareTo(b.nameField!));
    return courses;
  }

  Future<List<EventSchedule>> fetchEvents(String semester) async {
    if (user!.email == null) {
      throw Exception('User email is null');
    }
    List<EventSchedule> events =
        await DatabaseService.getAllEvents(user!.email!, semester);
    return events;
  }

  Widget _addNewEventButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewEventDialog(
              selectedSemester: selectedSemester,
              onUpdate: updateState,
            );
          },
        );
      },
      child: const Text('Add New Event'),
    );
  }

  Widget _buildFutureBuilder() {
    return FutureBuilder<List<dynamic>>(
      future: allDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Course> courses = snapshot.data![0];
          List<EventSchedule> events = snapshot.data![1];
          return _buildBody(courses, events);
        }
      },
    );
  }

  Widget _buildBody(List<Course> courses, List<EventSchedule> events) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendar(courses, events),
          _buildDropdownMenu(),
          _addNewEventButton(context),
          _buildCourseList(courses, events),
        ],
      ),
    );
  }

  Widget _buildCalendar(List<Course> courses, List<EventSchedule> events) {
    return MyCalendar(
      courses: courses,
      events: events,
    );
  }

  Widget _buildDropdownMenu() {
    return MyDropdownMenuSemester(
      initialSemester: selectedSemester,
      onSelectedItemChanged: (selectedItem) {
        setState(() {
          selectedSemester = selectedItem;
          allDataFuture = Future.wait([
            fetchCourses(selectedSemester!),
            fetchEvents(selectedSemester!),
          ]);
        });
      },
    );
  }

  Widget _buildCourseList(List<Course> courses, List<EventSchedule> events) {
    List<Course> filteredCourses = _filterCourses(courses);
    List<dynamic> combinedList = _combineLists(filteredCourses, events);
    return _buildListView(combinedList);
  }

  List<Course> _filterCourses(List<Course> courses) {
    return courses.where((course) {
      return !isDefaultDate(course.recordBookSelectedDateField);
    }).toList();
  }

  List<dynamic> _combineLists(
      List<Course> filteredCourses, List<EventSchedule> events) {
    return []
      ..addAll(filteredCourses)
      ..addAll(events);
  }

  Widget _buildListView(List<dynamic> combinedList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        var item = combinedList[index];
        if (item is Course) {
          return ListTile(
            title: Text(item.nameField!),
            subtitle: Text('Record Book Selected Date: ' +
                DateFormat.yMMMd().format(item.recordBookSelectedDateField!) +
                '\nScoring Type: ' +
                item.scoringTypeField!),
          );
        } else if (item is EventSchedule) {
          String subtitle = 'Event Type: ' + item.eventType!;
          if (!isDefaultDate(item.eventDateStart)) {
            subtitle += '\nStart Date: ' +
                DateFormat.yMMMd().format(item.eventDateStart!);
          }
          if (!isDefaultDate(item.eventDateEnd)) {
            subtitle +=
                '\nEnd Date: ' + DateFormat.yMMMd().format(item.eventDateEnd!);
          }
          return ListTile(
            title: Text(item.eventName!),
            subtitle: Text(subtitle),
          );
        } else {
          throw Exception('Unknown type in combinedList');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Schedule'),
      ),
      body: _buildFutureBuilder(),
    );
  }
}
