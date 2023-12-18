import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../class/course_class.dart';
import '../../class/database_service.dart';
import '../../class/event_class.dart';
import '../new_course_dialog.dart';
import 'new_event_dialog.dart';

class ClassListView extends StatefulWidget {
  final List<dynamic> combinedList;
  final Function updateState;
  final User? user;
  final String? selectedSemester;

  const ClassListView({
    Key? key,
    required this.combinedList,
    required this.updateState,
    this.user,
    this.selectedSemester,
  }) : super(key: key);

  @override
  State<ClassListView> createState() => _ClassListViewState();
}

class _ClassListViewState extends State<ClassListView> {
  bool isDefaultDate(DateTime? date) {
    return date!.millisecondsSinceEpoch == 978307200000;
  }

  void showDeleteDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Видалити елемент?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item is Course)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Builder(
                        builder: (context) => ElevatedButton(
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: const Center(
                              child: Text('Видалити зі сторінки',
                                  textAlign: TextAlign.center)),
                          onPressed: () async {
                            item.isEvent = false;
                            await DatabaseService.createOrUpdateCourse(
                                widget.user!.email!,
                                item,
                                widget.selectedSemester!);
                            widget.updateState();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(
                      builder: (context) => ElevatedButton(
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: const Center(
                            child: Text('Повністтю видалити елемент',
                                textAlign: TextAlign.center)),
                        onPressed: () async {
                          if (item is Course) {
                            await DatabaseService.deleteCourse(
                                widget.user!.email!, item.nameField!);
                          } else if (item is EventSchedule) {
                            await DatabaseService.deleteEvent(
                                widget.user!.email!, item.eventName!);
                          }
                          widget.updateState();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              child:
                  const Text('Закрити', style: TextStyle(color: Colors.brown)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildListView(List<dynamic> combinedList) {
    return SingleChildScrollView(
      child: Column(
        children: widget.combinedList.map((item) {
          return _buildListItem(item);
        }).toList(),
      ),
    );
  }

  Widget _buildListItem(dynamic item) {
    if (item is Course) {
      String subtitle =
          'Дата і час: ${item.recordBookSelectedDateField?.year.toString().padLeft(4, '0')}-${item.recordBookSelectedDateField?.month.toString().padLeft(2, '0')}-${item.recordBookSelectedDateField?.day.toString().padLeft(2, '0')} ${item.recordBookSelectedDateField?.hour.toString().padLeft(2, '0')}:${item.recordBookSelectedDateField?.minute.toString().padLeft(2, '0')}\nТип: ${item.scoringTypeField!}';
      return _buildListItemDesign(item.nameField!, subtitle, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewCourseDialog(
              isClassSchedule: true,
              isRecordBook: false,
              currentSemester: widget.selectedSemester,
              isEdit: true,
              course: item,
            );
          },
        );
      }, () {
        showDeleteDialog(context, item);
      }, item);
    } else if (item is EventSchedule) {
      String subtitle = 'Тип: ${item.eventType!}';
      if (!isDefaultDate(item.eventDateStart)) {
        subtitle +=
            '\nДата і час початку: ${item.eventDateStart?.year.toString().padLeft(4, '0')}-${item.eventDateStart?.month.toString().padLeft(2, '0')}-${item.eventDateStart?.day.toString().padLeft(2, '0')} ${item.eventDateStart?.hour.toString().padLeft(2, '0')}:${item.eventDateStart?.minute.toString().padLeft(2, '0')}';
      }
      if (!isDefaultDate(item.eventDateEnd)) {
        subtitle +=
            '\nДата і час кінця: ${item.eventDateEnd?.year.toString().padLeft(4, '0')}-${item.eventDateEnd?.month.toString().padLeft(2, '0')}-${item.eventDateEnd?.day.toString().padLeft(2, '0')} ${item.eventDateEnd?.hour.toString().padLeft(2, '0')}:${item.eventDateEnd?.minute.toString().padLeft(2, '0')}';
      }
      return _buildListItemDesign(item.eventName!, subtitle, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewEventDialog(
              isEdit: true,
              event: item,
              selectedSemester: widget.selectedSemester,
              onUpdate: widget.updateState,
            );
          },
        );
      }, () {
        showDeleteDialog(context, item);
      }, item);
    } else {
      throw Exception('Unknown type in combinedList');
    }
  }

  Widget _buildListItemDesign(String title, String subtitle, Function onEdit,
      Function onDelete, dynamic item) {
    BorderRadius borderRadius = BorderRadius.circular(8.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        elevation: 5.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[700]!,
              width: 2,
            ),
            borderRadius: borderRadius,
          ),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView(widget.combinedList);
  }
}
