import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static Future<void> createStudentDocument(var user /* email of user */) {
    //we use static keyword so we could call this method without creating an instance
    return FirebaseFirestore.instance.collection("student").doc(user).set({
      //*Firebase - "%user%" document -
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
          //*Firebase - "%user%" document - "semester" collection -
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
}
