import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/class/event_class.dart';
import '../../components/my_dropdownmenu_semeter.dart';

class NewEventDialog extends StatefulWidget {
  const NewEventDialog({Key? key}) : super(key: key);

  @override
  _NewEventDialogState createState() => _NewEventDialogState();
}

class _NewEventDialogState extends State<NewEventDialog> {
  final user = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  String eventName = '';
  String eventType = '';
  String? selectedSemesterPage;

  TextButton _saveButton(BuildContext context) {
    return TextButton(
      child: Text('Add'),
      onPressed: () async {
        if (_formKey.currentState!.validate() && selectedSemesterPage != null) {
          EventSchedule newEvent = EventSchedule(
            eventName: eventName,
            eventType: eventType,
          );
          await DatabaseService.createOrUpdateEvent(
              user.email, newEvent, selectedSemesterPage!);
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Event'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MyDropdownMenuSemester(
              onSelectedItemChanged: (selectedItem) {
                setState(() {
                  selectedSemesterPage = selectedItem;
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Event Name'),
              onChanged: (value) {
                setState(() {
                  eventName = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event name';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Event Type'),
              onChanged: (value) {
                setState(() {
                  eventType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter event type';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        _saveButton(context),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
