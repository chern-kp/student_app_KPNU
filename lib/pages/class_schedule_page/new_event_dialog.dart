// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_app/class/database_service.dart';
import 'package:student_app/class/event_class.dart';
import '../../components/my_datepicker.dart';
import '../../components/dropdownmenu_choose_semester.dart';

class NewEventDialog extends StatefulWidget {
  NewEventDialog({
    this.onUpdate,
    this.isEdit = false,
    this.event,
    this.selectedSemester,
    Key? key,
  }) : super(key: key);

  final Function? onUpdate;
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
  DateTime? eventDateStart;
  DateTime? eventDateEnd;
  String? selectedScoringType = 'Інше';

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
      child: const Text('Зберегти', style: TextStyle(color: Colors.brown)),
      onPressed: () async {
        try {
          String eventType;
          if (selectedScoringType == 'Інше') {
            eventType = eventTypeController.text.isEmpty
                ? 'Інше'
                : eventTypeController.text;
          } else {
            eventType = selectedScoringType!;
          }

          EventSchedule newEvent = EventSchedule(
            eventName: eventNameController.text,
            eventType: eventType,
            eventDateStart: eventDateStart,
            eventDateEnd: eventDateEnd,
          );
          await DatabaseService.createOrUpdateEvent(
            user.email,
            newEvent,
            selectedSemesterPage!,
          );
          if (widget.onUpdate != null) {
            widget.onUpdate!();
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Помилка'),
                content: Text(e.toString()),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Закрити'),
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(widget.isEdit ? 'Змінити подію' : 'Додати нову подію'),
            const SizedBox(height: 5),
            DropdownMenuChooseSemester(
              initialSemester: selectedSemesterPage,
              onSelectedItemChanged: (selectedItem) {
                setState(() {
                  selectedSemesterPage = selectedItem;
                });
              },
            ),
            TextField(
              controller: eventNameController,
              decoration: const InputDecoration(
                labelText: 'Назва',
              ),
            ),
            DropdownButton<String>(
              value: selectedScoringType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedScoringType = newValue;
                });
              },
              items: <String>['Екзамен', 'Залік', 'Інше']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: eventTypeController,
              decoration: const InputDecoration(
                labelText: 'Тип',
              ),
              enabled: selectedScoringType == 'Інше',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('Дата початку'),
                  onPressed: () async {
                    eventDateStart = await selectDate(context);
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      eventDateStart = null;
                    });
                  },
                ),
              ],
            ),
            Text(eventDateStart != null
                ? '${eventDateStart!.year.toString().padLeft(4, '0')}-${eventDateStart!.month.toString().padLeft(2, '0')}-${eventDateStart!.day.toString().padLeft(2, '0')} ${eventDateStart!.hour.toString().padLeft(2, '0')}:${eventDateStart!.minute.toString().padLeft(2, '0')}'
                : ''),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text('Дата кінця'),
                  onPressed: () async {
                    eventDateEnd = await selectDate(context);
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      eventDateEnd = null;
                    });
                  },
                ),
              ],
            ),
            Text(eventDateEnd != null
                ? '${eventDateEnd!.year.toString().padLeft(4, '0')}-${eventDateEnd!.month.toString().padLeft(2, '0')}-${eventDateEnd!.day.toString().padLeft(2, '0')} ${eventDateEnd!.hour.toString().padLeft(2, '0')}:${eventDateEnd!.minute.toString().padLeft(2, '0')}'
                : ''),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Закрити', style: TextStyle(color: Colors.brown)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        _saveButton(context),
      ],
    );
  }
}
