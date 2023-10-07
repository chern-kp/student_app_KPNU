import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static Future<void> createStudentDocument(var user) {
    //we use static keyword so we could call this method without creating an instance
    return FirebaseFirestore.instance.collection("student").doc(user).set({
      //Firestore - "student" collection - "%user%" document -
      "E-mail": user,
      "First Name": "",
      "Last Name": "",
      "Faculty": "",
      "Group": "",
      "Current Semester": "Semester 1",
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

  //*Firestore - "student" collection - set/update the field of the document whe pass as parameter
  static Future<void> setStudentFields(
      var user, String value, String field) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('student').doc(user);
    DocumentSnapshot snapshot = await docRef.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      data[field] = value;
      await docRef.set(data);
    }
  }
}
