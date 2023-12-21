import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/class_schedule_page/class_schedule_page.dart';
import 'courses_schedule_page.dart';
import 'record_book_page.dart';
import '../class/database_service.dart';
import '../components/dropdownmenu_user_semester.dart';
import '../components/my_button.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<List<String>> facultyList;
  late Future<String> selectedSemester;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    facultyList = DatabaseService.getSemesterList(user.email);
    selectedSemester =
        DatabaseService.getStudentField(user.email, 'Current Semester');
    await Future.wait([facultyList, selectedSemester]);
    setState(() {
      isLoading = false;
    });
  }

  void coursesSchedulePageButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CoursesSchedulePage()),
    );
  }

  void recordBookPageButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecordBookPage()),
    );
  }

  void classSchedulePageButton(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClassSchedulePage()),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Column(
            children: [
              const Text("Ви увійшли як:", style: TextStyle(fontSize: 16)),
              Text(user.email!,
                  style: TextStyle(fontSize: 18, color: Colors.blue[700])),
            ],
          ),
          const SizedBox(height: 25),
          const Text('Оберіть поточний семестр:',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownMenuUserSemester(
            chosenField: 'Current Semester',
          ),
          const SizedBox(height: 75),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyButton(
              onTap: () => coursesSchedulePageButton(context),
              text: 'Індивідуальний Навчальний План',
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyButton(
              onTap: () => recordBookPageButton(context),
              text: 'Залікова Книжка Студента',
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyButton(
              onTap: () => classSchedulePageButton(context),
              text: 'Графік Освітнього Процесу',
            ),
          ),
        ],
      ),
    );
  }
}
