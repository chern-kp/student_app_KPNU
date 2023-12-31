import 'package:cloud_firestore/cloud_firestore.dart';

class EventSchedule {
  String? eventName;
  String? eventType;
  DateTime? eventDateStart;
  DateTime? eventDateEnd;

  EventSchedule({
    this.eventName,
    this.eventType,
    this.eventDateStart,
    this.eventDateEnd,
  }) {
    eventName = eventName ?? '';
    eventType = eventType ?? '';
    eventDateStart = eventDateStart ??
        DateTime.fromMillisecondsSinceEpoch(978307200000, isUtc: true);
    eventDateEnd = eventDateEnd ??
        DateTime.fromMillisecondsSinceEpoch(978307200000, isUtc: true);
  }

  Map<String, dynamic> toJsonEvent() {
    Map<String, dynamic> json = {
      'Event Name': eventName,
      'Event Type': eventType,
    };

    if (eventDateStart != null) {
      json['Event Date'] = eventDateStart;
    }

    if (eventDateEnd != null) {
      json['Event Date End'] = eventDateEnd;
    }

    return json;
  }

  EventSchedule.fromJsonEvent(Map<String, dynamic> json) {
    eventName = json['Event Name'];
    eventType = json['Event Type'];
    eventDateStart = json['Event Date'] != null
        ? (json['Event Date'] as Timestamp).toDate()
        : null;
    eventDateEnd = json['Event Date End'] != null
        ? (json['Event Date End'] as Timestamp).toDate()
        : null;
  }
}
