import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  String? nameField;
  String? semesterField;
  num? hoursLectionsField;
  num? hoursPracticesField;
  num? hoursLabsField;
  num? hoursCourseworkField;
  num? hoursInClassTotalField;
  num? hoursIndividualTotalField;
  num? hoursOverallTotalField;
  num? creditsOverallTotalField;
  String? scoringTypeField;
  String? recordBookTeacherField;
  num? recordBookScoreField;
  DateTime? recordBookSelectedDateField;
  bool? isScheduleFilled;
  bool? isRecordBookFilled;
  bool? isClassScheduleOnly;
  bool? isEvent;

  Course({
    this.nameField,
    this.semesterField,
    this.hoursLectionsField,
    this.hoursPracticesField,
    this.hoursLabsField,
    this.hoursCourseworkField,
    this.hoursIndividualTotalField,
    this.hoursOverallTotalField,
    this.scoringTypeField,
    this.recordBookTeacherField,
    this.recordBookScoreField,
    this.recordBookSelectedDateField,
    this.isScheduleFilled,
    this.isRecordBookFilled,
    this.isClassScheduleOnly,
    this.isEvent,
  }) {
    hoursLectionsField = hoursLectionsField ?? 0;
    hoursPracticesField = hoursPracticesField ?? 0;
    hoursLabsField = hoursLabsField ?? 0;
    hoursCourseworkField = hoursCourseworkField ?? 0;
    hoursIndividualTotalField = hoursIndividualTotalField ?? 0;
    hoursOverallTotalField = hoursOverallTotalField ?? 0;
    hoursInClassTotalField = calculateTotalHoursInClass();
    hoursOverallTotalField = calculateTotalHoursOverall();
    creditsOverallTotalField = calculateTotalCredits();
    scoringTypeField = scoringTypeField ?? 'Залік';
    recordBookTeacherField = recordBookTeacherField ?? '';
    recordBookScoreField = recordBookScoreField ?? 0;
    recordBookSelectedDateField = recordBookSelectedDateField ?? DateTime.now();
    isScheduleFilled = isScheduleFilled ?? false;
    isRecordBookFilled = isRecordBookFilled ?? false;
    isClassScheduleOnly = isClassScheduleOnly ?? false;
    isEvent = isEvent ?? false;
  }

  Map<String, dynamic> toJsonCourse() {
    return {
      'Name': nameField,
      'Semester': semesterField,
      'Hours Lections': hoursLectionsField,
      'Hours Practices': hoursPracticesField,
      'Hours Labs': hoursLabsField,
      'Hours Coursework': hoursCourseworkField,
      'Hours In Class Total': hoursInClassTotalField,
      'Hours Individual Total': hoursIndividualTotalField,
      'Hours Overall Total': hoursOverallTotalField,
      'Credits Overall Total': creditsOverallTotalField,
      'Scoring Type': scoringTypeField,
      '(Record Book) Teacher': recordBookTeacherField,
      '(Record Book) Score': recordBookScoreField,
      '(Record Book) Date': recordBookSelectedDateField,
      '(app) isScheduleFilled': isScheduleFilled,
      '(app) isRecordBookFilled': isRecordBookFilled,
      '(app) isClassScheduleOnly': isClassScheduleOnly,
      '(app) isEvent': isEvent,
    };
  }

  Course.fromJsonCourse(Map<String, dynamic> json) {
    nameField = json['Name'];
    semesterField = json['Semester'];
    hoursLectionsField = json['Hours Lections'];
    hoursPracticesField = json['Hours Practices'];
    hoursLabsField = json['Hours Labs'];
    hoursCourseworkField = json['Hours Coursework'];
    hoursInClassTotalField = json['Hours In Class Total'];
    hoursIndividualTotalField = json['Hours Individual Total'];
    hoursOverallTotalField = json['Hours Overall Total'];
    creditsOverallTotalField = json['Credits Overall Total'];
    scoringTypeField = json['Scoring Type'];
    recordBookTeacherField = json['(Record Book) Teacher'];
    recordBookScoreField = json['(Record Book) Score'];
    recordBookSelectedDateField = json['(Record Book) Date'] != null
        ? (json['(Record Book) Date'] as Timestamp).toDate()
        : null;
    isScheduleFilled = json['(app) isScheduleFilled'];
    isRecordBookFilled = json['(app) isRecordBookFilled'];
    isClassScheduleOnly = json['(app) isClassScheduleOnly'];
    isEvent = json['(app) isEvent'];
  }

  void recalculateTotals() {
    hoursInClassTotalField = calculateTotalHoursInClass();
    hoursOverallTotalField = calculateTotalHoursOverall();
    creditsOverallTotalField = calculateTotalCredits();
  }

  num calculateTotalHoursInClass() {
    return (hoursLectionsField ?? 0) +
        (hoursPracticesField ?? 0) +
        (hoursLabsField ?? 0) +
        (hoursCourseworkField ?? 0);
  }

  num calculateTotalHoursOverall() {
    return (hoursInClassTotalField ?? 0) + (hoursIndividualTotalField ?? 0);
  }

  num calculateTotalCredits() {
    if (hoursOverallTotalField == null) {
      return 0;
    } else {
      return num.parse((hoursOverallTotalField! / 30).toStringAsFixed(2));
    }
  }
}
