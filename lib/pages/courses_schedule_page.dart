import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/dropdownmenu_choose_semester.dart';

import '../class/course_class.dart';
import 'new_course_dialog.dart';

class CoursesSchedulePage extends StatefulWidget {
  const CoursesSchedulePage({Key? key}) : super(key: key);

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
      items: const <DropdownMenuItem<SortOption>>[
        DropdownMenuItem<SortOption>(
          value: SortOption.alphabeticalAsc,
          child: Text('За алфавітом (А до Я)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.alphabeticalDesc,
          child: Text('За алфавітом (Я до А)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.hoursInClassDesc,
          child: Text('За аудиторними годинами'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.hoursIndividualDesc,
          child: Text('За індивідуальними годинами'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.hoursOverallDesc,
          child: Text('За годинами загалом'),
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
      child: const Text("Додати новий елемент"),
    );
  }

  void _showDeleteDialog(BuildContext context, Course course, String semester) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Видалити елемент?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: const Center(
                          child: Text('Видалити зі сторінки',
                              textAlign: TextAlign.center)),
                      onPressed: () async {
                        NavigatorState navigator = Navigator.of(context);
                        course.isScheduleFilled = false;
                        await DatabaseService.createOrUpdateCourse(
                            user.email!, course, semester);
                        setState(() {
                          coursesFuture = generateCourses(selectedSemester!);
                        });
                        navigator.pop();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: const Center(
                          child: Text('Повністю видалити елемент',
                              textAlign: TextAlign.center)),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await DatabaseService.deleteCourse(
                            user.email!, course.nameField!);
                        setState(() {
                          coursesFuture = generateCourses(selectedSemester!);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              child: const Text(
                'Закрити',
                style: TextStyle(color: Colors.brown),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _coursesListView(BuildContext context) {
    return FutureBuilder(
      future: coursesFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Помилка: ${snapshot.error}');
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
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Не заповнені',
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
                                    style: const TextStyle(fontSize: 16)),
                              ),
                              IconButton(
                                icon: course.isScheduleFilled == true
                                    ? const Icon(Icons.edit)
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
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteDialog(
                                      context, course, selectedSemester!);
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
    if (!(course.isScheduleFilled ?? false)) {
      return _courseDetailsUnfilledCourse(course);
    } else {
      return _courseDetailsFilledCourse(course);
    }
  }

  Widget _courseDetailsFilledCourse(Course course) {
    Widget courseName = Row(
      children: [
        Expanded(
          child: Text(
            'Назва: ${course.nameField}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          courseName,
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 20),
                    children: <InlineSpan>[
                      const TextSpan(
                        text: 'Форма підсумкового контролю: ',
                      ),
                      TextSpan(
                        text: '${course.scoringTypeField}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: course.scoringTypeField == 'Екзамен'
                              ? Colors.red
                              : course.scoringTypeField == 'Залік'
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Навчальне навантаження',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
              child: Text("Аудиторні години", style: TextStyle(fontSize: 20))),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: Colors.black),
            children: [
              const TableRow(
                children: [
                  Center(child: Text('Лекції', style: TextStyle(fontSize: 15))),
                  Center(
                      child: Text('Практичні / Семінарські',
                          style: TextStyle(fontSize: 15))),
                  Center(
                      child:
                          Text('Лабораторні', style: TextStyle(fontSize: 15))),
                  Center(
                      child: Text('Курсові', style: TextStyle(fontSize: 15))),
                ],
              ),
              TableRow(
                children: [
                  Center(
                      child: Text('${course.hoursLectionsField}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  Center(
                      child: Text('${course.hoursPracticesField}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  Center(
                      child: Text('${course.hoursLabsField}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  Center(
                      child: Text('${course.hoursCourseworkField}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: <InlineSpan>[
                const TextSpan(text: 'Усього аудиторних годин: '),
                TextSpan(
                    text: '${course.hoursIndividualTotalField}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: <InlineSpan>[
                const TextSpan(text: 'Години на самостійну роботу: '),
                TextSpan(
                    text: '${course.hoursIndividualTotalField}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 20),
              children: <InlineSpan>[
                const TextSpan(text: 'Усього годин: '),
                TextSpan(
                    text: '${course.hoursOverallTotalField}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Кількість кредитів ЄКТС: ${course.creditsOverallTotalField != null && course.creditsOverallTotalField! % 1 == 0 ? course.creditsOverallTotalField!.toInt() : course.creditsOverallTotalField}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _courseDetailsUnfilledCourse(Course course) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
            child: const Text('Додати інформацію'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Індивідуальний Навчальний План'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 5),
            DropdownMenuChooseSemester(
                onSelectedItemChanged: updateSelectedSemester),
            const SizedBox(height: 5),
            _addNewCourseButton(context),
            const SizedBox(height: 5),
            _sortDropDownMenu(),
            const SizedBox(height: 5),
            Expanded(child: _coursesListView(context)),
          ],
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
