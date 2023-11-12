import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../class/database_service.dart';
import '../components/my_dropdownmenu_semeter.dart';

class RecordBookPage extends StatefulWidget {
  const RecordBookPage({Key? key}) : super(key: key);

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
                  onSelectedItemChanged: updateSelectedSemester))
        ],
      ),
    );
  }
}
