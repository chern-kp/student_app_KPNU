import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app/class/course_class.dart';
import 'package:student_app/class/event_class.dart';

class DatabaseService {
  static Future<void> createStudentDocument(var user) {
    //шлях до документу "student" - "%user%"
    final docRef = FirebaseFirestore.instance.collection("student").doc(user);
    final Map<String, dynamic> studentData = {
      'E-mail': user,
      'Current Semester': "Семестр 1"
    };
    return docRef.set(studentData).then((_) {
      return createSemesterCollection(user);
    });
  }

  static Future<void> createSemesterCollection(var user) {
    List<Future> tasks = [];
    for (int i = 1; i <= 8; i++) {
      tasks.add(FirebaseFirestore.instance
          .collection("student")
          .doc(user)
          .collection('semester')
          .doc('Семестр $i')
          .set({}));
    }
    return Future.wait(tasks);
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

  static Future<bool> checkStudentDocument(var user) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("student").doc(user).get();
    return snapshot.exists;
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

  // CREATE
  static Future<void> createOrUpdateCourse(
      var user, Course course, String semester) async {
    if (course.nameField!.trim().isEmpty) {
      throw Exception('Назва курсу не може бути порожньою!');
    }
    final docRef = FirebaseFirestore.instance
        .collection("student")
        .doc(user)
        .collection("semester")
        .doc(semester)
        .collection("Courses")
        .doc(course.nameField);
    return docRef.set(course.toJsonCourse());
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
          .doc(courseName)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createOrUpdateEvent(
      var user, EventSchedule event, String semester) async {
    if (event.eventName!.trim().isEmpty) {
      throw Exception('Назва події не може бути порожньою!');
    }
    final docRef = FirebaseFirestore.instance
        .collection("student")
        .doc(user)
        .collection("semester")
        .doc(semester)
        .collection("Events")
        .doc(event.eventName);
    return docRef.set(event.toJsonEvent());
  }

  static Future<void> deleteEvent(var user, String eventName) async {
    try {
      var currentSemester = await getStudentField(user, 'Current Semester');
      await FirebaseFirestore.instance
          .collection("student")
          .doc(user)
          .collection("semester")
          .doc(currentSemester)
          .collection("Events")
          .doc(eventName) // Use event name as document ID
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<EventSchedule>> getAllEvents(
      String userEmail, String semester) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("student")
        .doc(userEmail)
        .collection("semester")
        .doc(semester)
        .collection("Events")
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs
          .map((doc) =>
              EventSchedule.fromJsonEvent(doc.data() as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }
}
