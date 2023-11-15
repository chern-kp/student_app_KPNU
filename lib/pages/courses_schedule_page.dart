// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers

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

  void updateSelectedSemester(
    String selectedItem,
  ) {
    setState(() {
      selectedSemesterPage = selectedItem;
      coursesFuture = generateCourses(selectedItem);
    });
  }

  Future<List<Map<String, dynamic>>> generateCourses(String semester) async {
    List<Course> courses =
        await DatabaseService.getAllCourses(user.email!, semester);
    expandedState = List<bool>.filled(courses.length, false);
    return courses.map((course) {
      return {
        'course': course,
        'isExpanded': false,
      };
    }).toList();
  }

  Widget _addNewCourseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool? result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog();
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
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              bool? result = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return NewCourseDialog(
                                    isEdit: true,
                                    course: course,
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
                            onPressed: () {
                              DatabaseService.deleteCourse(
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text('Назва дисципліни: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
              Text(course.nameField ?? '', style: TextStyle(fontSize: 20)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Форма підсумкового конролю: ',
                  style: TextStyle(
                    fontSize: 20,
                  )),
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
              Expanded(child: _coursesListView(context)),
            ],
          ),
        ),
      ),
    );
  }
}
