import 'package:cloud_firestore/cloud_firestore.dart';

import 'database_data.dart';

class DatabaseService {
  static Future<void> createStudentDocument(var user) {
    //path to the document "student" - "%user%"
    final docRef = FirebaseFirestore.instance.collection("student").doc(user);

    final Student studentInstance = Student(
        emailField: user,
        firstNameField: "",
        lastNameField: "",
        facultyField: "",
        groupField: "",
        currentSemesterField: "Semester 1");
    final json = studentInstance.toJsonStudent();
    return docRef.set(json).then((_) {
      return createSemesterCollection(user);
    });
  }

  //*Firestore - "student" collection - set/update the field of the document whe pass as parameter
  static Future<void> setStudentFields(
      var user, String value, String field) async {
    //path to the document "student" - "%user%"
    final docRef = FirebaseFirestore.instance.collection('student').doc(user);
    DocumentSnapshot snapshot = await docRef.get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    data[field] = value;
    await docRef.set(data);
  }

  //*Firestore - "student" collection - get the field of the document whe pass as parameter
  static Future<String> getStudentField(var user, String field) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('student').doc(user).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data[field];
    } else {
      return '';
    }
  }

  static Future<void> createSemesterCollection(var user) {
    List<Future> tasks = [];
    for (int i = 1; i <= 8; i++) {
      tasks.add(FirebaseFirestore.instance
          //*Firestore - "student" collection - "%user%" document - "semester" collection -
          .collection("student")
          .doc(user)
          .collection('semester')
          .doc('Semester $i')
          .set({"isEmpty?": true}));
    }
    return Future.wait(tasks);
  }

  static Future<bool> checkStudentDocument(var user) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("student").doc(user).get();
    return snapshot.exists;
  }

  static Future<List<String>> getFacultyList() async {
    //*Firestore - "university" collection - "faculty" document - "Faculty List" collection - get all documents to list of strings
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("university")
        .doc("faculty")
        .collection("Faculty List")
        .get();
    List<String> facultyList = snapshot.docs.map((doc) => doc.id).toList();
    return facultyList;
  }

  static Future<List<String>> getSemesterList(var user) async {
    //*Firestore - "university" collection - "faculty" document - "Faculty List" collection - get all documents to list of strings
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("student")
        .doc(user)
        .collection('semester')
        .get();
    List<String> semesterList = snapshot.docs.map((doc) => doc.id).toList();
    return semesterList;
  }

  static Future<void> createNewCourse(var user) async {
    var currentSemester = await getStudentField(user, 'Current Semester');
    print(currentSemester);
    final docRef = FirebaseFirestore.instance
        .collection("student")
        .doc(user)
        .collection("semester")
        .doc(currentSemester);
  }
  //todo
}
