// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/dropdownmenu_design.dart';

class DropdownMenuUserSemester extends StatefulWidget {
  final String? chosenField;

  DropdownMenuUserSemester({super.key, required this.chosenField});

  @override
  State<DropdownMenuUserSemester> createState() =>
      _DropdownMenuUserSemesterState();
}

class _DropdownMenuUserSemesterState extends State<DropdownMenuUserSemester> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<List<String>> listOfData;
  late Future<String> chosenValueInDatabase;

  @override
  void initState() {
    super.initState();
    listOfData = DatabaseService.getSemesterList(user.email);
    chosenValueInDatabase =
        DatabaseService.getStudentField(user.email, widget.chosenField!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: listOfData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Помилка: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<String>? dataList = snapshot.data;
          return FutureBuilder<String?>(
            future: chosenValueInDatabase,
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Помилка: ${snapshot.error}');
              } else {
                return DropdownMenuDesign(
                  items: dataList!,
                  selectedItem: snapshot.data == "" ? null : snapshot.data,
                  onChanged: (selectedItem) {
                    DatabaseService.setStudentFields(
                        user.email, selectedItem!, widget.chosenField!);
                    setState(() {
                      chosenValueInDatabase = Future.value(selectedItem);
                    });
                  },
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
