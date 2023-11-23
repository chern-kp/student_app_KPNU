// ignore_for_file: must_be_immutable, prefer_const_constructors, prefer_const_constructors_in_immutables

//todo combine with MyDropdownMenu

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';

class MyDropdownMenuSemester extends StatefulWidget {
  final Function(String) onSelectedItemChanged;
  final String? initialSemester;

  MyDropdownMenuSemester({
    Key? key,
    required this.onSelectedItemChanged,
    this.initialSemester,
  }) : super(key: key);

  @override
  State<MyDropdownMenuSemester> createState() => _MyDropdownMenuSemesterState();
}

class _MyDropdownMenuSemesterState extends State<MyDropdownMenuSemester> {
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
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<String>? dataList = snapshot.data;
          return FutureBuilder<String?>(
            future: currentSemester,
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return DropdownButton(
                  items: dataList?.map((String item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item.toString()),
                    );
                  }).toList(),
                  onChanged: (selectedItem) {
                    setState(() {
                      currentSemester = Future.value(selectedItem);
                    });
                    widget.onSelectedItemChanged(selectedItem!);
                  },
                  value: snapshot.data == "" ? null : snapshot.data,
                  hint: Text(snapshot.data == ""
                      ? "Choose the faculty"
                      : snapshot.data!),
                );
              }
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
