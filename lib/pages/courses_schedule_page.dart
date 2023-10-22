// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_data.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/my_dropdownmenu_semeter.dart';

import 'new_course_dialog.dart';

class CoursesSchedulePage extends StatefulWidget {
  CoursesSchedulePage({Key? key}) : super(key: key);

  @override
  State<CoursesSchedulePage> createState() => _CoursesSchedulePageState();
}

class _CoursesSchedulePageState extends State<CoursesSchedulePage> {
  // Building List View
  late Future<List<Map<String, dynamic>>> coursesFuture;

  List<bool> expandedState = [];
  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  String? selectedSemesterPage;
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    selectedSemester.then((value) {
      setState(() {
        selectedSemesterPage = value;
      });
    });
    coursesFuture = generateCourses();
  }

  void updateSelectedSemester(String selectedItem) {
    setState(() {
      selectedSemesterPage = selectedItem;
    });
  }

  Future<List<Map<String, dynamic>>> generateCourses() async {
    List<Course> courses = await DatabaseService.getAllCourses(user.email!);
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
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog();
          },
        );
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
                          Text(course.nameField ?? ""),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // todo edit func
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              DatabaseService.deleteCourse(
                                  user.email!, course.nameField!);
                              setState(() {
                                coursesFuture = generateCourses();
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

  Widget _courseDetails(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Name: ${course.nameField}'),
        Text('Semester: ${course.semesterField}'),
        Text('Hours Lections: ${course.hoursLectionsField}'),
        Text('Hours Practices: ${course.hoursPracticesField}'),
        Text('Hours Labs: ${course.hoursLabsField}'),
        Text('Hours Coursework: ${course.hoursCourseworkField}'),
        Text('Hours In Class Total: ${course.hoursInClassTotalField}'),
        Text('Hours Individual Total: ${course.hoursIndividualTotalField}'),
        Text('Hours Overall Total: ${course.hoursOverallTotalField}'),
        Text('Credits Overall Total: ${course.creditsOverallTotalField}'),
      ],
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
              if (selectedSemesterPage == "Semester 1")
                Expanded(child: _coursesListView(context)),
            ],
          ),
        ),
      ),
    );
  }
}
