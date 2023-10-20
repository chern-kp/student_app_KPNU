// ignore_for_file: must_be_immutable, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/my_dropdownmenu_semeter.dart';

import 'new_course_dialog.dart';

class CoursesSchedulePage extends StatefulWidget {
  CoursesSchedulePage({Key? key}) : super(key: key);

  @override
  State<CoursesSchedulePage> createState() => _CoursesSchedulePageState();
}

class _CoursesSchedulePageState extends State<CoursesSchedulePage> {
  final user = FirebaseAuth.instance.currentUser!;

  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);

  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  String? selectedSemesterPage;
  void updateSelectedSemester(String selectedItem) {
    setState(() {
      selectedSemesterPage = selectedItem;
    });
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
    return ListView.builder(
      itemCount: yourData.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(yourData[index]['isExpanded']
                          ? Icons.expand_less
                          : Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          yourData[index]['isExpanded'] =
                              !yourData[index]['isExpanded'];
                        });
                      },
                    ),
                    Text('Title ${index + 1}'),
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
                        // todo delete func
                      },
                    ),
                  ],
                ),
              ),
              if (yourData[index]['isExpanded'])
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Unfolded text',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

//temp
  List<Map<String, dynamic>> yourData = List.generate(5, (index) {
    return {
      'Item': 'Item ${index + 1}',
      'Property 1': 'Item ${index + 1} Property 1',
      'Property 2': 'Item ${index + 1} Property 2',
      'isExpanded': false,
    };
  });

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
