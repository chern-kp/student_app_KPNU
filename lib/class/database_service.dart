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
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("student")
        .doc(user)
        .collection('semester')
        .get();
    List<String> semesterList = snapshot.docs.map((doc) => doc.id).toList();
    return semesterList;
  }

  // CREATE course
  static Future<void> createNewCourse(var user, Course course) async {
    var currentSemester = await getStudentField(user, 'Current Semester');
    final docRef = FirebaseFirestore.instance
        .collection("student")
        .doc(user)
        .collection("semester")
        .doc(currentSemester)
        .collection("Courses")
        .doc(course.nameField);
    return docRef.set(course.toJsonCourse());
  }

  // GET course by name
  static Future<Course> getCourseByName(
      String userEmail, String courseName) async {
    var currentSemester = await getStudentField(userEmail, 'Current Semester');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("student")
        .doc(userEmail)
        .collection("semester")
        .doc(currentSemester)
        .collection("Courses")
        .where('Name', isEqualTo: courseName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If there are multiple courses with the same name, this will return the first one.
      DocumentSnapshot snapshot = querySnapshot.docs.first;
      return Course.fromJsonCourse(snapshot.data() as Map<String, dynamic>);
    } else {
      throw Exception('Course not found');
    }
  }

// get all courses
  static Future<List<Course>> getAllCourses(
      String userEmail, String semester) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("student")
        .doc(userEmail)
        .collection("semester")
        .doc(semester)
        .collection("Courses")
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs
          .map((doc) =>
              Course.fromJsonCourse(doc.data() as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }

  static Future<void> deleteCourse(var user, String courseName) async {
    try {
      var currentSemester = await getStudentField(user, 'Current Semester');
      await FirebaseFirestore.instance
          .collection("student")
          .doc(user)
          .collection("semester")
          .doc(currentSemester)
          .collection("Courses")
          .doc(courseName) // Use course name as document ID
          .delete();
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }
}
