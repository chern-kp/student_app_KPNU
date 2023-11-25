import 'package:flutter/material.dart';
import 'package:student_app/class/course_class.dart';
import 'package:student_app/class/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_app/components/my_dropdownmenu_semeter.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({Key? key}) : super(key: key);

  @override
  _ClassSchedulePageState createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  late String selectedSemester;
  late Future<List<Course>> coursesFuture = Future.value([]);

  Future<List<Course>> fetchCourses(String semester) async {
    String? userEmail = FirebaseAuth.instance.currentUser!.email;
    if (userEmail == null) {
      throw Exception('User email is null');
    }
    List<Course> courses =
        await DatabaseService.getAllCourses(userEmail, semester);
    courses.sort((a, b) => a.nameField!.compareTo(b.nameField!));
    return courses;
  }

  @override
  void initState() {
    super.initState();
    DatabaseService.getStudentField(
            FirebaseAuth.instance.currentUser!.email, 'Current Semester')
        .then((value) {
      setState(() {
        selectedSemester = value;
        coursesFuture = fetchCourses(selectedSemester);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ClassSchedulePage'),
      ),
      body: Center(
        child: Column(
          children: [
            MyDropdownMenuSemester(
              onSelectedItemChanged: (selectedItem) {
                setState(() {
                  selectedSemester = selectedItem;
                  coursesFuture = fetchCourses(selectedSemester);
                });
              },
            ),
            FutureBuilder<List<Course>>(
              future: coursesFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Course course = snapshot.data![index];
                        return ListTile(
                          title: Text(course.nameField!),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
