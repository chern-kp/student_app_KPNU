import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/new_course_dialog.dart';

import '../class/course_class.dart';
import '../class/database_service.dart';
import '../components/dropdownmenu_choose_semester.dart';

class RecordBookPage extends StatefulWidget {
  const RecordBookPage({Key? key}) : super(key: key);

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

  Future<List<Course>> fetchCourses(String semester) async {
    return await DatabaseService.getAllCourses(user.email!, semester);
  }

  List<bool> setExpandedState(List<Course> courses) {
    return List<bool>.filled(courses.length, false);
  }

  List<Course> sortCourses(List<Course> courses) {
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
    }

    if (isGroupedByScoringType) {
      courses.sort((a, b) {
        int aValue = a.scoringTypeField == 'Екзамен'
            ? 1
            : a.scoringTypeField == 'Залік'
                ? 2
                : 3;
        int bValue = b.scoringTypeField == 'Екзамен'
            ? 1
            : b.scoringTypeField == 'Залік'
                ? 2
                : 3;
        return aValue.compareTo(bValue);
      });
    }

    courses.sort((a, b) {
      if (a.isRecordBookFilled == b.isRecordBookFilled) {
        return 0;
      } else if (a.isRecordBookFilled == true) {
        return -1;
      } else {
        return 1;
      }
    });

