import 'package:flutter/material.dart';
import 'package:student_app/class/course_class.dart';
import 'package:student_app/class/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_app/class/event_class.dart';
import 'package:student_app/components/dropdownmenu_choose_semester.dart';
import 'package:student_app/pages/class_schedule_page/my_callendar.dart';
import 'package:student_app/pages/class_schedule_page/new_event_dialog.dart';

import '../new_course_dialog.dart';
import 'class_list_view_builder.dart';

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
  SortOption sortOption = SortOption.byNameAtoZ;

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

  Widget _sortDropDownMenu() {
    return DropdownButton<SortOption>(
      value: sortOption,
      icon: const Icon(Icons.arrow_downward),
      onChanged: (SortOption? newValue) {
        setState(() {
          sortOption = newValue!;
          allDataFuture = initializeData();
        });
      },
      items: const <DropdownMenuItem<SortOption>>[
        DropdownMenuItem<SortOption>(
          value: SortOption.byNameAtoZ,
          child: Text('За алфавітом (А до Я)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.byNameZtoA,
          child: Text('За алфавітом (Я до А)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.byStartDate,
          child: Text('По даті початку'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.byEndDate,
          child: Text('По даті кінця'),
        ),
      ],
    );
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
    courses.sort((a, b) {
      switch (sortOption) {
        case SortOption.byNameAtoZ:
          return a.nameField!.compareTo(b.nameField!);
        case SortOption.byNameZtoA:
          return b.nameField!.compareTo(a.nameField!);
        case SortOption.byStartDate:
        case SortOption.byEndDate:
          return a.recordBookSelectedDateField!
              .compareTo(b.recordBookSelectedDateField!);
      }
    });
    return courses;
  }

  Future<List<EventSchedule>> fetchEvents(String semester) async {
    if (user!.email == null) {
      throw Exception('User email is null');
    }
    List<EventSchedule> events =
        await DatabaseService.getAllEvents(user!.email!, semester);
    events.sort((a, b) {
      switch (sortOption) {
        case SortOption.byNameAtoZ:
          return a.eventName!.compareTo(b.eventName!);
        case SortOption.byNameZtoA:
          return b.eventName!.compareTo(a.eventName!);
        case SortOption.byStartDate:
          return a.eventDateStart!.compareTo(b.eventDateStart!);
        case SortOption.byEndDate:
          return a.eventDateEnd!.compareTo(b.eventDateEnd!);
      }
    });
    return events;
  }

  Widget _addNewEventButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
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
          child: const Text('Додати нову подію'),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return NewCourseDialog(
                  isClassSchedule: true,
                  isRecordBook: false,
                  filledNewRecordBook: false,
                  filledCourseSchedule: false,
                  currentSemester: selectedSemester,
                );
              },
            );
            if (result != null && result) {
              updateState();
            }
          },
          child: const Text('Додати новий елемент'),
        ),
      ],
    );
  }

  Widget _buildFutureBuilder() {
    return FutureBuilder<List<dynamic>>(
      future: allDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Помилка: ${snapshot.error}'));
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
          _sortDropDownMenu(),
          _addNewEventButton(context),
          ClassListView(
            combinedList: _combineLists(_filterCourses(courses), events),
            updateState: updateState,
            user: user,
            selectedSemester: selectedSemester,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(List<Course> courses, List<EventSchedule> events) {
    return MyCalendar(
      courses: courses,
      events: events,
      selectedSemester: selectedSemester,
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

  List<Course> _filterCourses(List<Course> courses) {
    return courses.where((course) {
      return !isDefaultDate(course.recordBookSelectedDateField) &&
          course.isEvent == true;
    }).toList();
  }

  List<dynamic> _combineLists(
      List<Course> filteredCourses, List<EventSchedule> events) {
    return [...filteredCourses, ...events];
  }

  void showDeleteDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Видалити елемент?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item is Course)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Builder(
                        builder: (context) => ElevatedButton(
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: const Center(
                              child: Text('Видалити зі сторінки',
                                  textAlign: TextAlign.center)),
                          onPressed: () async {
                            item.isEvent = false;
                            await DatabaseService.createOrUpdateCourse(
                                user!.email!, item, selectedSemester!);
                            updateState();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(
                      builder: (context) => ElevatedButton(
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: const Center(
                            child: Text('Повністтю видалити елемент',
                                textAlign: TextAlign.center)),
                        onPressed: () async {
                          if (item is Course) {
                            await DatabaseService.deleteCourse(
                                user!.email!, item.nameField!);
                          } else if (item is EventSchedule) {
                            await DatabaseService.deleteEvent(
                                user!.email!, item.eventName!);
                          }
                          updateState();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              child:
                  const Text('Закрити', style: TextStyle(color: Colors.brown)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

enum SortOption {
  byNameAtoZ,
  byNameZtoA,
  byStartDate,
  byEndDate,
}
