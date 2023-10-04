// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';

class MyDropdownMenu extends StatefulWidget {
  final Future<List<String>> facultyList;
  late Future<String>
      selectedFaculty; //i need to pass late Future<String> selectedFaculty

  MyDropdownMenu(
      {super.key, required this.facultyList, required this.selectedFaculty});

  @override
  State<MyDropdownMenu> createState() => _MyDropdownMenuState();
}

class _MyDropdownMenuState extends State<MyDropdownMenu> {
  final user = FirebaseAuth.instance
      .currentUser!; //user here is the instance of class User from firebase auth package. To get the email address itself we use "user.email".

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //First future builder - until we get list of faculties, we will show CircularProgressIndicator
      future: widget
          .facultyList, //when we get list of faculties, it will save to "snapshot" variable, and later will be used in dropdown menu
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
            future: widget.selectedFaculty,
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
                    DatabaseService.setStudentFaculty(
                        user.email, selectedItem!);
                    setState(() {
                      widget.selectedFaculty = Future.value(selectedItem);
                    });
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
