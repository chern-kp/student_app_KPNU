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
  bool isSortedByDate = false;
  SortOption sortOption = SortOption.alphabeticalAsc;
  bool isGroupedByScoringType = false;

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

    if (sortOption == SortOption.dateAsc) {
      courses.sort((a, b) => a.recordBookSelectedDateField!
          .compareTo(b.recordBookSelectedDateField!));
    } else if (sortOption == SortOption.dateDesc) {
      courses.sort((a, b) => b.recordBookSelectedDateField!
          .compareTo(a.recordBookSelectedDateField!));
    } else if (sortOption == SortOption.alphabeticalAsc) {
      courses.sort((a, b) => a.nameField!.compareTo(b.nameField!));
    } else if (sortOption == SortOption.alphabeticalDesc) {
      courses.sort((a, b) => b.nameField!.compareTo(a.nameField!));
    } else if (sortOption == SortOption.teacherAsc) {
      courses.sort((a, b) {
        if (a.recordBookTeacherField!.isEmpty &&
            b.recordBookTeacherField!.isEmpty) {
          return 0;
        } else if (a.recordBookTeacherField!.isEmpty) {
          return 1;
        } else if (b.recordBookTeacherField!.isEmpty) {
          return -1;
        } else {
          return a.recordBookTeacherField!.compareTo(b.recordBookTeacherField!);
        }
      });
    } else if (sortOption == SortOption.teacherDesc) {
      courses.sort((a, b) {
        if (a.recordBookTeacherField!.isEmpty &&
            b.recordBookTeacherField!.isEmpty) {
          return 0;
        } else if (a.recordBookTeacherField!.isEmpty) {
          return 1;
        } else if (b.recordBookTeacherField!.isEmpty) {
          return -1;
        } else {
          return b.recordBookTeacherField!.compareTo(a.recordBookTeacherField!);
        }
      });
      if (isGroupedByScoringType) {
        courses.sort((a, b) {
          int aValue = a.scoringTypeField == 'Exam'
              ? 1
              : a.scoringTypeField == 'Scoring'
                  ? 2
                  : 3;
          int bValue = b.scoringTypeField == 'Exam'
              ? 1
              : b.scoringTypeField == 'Scoring'
                  ? 2
                  : 3;
          return aValue.compareTo(bValue);
        });
      }

      return courses.map((course) {
        return {
          'course': course,
          'isExpanded': false,
        };
      }).toList();
    }

    return courses.map((course) {
      return {
        'course': course,
        'isExpanded': false,
      };
    }).toList();
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

  Widget _sortDropDownMenu() {
    return DropdownButton<SortOption>(
      value: sortOption,
      icon: const Icon(Icons.arrow_downward),
      onChanged: (SortOption? newValue) {
        setState(() {
          sortOption = newValue!;
          coursesFuture = generateCourses(selectedSemesterPage!);
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
          value: SortOption.dateAsc,
          child: Text('Sort by Date (Oldest to Newest)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.dateDesc,
          child: Text('Sort by Date (Newest to Oldest)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.teacherAsc,
          child: Text('Sort by Teacher (A to Z)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.teacherDesc,
          child: Text('Sort by Teacher (Z to A)'),
        ),
      ],
    );
  }

  Widget _groupByScoringTypeCheckbox() {
    return CheckboxListTile(
      title: Text('Group by Scoring Type'),
      value: isGroupedByScoringType,
      onChanged: (bool? value) {
        setState(() {
          isGroupedByScoringType = value!;
          coursesFuture = generateCourses(selectedSemesterPage!);
        });
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
          List<Map<String, dynamic>> examCourses = [];
          List<Map<String, dynamic>> scoringCourses = [];
          List<Map<String, dynamic>> otherCourses = [];

          for (var courseMap in snapshot.data!) {
            Course course = courseMap['course'];
            if (course.scoringTypeField == 'Exam') {
              examCourses.add(courseMap);
            } else if (course.scoringTypeField == 'Scoring') {
              scoringCourses.add(courseMap);
            } else {
              otherCourses.add(courseMap);
            }
          }

          return Expanded(
            child: ListView(
              children: [
                if (isGroupedByScoringType)
                  ..._buildCategory('Exam', examCourses),
                if (isGroupedByScoringType)
                  ..._buildCategory('Scoring', scoringCourses),
                if (isGroupedByScoringType)
                  ..._buildCategory('Others', otherCourses),
                if (!isGroupedByScoringType)
                  ...snapshot.data!
                      .map((courseMap) => _recordBookCell(courseMap['course']))
                      .toList(),
              ],
            ),
          );
        }
      },
    );
  }

  List<Widget> _buildCategory(
      String title, List<Map<String, dynamic>> courses) {
    return [
      _categoryTitle(title),
      ...courses
          .map((courseMap) => _recordBookCell(courseMap['course']))
          .toList(),
    ];
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(child: Text(course.nameField!)),
              course.isRecordBookFilled ?? false
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Spacer(),
                            Text(
                              "Викладач",
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                        Row(
                          children: [
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
                          children: [
                            Text('Оцінка'),
                            Spacer(),
                            Text(
                              course.recordBookScoreField.toString(),
                              textAlign: TextAlign.end,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text('Дата'),
                            Spacer(),
                            Text(
                              "${course.recordBookSelectedDateField?.year.toString().padLeft(4, '0')}-${course.recordBookSelectedDateField?.month.toString().padLeft(2, '0')}-${course.recordBookSelectedDateField?.day.toString().padLeft(2, '0')} ${course.recordBookSelectedDateField?.hour.toString().padLeft(2, '0')}:${course.recordBookSelectedDateField?.minute.toString().padLeft(2, '0')}",
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
                              onPressed: () async {
                                bool? result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return NewCourseDialog(
                                      isEdit: true,
                                      course: course,
                                      isRecordBook: true,
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
                          ],
                        )
                      ],
                    )
                  : Container(
                      padding: EdgeInsets.all(10),
                      color: backgroundColor,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool? result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NewCourseDialog(
                                isEdit: true,
                                course: course,
                                isRecordBook: true,
                                filledNewRecordBook: true,
                                filledCourseSchedule:
                                    course.isScheduleFilled ?? false,
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
                        child: Text('Edit Scores'),
                      ),
                    ),
            ],
          ),
        ),
      ),
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
          _sortDropDownMenu(),
          _groupByScoringTypeCheckbox(),
          _recordBookListView(),
        ],
      ),
    );
  }
}

enum SortOption {
  dateAsc,
  dateDesc,
  alphabeticalAsc,
  alphabeticalDesc,
  teacherAsc,
  teacherDesc
}

enum ScoringType { Exam, Scoring, Others }
