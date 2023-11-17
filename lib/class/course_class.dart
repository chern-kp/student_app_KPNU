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
  }
}
