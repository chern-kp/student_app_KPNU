// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/new_course_dialog.dart';

import '../class/course_class.dart';
import '../class/database_service.dart';
import '../components/my_dropdownmenu_semeter.dart';

class RecordBookPage extends StatefulWidget {
  RecordBookPage({Key? key}) : super(key: key);

  @override
  State<RecordBookPage> createState() => _RecordBookPageState();
}

class _RecordBookPageState extends State<RecordBookPage> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);

  String? selectedSemesterPage;
  String? selectedCourse;
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

  void updateSelectedSemester(String selectedItem) {
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

  Widget _currentCoursesDropdownMenu() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: coursesFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return DropdownButton<String>(
            value: selectedCourse,
            onChanged: (String? newValue) {
              if (snapshot.data!.any(
                  (courseMap) => courseMap['course'].nameField == newValue)) {
                setState(() {
                  selectedCourse = newValue!;
                });
              } else {
                setState(() {
                  selectedCourse = null;
                });
              }
            },
            items: snapshot.data!.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> courseMap) {
              Course course = courseMap['course'];
              return DropdownMenuItem<String>(
                value: course.nameField,
                child: Text(course.nameField!),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _addScoresButton() {
    return ElevatedButton(
      child: Text('Add Scores'),
      onPressed: () async {
        bool? result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog(
              isRecordBook: true,
            );
          },
        );
        if (result == true) {
          setState(() {
            coursesFuture = generateCourses(selectedSemesterPage!);
          });
        }
      },
    );
  }

  Widget _categoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _recordBookListView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: coursesFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          snapshot.data!.sort((a, b) {
            int aValue = a['course'].scoringTypeField == 'Exam'
                ? 1
                : a['course'].scoringTypeField == 'Scoring'
                    ? 2
                    : 3;
            int bValue = b['course'].scoringTypeField == 'Exam'
                ? 1
                : b['course'].scoringTypeField == 'Scoring'
                    ? 2
                    : 3;
            return aValue.compareTo(bValue);
          });
          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Course course = snapshot.data![index]['course'];
                String category = course.scoringTypeField == 'Exam'
                    ? 'Exam'
                    : course.scoringTypeField == 'Scoring'
                        ? 'Scoring'
                        : 'Others';
                if (index == 0 ||
                    (index > 0 &&
                        (snapshot.data![index - 1]['course'].scoringTypeField ==
                                    'Exam'
                                ? 'Exam'
                                : snapshot.data![index - 1]['course']
                                            .scoringTypeField ==
                                        'Scoring'
                                    ? 'Scoring'
                                    : 'Others') !=
                            category)) {
                  return Column(
                    children: [
                      _categoryTitle(category),
                      _recordBookCell(course),
                    ],
                  );
                } else {
                  return _recordBookCell(course);
                }
              },
            ),
          );
        }
      },
    );
  }

  Widget _recordBookCell(Course course) {
    Color backgroundColor = course.scoringTypeField == 'Exam'
        ? Colors.red
        : course.scoringTypeField == 'Scoring'
            ? Colors.yellow
            : Colors.green;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: EdgeInsets.all(10),
          color: backgroundColor,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      child: Column(
                    children: [Text('Дисципліна')],
                  )),
                  Spacer(),
                  Text(
                    "Викладач",
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(course.nameField!),
                  Spacer(),
                  Text(course.recordBookTeacherField ?? ''),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text('Форма підсумкового контролю'),
                  Spacer(),
                  Text(
                    course.scoringTypeField ?? "",
                    textAlign: TextAlign.end,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      //todo
                    },
                  ),
                ],
              )
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RecordBookPage'),
        //todo
      ),
      body: Column(
        children: [
          Center(
              child: MyDropdownMenuSemester(
                  onSelectedItemChanged: updateSelectedSemester)),
          _addScoresButton(),
          _currentCoursesDropdownMenu(),
          _recordBookListView(),
        ],
      ),
    );
  }
}
