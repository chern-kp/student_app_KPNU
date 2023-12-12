import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'dropdownmenu_design.dart';

class DropdownMenuChooseSemester extends StatefulWidget {
  final Function(String) onSelectedItemChanged;
  final String? initialSemester;

  const DropdownMenuChooseSemester({
    Key? key,
    required this.onSelectedItemChanged,
    this.initialSemester,
  }) : super(key: key);

  @override
  State<DropdownMenuChooseSemester> createState() =>
      _DropdownMenuChooseSemesterState();
}

class _DropdownMenuChooseSemesterState
    extends State<DropdownMenuChooseSemester> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);
  late Future<String> currentSemester = widget.initialSemester != null
      ? Future.value(widget.initialSemester)
      : DatabaseService.getStudentField(user.email, 'Current Semester');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: semesterList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Помилка: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<String>? dataList = snapshot.data;
          return FutureBuilder<String?>(
            future: currentSemester,
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Помилка: ${snapshot.error}'));
              } else {
                return DropdownMenuDesign(
                  items: dataList!,
                  selectedItem: snapshot.data,
                  onChanged: (selectedItem) {
                    setState(() {
                      currentSemester = Future.value(selectedItem);
                    });
                    widget.onSelectedItemChanged(selectedItem!);
                  },
                );
              }
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
