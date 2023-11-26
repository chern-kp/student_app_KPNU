import 'package:cloud_firestore/cloud_firestore.dart';

class EventSchedule {
  String? eventName;
  String? eventType;
  DateTime? eventDate;

  EventSchedule({
    this.eventName,
    this.eventType,
    this.eventDate,
  }) {
    eventName = eventName ?? '';
    eventType = eventType ?? '';
    eventDate = eventDate ?? DateTime.now();
  }

  Map<String, dynamic> toJsonEvent() {
    return {
      'Event Name': eventName,
      'Event Type': eventType,
      'Event Date': eventDate,
    };
  }

  EventSchedule.fromJsonEvent(Map<String, dynamic> json) {
    eventName = json['Event Name'];
    eventType = json['Event Type'];
    eventDate = json['Event Date'] != null
        ? (json['Event Date'] as Timestamp).toDate()
        : null;
  }
}
