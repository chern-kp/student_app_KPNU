// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_constructors_in_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/my_dropdownmenu_semeter.dart';

import '../class/course_class.dart';
import 'new_course_dialog.dart';

class CoursesSchedulePage extends StatefulWidget {
  CoursesSchedulePage({Key? key}) : super(key: key);

  @override
  State<CoursesSchedulePage> createState() => _CoursesSchedulePageState();
}

class _CoursesSchedulePageState extends State<CoursesSchedulePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);

  String? selectedSemesterPage;
  // Building List View
  Future<List<Map<String, dynamic>>> coursesFuture = Future.value([]);
  List<bool> expandedState = [];
  SortOption sortOption = SortOption.alphabeticalAsc;

  @override
  void initState() {
    super.initState();
    selectedSemester.then((value) {
      setState(() {
        selectedSemesterPage = value;
        coursesFuture = generateCourses(selectedSemesterPage!);
      });
    });
  }

  void updateSelectedSemester(String selectedItem) {
    setState(() {
      selectedSemesterPage = selectedItem;
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
          coursesFuture = generateCourses(selectedSemesterPage!);
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

  Future<List<Map<String, dynamic>>> generateCourses(String semester) async {
    List<Course> courses =
        await DatabaseService.getAllCourses(user.email!, semester);
    expandedState =
        courses.map((course) => !(course.isScheduleFilled ?? false)).toList();

    // Sort courses based on isScheduleFilled
    courses.sort((a, b) {
      if (a.isScheduleFilled == true && b.isScheduleFilled != true) {
        return -1;
      } else if (b.isScheduleFilled == true && a.isScheduleFilled != true) {
        return 1;
      } else {
        return 0;
      }
    });

    if (sortOption == SortOption.alphabeticalAsc) {
      courses.sort((a, b) => (a.nameField ?? "").compareTo(b.nameField ?? ""));
    } else if (sortOption == SortOption.alphabeticalDesc) {
      courses.sort((a, b) => (b.nameField ?? "").compareTo(a.nameField ?? ""));
    } else if (sortOption == SortOption.hoursInClassDesc) {
      courses.sort((a, b) => (b.hoursInClassTotalField?.toInt() ?? 0)
          .compareTo(a.hoursInClassTotalField?.toInt() ?? 0));
    } else if (sortOption == SortOption.hoursIndividualDesc) {
      courses.sort((a, b) => (b.hoursIndividualTotalField?.toInt() ?? 0)
          .compareTo(a.hoursIndividualTotalField?.toInt() ?? 0));
    } else if (sortOption == SortOption.hoursOverallDesc) {
      courses.sort((a, b) => (b.hoursOverallTotalField?.toInt() ?? 0)
          .compareTo(a.hoursOverallTotalField?.toInt() ?? 0));
    }

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
              currentSemester: selectedSemesterPage,
            );
          },
        );
        if (result == true) {
          setState(() {
            coursesFuture = generateCourses(selectedSemesterPage!);
          });
        }
      },
      child: Text("Add New Course"),
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
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(expandedState[index]
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onPressed: () {
                              setState(() {
                                expandedState[index] = !expandedState[index];
                              });
                            },
                          ),
                          Text(course.nameField ?? "",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: course.isScheduleFilled != false
                                ? Icon(Icons.edit)
                                : Container(),
                            onPressed: () async {
                              bool? result = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return NewCourseDialog(
                                    isEdit: true,
                                    course: course,
                                    currentSemester: selectedSemesterPage,
                                  );
                                },
                              );
                              if (result == true) {
                                setState(() {
                                  coursesFuture =
                                      generateCourses(selectedSemesterPage!);
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
                                    generateCourses(selectedSemesterPage!);
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
        Text(
          'Назва дисципліни: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(course.nameField ?? '', style: TextStyle(fontSize: 20)),
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
                      course: course,
                      filledCourseSchedule: true,
                      filledNewRecordBook: course.isRecordBookFilled ?? false,
                      currentSemester: selectedSemesterPage,
                    );
                  },
                );
                if (result == true) {
                  setState(() {
                    coursesFuture = generateCourses(selectedSemesterPage!);
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
                Text('Форма підсумкового конролю: ',
                    style: TextStyle(fontSize: 20)),
                Text(course.scoringTypeField ?? '',
                    style: TextStyle(fontSize: 20))
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
                Text('Кількість кредитів: ', style: TextStyle(fontSize: 20)),
                Text(
                  course.creditsOverallTotalField.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600]),
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
        title: Text('CoursesSchedulePage'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              MyDropdownMenuSemester(
                  onSelectedItemChanged: updateSelectedSemester),
              SizedBox(height: 25),
              _addNewCourseButton(context),
              SizedBox(height: 25),
              _sortDropDownMenu(),
              SizedBox(height: 25),
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
