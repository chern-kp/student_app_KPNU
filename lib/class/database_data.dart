class Student {
  String email;
  String firstName;
  String lastName;
  String faculty;
  String group;

  Student({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.faculty,
    required this.group,
  });

  factory Student.fromFirestore(Map<String, dynamic> firestoreData) {
    return Student(
      email: firestoreData['E-mail'],
      firstName: firestoreData['First Name'],
      lastName: firestoreData['Last Name'],
      faculty: firestoreData['Faculty'],
      group: firestoreData['Group'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'E-mail': email,
      'First Name': firstName,
      'Last Name': lastName,
      'Faculty': faculty,
      'Group': group,
    };
  }
}
