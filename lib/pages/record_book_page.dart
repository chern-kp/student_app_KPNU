// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/pages/new_course_dialog.dart';

import '../class/database_service.dart';
import '../components/my_dropdownmenu_semeter.dart';

class RecordBookPage extends StatefulWidget {
  RecordBookPage({Key? key}) : super(key: key);

  @override
  State<RecordBookPage> createState() => _RecordBookPageState();
}

class _RecordBookPageState extends State<RecordBookPage> {
  late Future<String> selectedSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  String? selectedSemesterPage;
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);

  final user = FirebaseAuth.instance.currentUser!;

  List<Map<String, dynamic>> sampleData = [
    {
      'nameOfClass': 'Mathematics',
      'hours': 5,
      'credits': 3,
      'teacher': 'Mr. Smith',
      'points': 88,
      'rank': 1,
      'date': '2023-11-01'
    },
    {
      'nameOfClass': 'Physics',
      'hours': 4,
      'credits': 2,
      'teacher': 'Ms. Johnson',
      'points': 92,
      'rank': 2,
      'date': '2023-11-02'
    },
    {
      'nameOfClass': 'Chemistry',
      'hours': 3,
      'credits': 2,
      'teacher': 'Dr. Brown',
      'points': 85,
      'rank': 3,
      'date': '2023-11-03'
    },
    // Add more rows as needed
  ];

  @override
  void initState() {
    super.initState();
    selectedSemester.then((value) {
      setState(() {
        selectedSemesterPage = value;
      });
    });
  }

  void updateSelectedSemester(String selectedItem) {
    setState(() {
      selectedSemesterPage = selectedItem;
    });
  }

  Widget _addScoresButton() {
    return TextButton(
      child: Text('Add Scores'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog(
              isRecordBook: true,
            );
          },
        );
      },
    );
  }

  Widget _recordBookCell() {
    return Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey[200],
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
                Text('NAME'),
                Spacer(),
                Text(
                  'TEACHER',
                  textAlign: TextAlign.end,
                )
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
                  'Екзамен',
                  textAlign: TextAlign.end,
                )
              ],
            )
          ],
        ));
  }

  Widget _recordBookTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1),
        6: FlexColumnWidth(2),
      },
      children: [
        // First title row
        TableRow(
          children: [
            SizedBox(),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: Text('Amount')),
            ),
            SizedBox(),
            SizedBox(),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(child: Text('Score')),
            ),
            SizedBox(),
            SizedBox(),
          ],
        ),
        // Second title row
        TableRow(
          children: [
            Text('Name of class'),
            Text('Hours'),
            Text('Credits'),
            Text('Teacher'),
            Text('Points'),
            Text('Rank'),
            Text('Date'),
          ],
        ),
        ...sampleData.map((item) {
          return TableRow(
            children: [
              Text(item['nameOfClass'].toString()),
              Text(item['hours'].toString()),
              Text(item['credits'].toString()),
              Text(item['teacher'].toString()),
              Text(item['points'].toString()),
              Text(item['rank'].toString()),
              Text(item['date'].toString()),
            ],
          );
        }).toList(),
      ],
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
          _recordBookTable(),
          SizedBox(height: 40),
          _addScoresButton(),
          SizedBox(height: 40),
          _recordBookCell(),
        ],
      ),
    );
  }
}
