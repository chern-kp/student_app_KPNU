import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/class/event_class.dart';
import '../../components/my_dropdownmenu_semeter.dart';

class NewEventDialog extends StatefulWidget {
  NewEventDialog({
    this.isEdit = false,
    this.event,
    this.selectedSemester,
    Key? key,
  }) : super(key: key);

  bool isEdit;
  final EventSchedule? event;
  final String? selectedSemester;

  @override
  State<NewEventDialog> createState() => _NewEventDialogState();
}

class _NewEventDialogState extends State<NewEventDialog> {
  final user = FirebaseAuth.instance.currentUser!;
  final eventNameController = TextEditingController();
  final eventTypeController = TextEditingController();
  String? selectedSemesterPage;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.event != null) {
      eventNameController.text = widget.event!.eventName ?? '';
      eventTypeController.text = widget.event!.eventType ?? '';
    }
    selectedSemesterPage = widget.selectedSemester;
  }

  TextButton _saveButton(BuildContext context) {
    return TextButton(
      child: Text('Save'),
      onPressed: () async {
        try {
          EventSchedule newEvent = EventSchedule(
            eventName: eventNameController.text,
            eventType: eventTypeController.text,
          );
          await DatabaseService.createOrUpdateEvent(
            user.email,
            newEvent,
            selectedSemesterPage!,
          );
          Navigator.of(context).pop(true);
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(e.toString()),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MyDropdownMenuSemester(
              initialSemester: selectedSemesterPage,
              onSelectedItemChanged: (selectedItem) {
                setState(() {
                  selectedSemesterPage = selectedItem;
                });
              },
            ),
            TextField(
              controller: eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
              ),
            ),
            TextField(
              controller: eventTypeController,
              decoration: InputDecoration(
                labelText: 'Event Type',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        _saveButton(context),
      ],
    );
  }
}
