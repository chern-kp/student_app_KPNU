import 'package:flutter/material.dart';

class CalendarDialog extends StatelessWidget {
  final DateTime selectedDate;

  CalendarDialog({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selected Date'),
      content: Text(selectedDate.toString()),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
