// ignore_for_file: must_be_immutable, prefer_const_constructors, prefer_const_constructors_in_immutables

//todo combine with MyDropdownMenu

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';

class MyDropdownMenuSemester extends StatefulWidget {
  final Function(String) onSelectedItemChanged;

  MyDropdownMenuSemester({super.key, required this.onSelectedItemChanged});

  @override
  State<MyDropdownMenuSemester> createState() => _MyDropdownMenuSemesterState();
}

class _MyDropdownMenuSemesterState extends State<MyDropdownMenuSemester> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<List<String>> semesterList =
      DatabaseService.getSemesterList(user.email);
  late Future<String> currentSemester =
      DatabaseService.getStudentField(user.email, 'Current Semester');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //First future builder - until we get list of faculties, we will show CircularProgressIndicator
      future:
          semesterList, //when we get list of faculties, it will save to "snapshot" variable, and later will be used in dropdown menu
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //if problems with internet connection
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          //todo better error handling
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          //if everything is ok
          List<String>? dataList = snapshot.data;
          //Second future builder - we are getting selected faculty from student document, until we get it, we will show CircularProgressIndicator
          return FutureBuilder<String?>(
            future: currentSemester,
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                //todo better error handling
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
