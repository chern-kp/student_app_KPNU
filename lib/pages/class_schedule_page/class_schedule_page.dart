import 'package:flutter/material.dart';
import 'package:student_app/class/course_class.dart';
import 'package:student_app/class/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_app/class/event_class.dart';
import 'package:student_app/components/dropdownmenu_choose_semester.dart';
import 'package:student_app/pages/class_schedule_page/my_callendar.dart';
import 'package:intl/intl.dart';
import 'package:student_app/pages/class_schedule_page/new_event_dialog.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({Key? key}) : super(key: key);

  @override
  ClassSchedulePageState createState() => ClassSchedulePageState();
}

class ClassSchedulePageState extends State<ClassSchedulePage> {
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
          return const Center(child: CircularProgressIndicator());
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
    return DropdownMenuChooseSemester(
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
    return [...filteredCourses, ...events];
  }

  Widget _buildListView(List<dynamic> combinedList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        var item = combinedList[index];
        return _buildListItem(item);
      },
    );
  }

  Widget _buildListItem(dynamic item) {
    if (item is Course) {
      return ListTile(
        title: Text(item.nameField!),
        subtitle: Text(
            'Record Book Selected Date: ${DateFormat.yMMMd().format(item.recordBookSelectedDateField!)}\nScoring Type: ${item.scoringTypeField!}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await DatabaseService.deleteCourse(user!.email!, item.nameField!);
            updateState();
          },
        ),
      );
    } else if (item is EventSchedule) {
      String subtitle = 'Event Type: ${item.eventType!}';
      if (!isDefaultDate(item.eventDateStart)) {
        subtitle +=
            '\nStart Date: ${DateFormat.yMMMd().format(item.eventDateStart!)}';
      }
      if (!isDefaultDate(item.eventDateEnd)) {
        subtitle +=
            '\nEnd Date: ${DateFormat.yMMMd().format(item.eventDateEnd!)}';
      }

      return ListTile(
        title: Text(item.eventName!),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NewEventDialog(
                      isEdit: true,
                      event: item,
                      selectedSemester: selectedSemester,
                      onUpdate: updateState,
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await DatabaseService.deleteEvent(
                    user!.email!, item.eventName!);
                updateState();
              },
            ),
          ],
        ),
      );
    } else {
      throw Exception('Unknown type in combinedList');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Графік Освітнього Процесу'),
      ),
      body: _buildFutureBuilder(),
    );
  }
}
