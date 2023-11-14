class Student {
  String? emailField;
  String? firstNameField;
  String? lastNameField;
  String? facultyField;
  String? groupField;
  String? currentSemesterField;

  //constructor
  //when we creating new instance of class, we will pass these parameters, and they will be used in methods inside this class
  //data that we pass as parameters will be assigned to these variables and then will be used in methods
  Student(
      {this.emailField,
      this.firstNameField,
      this.lastNameField,
      this.facultyField,
      this.groupField,
      this.currentSemesterField});

  //here we name the fields in Firestore db and make so we can call them using "...Field" variables
  Map<String, dynamic> toJsonStudent() {
    return {
      'E-mail': emailField,
      'First Name': firstNameField,
      'Last Name': lastNameField,
      'Group': groupField,
      'Faculty': facultyField,
      'Current Semester': currentSemesterField,
    };
  }

  Student.fromJson(Map<String, dynamic> json) {
    emailField = json['E-mail'];
    firstNameField = json['First Name'];
    lastNameField = json['Last Name'];
    groupField = json['Group'];
    facultyField = json['Faculty'];
    currentSemesterField = json['CurrentSemester'];
  }
}

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

  Course({
    this.nameField,
    this.semesterField,
    this.hoursLectionsField,
    this.hoursPracticesField,
    this.hoursLabsField,
    this.hoursCourseworkField,
    this.hoursIndividualTotalField,
    this.hoursOverallTotalField,
  }) {
    hoursInClassTotalField = calculateTotalHoursInClass();
    hoursOverallTotalField = calculateTotalHoursOverall();
    creditsOverallTotalField = calculateTotalCredits();
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
      return (hoursOverallTotalField! / 30);
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
  }
}
