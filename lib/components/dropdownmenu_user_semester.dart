import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/dropdownmenu_design.dart';

class DropdownMenuUserSemester extends StatefulWidget {
  final Future<List<String>> listOfData;
  late Future<String>
      chosenValueInDatabase; //i need to pass late Future<String> selectedFaculty
  final String? chosenField;

  DropdownMenuUserSemester(
      {super.key,
      required this.listOfData,
      required this.chosenValueInDatabase,
      required this.chosenField});

  @override
  State<DropdownMenuUserSemester> createState() =>
      _DropdownMenuUserSemesterState();
}

class _DropdownMenuUserSemesterState extends State<DropdownMenuUserSemester> {
  final user = FirebaseAuth.instance
      .currentUser!; //user here is the instance of class User from firebase auth package. To get the email address itself we use "user.email".

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //First future builder - until we get list of faculties, we will show CircularProgressIndicator
      future: widget
          .listOfData, //when we get list of faculties, it will save to "snapshot" variable, and later will be used in dropdown menu
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //if problems with internet connection
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          //todo better error handling
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          //if everything is ok
          List<String>? dataList = snapshot.data;
          //Second future builder - we are getting selected faculty from student document, until we get it, we will show CircularProgressIndicator
          return FutureBuilder<String?>(
            future: widget.chosenValueInDatabase,
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return DropdownMenuDesign(
                  items: dataList!,
                  selectedItem: snapshot.data == "" ? null : snapshot.data,
                  onChanged: (selectedItem) {
                    DatabaseService.setStudentFields(
                        user.email, selectedItem!, widget.chosenField!);
                    setState(() {
                      widget.chosenValueInDatabase = Future.value(selectedItem);
                    });
                  },
                  hintText: widget.chosenField == 'Faculty'
                      ? (snapshot.data == ""
                          ? "Choose the faculty"
                          : snapshot.data!)
                      : (widget.chosenField == 'Current Semester'
                          ? (snapshot.data == ""
                              ? "Current Semester"
                              : snapshot.data!)
                          : ''),
                );
              }
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
