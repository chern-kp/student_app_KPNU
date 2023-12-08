// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_constructors_in_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/dropdownmenu_choose_semester.dart';

import '../class/course_class.dart';
import 'new_course_dialog.dart';

class CoursesSchedulePage extends StatefulWidget {
  CoursesSchedulePage({Key? key}) : super(key: key);

  @override
  State<CoursesSchedulePage> createState() => _CoursesSchedulePageState();
}

class _CoursesSchedulePageState extends State<CoursesSchedulePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<String> selectedSemesterOfUser =
      DatabaseService.getStudentField(user.email, 'Current Semester');
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);

  SortOption sortOption = SortOption.alphabeticalAsc;
  String? selectedSemester;
  // Building List View
  Future<List<Map<String, dynamic>>> coursesFuture = Future.value([]);
  List<bool> expandedState = [];

  @override
  void initState() {
    super.initState();
    selectedSemesterOfUser.then((value) {
      setState(() {
        selectedSemester = value;
        coursesFuture = generateCourses(selectedSemester!);
      });
    });
  }

  void updateSelectedSemester(String selectedItem) {
    setState(() {
      selectedSemester = selectedItem;
      coursesFuture = generateCourses(selectedItem);
      coursesFuture.then((courses) {
        setState(() {
          expandedState = courses
              .map((course) => !(course['course'].isScheduleFilled ?? false))
              .toList();
        });
      });
    });
  }

  Widget _sortDropDownMenu() {
    return DropdownButton<SortOption>(
      value: sortOption,
      icon: const Icon(Icons.arrow_downward),
      onChanged: (SortOption? newValue) {
        setState(() {
          sortOption = newValue!;
          coursesFuture = generateCourses(selectedSemester!);
          coursesFuture.then((courses) {
            setState(() {
              expandedState = courses
                  .map(
                      (course) => !(course['course'].isScheduleFilled ?? false))
                  .toList();
            });
          });
        });
      },
      items: <DropdownMenuItem<SortOption>>[
        DropdownMenuItem<SortOption>(
          value: SortOption.alphabeticalAsc,
          child: Text('Alphabetical (A to Z)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.alphabeticalDesc,
          child: Text('Alphabetical (Z to A)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.hoursInClassDesc,
          child: Text('By Hours In Class'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.hoursIndividualDesc,
          child: Text('By Hours Individual'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.hoursOverallDesc,
          child: Text('By Hours Overall'),
        ),
      ],
    );
  }

  Future<List<Course>> fetchCourses(String semester) async {
    return await DatabaseService.getAllCourses(user.email!, semester);
  }

  List<bool> setExpandedState(List<Course> courses) {
    return courses
        .map((course) => !(course.isScheduleFilled ?? false))
        .toList();
  }

  List<Course> sortCourses(List<Course> courses) {
    courses.sort((a, b) {
      if (a.isScheduleFilled == true && b.isScheduleFilled != true) {
        return -1;
      } else if (b.isScheduleFilled == true && a.isScheduleFilled != true) {
        return 1;
      } else {
        if (sortOption == SortOption.alphabeticalAsc) {
          return (a.nameField ?? "").compareTo(b.nameField ?? "");
        } else if (sortOption == SortOption.alphabeticalDesc) {
          return (b.nameField ?? "").compareTo(a.nameField ?? "");
        } else if (sortOption == SortOption.hoursInClassDesc) {
          return (b.hoursInClassTotalField?.toInt() ?? 0)
              .compareTo(a.hoursInClassTotalField?.toInt() ?? 0);
        } else if (sortOption == SortOption.hoursIndividualDesc) {
          return (b.hoursIndividualTotalField?.toInt() ?? 0)
              .compareTo(a.hoursIndividualTotalField?.toInt() ?? 0);
        } else if (sortOption == SortOption.hoursOverallDesc) {
          return (b.hoursOverallTotalField?.toInt() ?? 0)
              .compareTo(a.hoursOverallTotalField?.toInt() ?? 0);
        } else {
          return 0;
        }
      }
    });

    return courses;
  }

  Future<List<Map<String, dynamic>>> generateCourses(String semester) async {
    List<Course> courses = await fetchCourses(semester);
    List<Course> filledCourses = [];
    List<Course> unfilledCourses = [];

    for (var course in courses) {
      if (course.isScheduleFilled == true) {
        filledCourses.add(course);
      } else {
        unfilledCourses.add(course);
      }
    }

    filledCourses = sortCourses(filledCourses);
    unfilledCourses = sortCourses(unfilledCourses);

    courses = [...filledCourses, ...unfilledCourses];
    expandedState = setExpandedState(courses);

    return courses.map((course) {
      return {
        'course': course,
        'isExpanded': !(course.isScheduleFilled ?? false),
      };
    }).toList();
  }

  Widget _addNewCourseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool? result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog(
              currentSemester: selectedSemester,
            );
          },
        );
        if (result == true) {
          setState(() {
            coursesFuture = generateCourses(selectedSemester!);
          });
        }
      },
      child: Text("Додати новий"),
    );
  }

  Widget _coursesListView(BuildContext context) {
    return FutureBuilder(
      future: coursesFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              Course course = snapshot.data[index]['course'];
              bool isNotFilledTitle = index > 0 &&
                  snapshot.data[index - 1]['course'].isScheduleFilled == true &&
                  course.isScheduleFilled == false;
              return Column(
                children: [
                  if (isNotFilledTitle)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Not Filled Courses',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(expandedState[index]
                                    ? Icons.expand_less
                                    : Icons.expand_more),
                                onPressed: () {
                                  setState(() {
                                    expandedState[index] =
                                        !expandedState[index];
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(course.nameField ?? "",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              IconButton(
                                icon: course.isScheduleFilled == true
                                    ? Icon(Icons.edit)
                                    : Container(),
                                onPressed: () async {
                                  bool? result = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return NewCourseDialog(
                                        isEdit: true,
                                        isEditFilling: false,
                                        course: course,
                                        filledCourseSchedule: true,
                                        currentSemester: selectedSemester,
                                      );
                                    },
                                  );
                                  if (result == true) {
                                    setState(() {
                                      coursesFuture =
                                          generateCourses(selectedSemester!);
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await DatabaseService.deleteCourse(
                                      user.email!, course.nameField!);
                                  setState(() {
                                    coursesFuture =
                                        generateCourses(selectedSemester!);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (expandedState[index])
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _courseDetails(course))
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  //UI of items in the list
  Widget _courseDetails(Course course) {
    Widget courseName = Row(
      children: [
        Expanded(
          child: Text(
            'Назва дисципліни: ${course.nameField}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
    if (!(course.isScheduleFilled ?? false)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            courseName,
            ElevatedButton(
              onPressed: () async {
                bool? result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return NewCourseDialog(
                      isEdit: true,
                      isEditFilling: true,
                      course: course,
                      filledCourseSchedule: true,
                      filledNewRecordBook: course.isRecordBookFilled!,
                      currentSemester: selectedSemester,
                    );
                  },
                );
                if (result == true) {
                  setState(() {
                    coursesFuture = generateCourses(selectedSemester!);
                    coursesFuture.then((courses) {
                      setState(() {
                        expandedState = courses
                            .map((course) =>
                                !(course['course'].isScheduleFilled ?? false))
                            .toList();
                      });
                    });
                  });
                }
              },
              child: Text('Button Text'),
            ),
          ],
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            courseName,
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Форма підсумкового конролю: ${course.scoringTypeField}',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Навчальне навантаження: ',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Кількість кредитів: ${course.creditsOverallTotalField}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Години: ', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.black),
              children: [
                TableRow(
                  children: [
                    Text('Усього'),
                    Text('В аудиторії'),
                    Text('Лекції'),
                    Text('Практичні'),
                    Text('Лабораторні'),
                    Text('Курсові'),
                    Text('Самостійна робота'),
                  ],
                ),
                TableRow(
                  children: [
                    Text('${course.hoursOverallTotalField}'),
                    Text('${course.hoursInClassTotalField}'),
                    Text('${course.hoursLectionsField}'),
                    Text('${course.hoursPracticesField}'),
                    Text('${course.hoursLabsField}'),
                    Text('${course.hoursCourseworkField}'),
                    Text('${course.hoursIndividualTotalField}'),
                  ],
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Індивідуальний Навчальний План'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              DropdownMenuChooseSemester(
                  onSelectedItemChanged: updateSelectedSemester),
              SizedBox(height: 25),
              _addNewCourseButton(context),
              SizedBox(height: 5),
              _sortDropDownMenu(),
              SizedBox(height: 5),
              Expanded(child: _coursesListView(context)),
            ],
          ),
        ),
      ),
    );
  }
}

enum SortOption {
  alphabeticalAsc,
  alphabeticalDesc,
  hoursInClassDesc,
  hoursIndividualDesc,
  hoursOverallDesc,
}
