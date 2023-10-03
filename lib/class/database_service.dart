import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/class/database_data.dart';

class DatabaseService {
  static Future<void> createStudentDocument(var user /* email of user */) {
    //we use static keyword so we could call this method without creating an instance
    return FirebaseFirestore.instance.collection("student").doc(user).set({
      //*Firestore - "student" collection - "%user%" document -
      "E-mail": user,
      "First Name": "",
      "Last Name": "",
      "Faculty": "",
      "Group": "",
    }).then((_) {
      return createSemesterCollection(user);
    });
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

  static Future<String> getStudentFaculty(var user) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('student').doc(user).get();

    if (snapshot.exists) {
      Student student =
          Student.fromFirestore(snapshot.data() as Map<String, dynamic>);
      return student.faculty;
    } else {
      return '';
    }
  }
}
