// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/components/dropdownmenu_design.dart';

class DropdownMenuUserSemester extends StatefulWidget {
  final Future<List<String>> listOfData;
  late Future<String> chosenValueInDatabase;
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
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.listOfData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Помилка: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<String>? dataList = snapshot.data;
          return FutureBuilder<String?>(
            future: widget.chosenValueInDatabase,
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
                      widget.chosenValueInDatabase = Future.value(selectedItem);
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
