// ignore_for_file: must_be_immutable, prefer_const_constructors, prefer_const_constructors_in_immutables

//todo combine with MyDropdownMenu

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'dropdownmenu_design.dart';

class DropdownMenuChooseSemester extends StatefulWidget {
  final Function(String) onSelectedItemChanged;
  final String? initialSemester;

  DropdownMenuChooseSemester({
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<String>? dataList = snapshot.data as List<String>?;
          return FutureBuilder<String?>(
            future: currentSemester,
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return CustomDropdown(
                  items: dataList!,
                  selectedItem: snapshot.data,
                  onChanged: (selectedItem) {
                    setState(() {
                      currentSemester = Future.value(selectedItem);
                    });
                    widget.onSelectedItemChanged(selectedItem!);
                  },
                  hintText: "Choose the faculty",
                );
              }
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