    return courses;
  }

  Future<List<Map<String, dynamic>>> generateCourses(String semester) async {
    List<Course> courses = await fetchCourses(semester);
    expandedState = setExpandedState(courses);
    courses = sortCourses(courses);

    return courses.map((course) {
      return {
        'course': course,
        'isExpanded': false,
      };
    }).toList();
  }

  Widget _addScoresButton() {
    return ElevatedButton(
      child: const Text('Додати новий елемент'),
      onPressed: () async {
        bool? result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog(
              isRecordBook: true,
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
          value: SortOption.dateAsc,
          child: Text('По даті (Старіші до новіших)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.dateDesc,
          child: Text('По даті (Новіші до старіших)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.teacherAsc,
          child: Text('За викладачем (А до Я)'),
        ),
        DropdownMenuItem<SortOption>(
          value: SortOption.teacherDesc,
          child: Text('За викладачем (Я до Аcr)'),
        ),
      ],
    );
  }

  Widget _groupByScoringTypeCheckbox() {
    return CheckboxListTile(
      title: const Text('Групувати за формою підсумкового контролю',
          style: TextStyle(fontSize: 14)),
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
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _recordBookListView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: coursesFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Помилка: ${snapshot.error}');
        } else {
          List<Map<String, dynamic>> examCoursesFilled = [];
          List<Map<String, dynamic>> scoringCoursesFilled = [];
          List<Map<String, dynamic>> otherCoursesFilled = [];
          List<Map<String, dynamic>> examCoursesNotFilled = [];
          List<Map<String, dynamic>> scoringCoursesNotFilled = [];
          List<Map<String, dynamic>> otherCoursesNotFilled = [];

          for (var courseMap in snapshot.data!) {
            Course course = courseMap['course'];
            if (course.isRecordBookFilled!) {
              if (course.scoringTypeField == 'Екзамен') {
                examCoursesFilled.add(courseMap);
              } else if (course.scoringTypeField == 'Залік') {
                scoringCoursesFilled.add(courseMap);
              } else {
                otherCoursesFilled.add(courseMap);
              }
            } else {
              if (course.scoringTypeField == 'Екзамен') {
                examCoursesNotFilled.add(courseMap);
              } else if (course.scoringTypeField == 'Залік') {
                scoringCoursesNotFilled.add(courseMap);
              } else {
                otherCoursesNotFilled.add(courseMap);
              }
            }
          }

          return Expanded(
            child: ListView(
              children: [
                if (isGroupedByScoringType && examCoursesFilled.isNotEmpty)
                  ..._buildCategory('Екзамен', examCoursesFilled),
                if (isGroupedByScoringType && scoringCoursesFilled.isNotEmpty)
                  ..._buildCategory('Залік', scoringCoursesFilled),
                if (isGroupedByScoringType && otherCoursesFilled.isNotEmpty)
                  ..._buildCategory('Інше', otherCoursesFilled),
                if (isGroupedByScoringType && examCoursesNotFilled.isNotEmpty)
                  ..._buildCategory('Екзамен', examCoursesNotFilled),
                if (isGroupedByScoringType &&
                    scoringCoursesNotFilled.isNotEmpty)
                  ..._buildCategory('Залік', scoringCoursesNotFilled),
                if (isGroupedByScoringType && otherCoursesNotFilled.isNotEmpty)
                  ..._buildCategory('Інше', otherCoursesNotFilled),
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
    Color backgroundColor = course.scoringTypeField == 'Екзамен'
        ? const Color.fromARGB(255, 184, 48, 38)
        : course.scoringTypeField == 'Залік'
            ? const Color.fromARGB(255, 250, 193, 8)
            : const Color.fromARGB(255, 60, 139, 63);
    return _buildCourseCell(course, backgroundColor);
  }

  Widget _buildCourseCell(Course course, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 3.0,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: borderColor,
                  width: 5.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                        child: Text(
                      course.nameField!,
                      style: const TextStyle(fontSize: 18),
                    )),
                    course.isRecordBookFilled ?? false
                        ? _buildFilledCourseDetails(course, borderColor)
                        : _buildEmptyCourseButton(course),
                  ],
                ),
              ),
            ),
            if (!(course.isRecordBookFilled ?? false))
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDeleteDialog(context, course, selectedSemesterPage!);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledCourseDetails(Course course, Color backgroundColor) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        if (course.recordBookTeacherField!.isNotEmpty)
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text(
                    "Викладач: ",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${course.recordBookTeacherField}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ],
          ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const Text('Форма підсумкового \nконтролю:',
                style: TextStyle(fontSize: 20)),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 20),
                  children: <InlineSpan>[
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
                softWrap: true,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        if (course.hoursOverallTotalField != null &&
            course.hoursOverallTotalField != 0)
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text('Кількість годин: ',
                      style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Text(course.hoursOverallTotalField.toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
            ],
          ),
        if (course.creditsOverallTotalField != null &&
            course.creditsOverallTotalField != 0)
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text('Кількість кредитів:',
                      style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Text(
                      course.creditsOverallTotalField != null &&
                              course.creditsOverallTotalField! % 1 == 0
                          ? course.creditsOverallTotalField!.toInt().toString()
                          : course.creditsOverallTotalField.toString(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
            ],
          ),
        if (!course.recordBookSelectedDateField!.isAtSameMomentAs(
            DateTime.fromMillisecondsSinceEpoch(978307200000, isUtc: true)))
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Text('Дата і час:', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Text(
                      "${course.recordBookSelectedDateField?.year.toString().padLeft(4, '0')}-${course.recordBookSelectedDateField?.month.toString().padLeft(2, '0')}-${course.recordBookSelectedDateField?.day.toString().padLeft(2, '0')} ${course.recordBookSelectedDateField?.hour.toString().padLeft(2, '0')}:${course.recordBookSelectedDateField?.minute.toString().padLeft(2, '0')}",
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
            ],
          ),
        const SizedBox(
          height: 5,
        ),
        const Text('Оцінка', style: TextStyle(fontSize: 24)),
        Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    course.recordBookScoreField == null ||
                            course.recordBookScoreField == 0
                        ? "-"
                        : course.recordBookScoreField.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          bool? result = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return NewCourseDialog(
                                isEdit: true,
                                course: course,
                                isRecordBook: true,
                                filledNewRecordBook: true,
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
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDeleteDialog(
                              context, course, selectedSemesterPage!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showDeleteDialog(BuildContext context, Course course, String semester) {
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
                    child: Builder(
                      builder: (context) => ElevatedButton(
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: const Center(
                            child: Text('Видалити зі сторінки',
                                textAlign: TextAlign.center)),
                        onPressed: () async {
                          course.isRecordBookFilled = false;
                          await DatabaseService.createOrUpdateCourse(
                              user.email!, course, semester);
                          setState(() {
                            coursesFuture =
                                generateCourses(selectedSemesterPage!);
                          });
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
                          await DatabaseService.deleteCourse(
                              user.email!, course.nameField!);
                          setState(() {
                            coursesFuture =
                                generateCourses(selectedSemesterPage!);
                          });
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

  Widget _buildEmptyCourseButton(Course course) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () async {
          bool? result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return NewCourseDialog(
                isEdit: true,
                isEditFilling: true,
                course: course,
                isRecordBook: true,
                filledNewRecordBook: true,
                filledCourseSchedule: course.isScheduleFilled ?? false,
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
        child: const Text('Додати інформацію'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Залікова Книжка Студента'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Center(
              child: DropdownMenuChooseSemester(
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
