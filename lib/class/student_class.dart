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
