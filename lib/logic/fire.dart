import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

final Firestore _firestore = Firestore();

class Fire {
  // void createStudentAccount({String userUid, String email, String userName
  //     //String school,
  //     //String studentId,
  //     }) {
  //   _firestore.collection('students').document(userUid).setData(
  //     {
  //       'email': email,
  //       'user name': userName,
  //       //'school': school,
  //       //'student id': studentId,
  //       'selected class': 'no selected class',
  //     },
  //   );
  // }

  void createStudentAccount({String userUid, String email, String userName}) {
    _firestore.collection('user data').document(userUid).setData({
      'email': email,
      'display-name': userName,
      'selected class': 'no selected class',
      'Account Status': 'Activated',
      'Account Type': 'Student',
      //idk what use name is - on website it is email
      'username': email,
    });
  }

  // void createTeacherAccount({
  //   String userUid,
  //   String email,
  //   String userName,
  //   //String school,
  //   //String professionalName,
  // }) {
  //   _firestore.collection('teachers').document(userUid).setData(
  //     {
  //       'email': email,
  //       'user name': userName,
  //       'selected class': 'no selected class',
  //       'student display name': userName,
  //       //'professional name': professionalName,
  //     },
  //   );
  // }

  void createTeacherAccount({String userUid, String email, String userName}) {
    _firestore.collection('user data').document(userUid).setData({
      'email': email,
      'username': email,
      'display-name': userName,
      'selected class': 'no selected class',
      'Account Status': 'Activated',
      'Account Type': 'Teacher',
    });
  }

  // Future<String> getLoginType({
  //   String email,
  // }) async {
  //   try {
  //     String teacherQueryResult = await _firestore
  //         .collection('teachers')
  //         .where('email', isEqualTo: email)
  //         .getDocuments()
  //         .then(
  //           (querySnap) => querySnap.documents[0].documentID.toString(),
  //         );
  //     print(
  //       'teacher result ' + teacherQueryResult.toString(),
  //     );
  //     return 'teacher';
  //   } catch (e) {
  //     return 'student';
  //   }
  // }

  Future<String> getLoginType({String email}) async {
    try {
      String queryResult = await _firestore
          .collection('UserData')
          .where('email', isEqualTo: email)
          .where('Account Type', isEqualTo: 'Teacher')
          .getDocuments()
          .then(
              (querySnap) => querySnap.documents[0]['Account Type'].toString());
      return 'teacher';
    } catch (e) {
      String queryResult = await _firestore
          .collection('UserData')
          .where('email', isEqualTo: email)
          .where('Account Type', isEqualTo: 'Student')
          .getDocuments()
          .then(
              (querySnap) => querySnap.documents[0]['Account Type'].toString());
      if (queryResult == 'Student') {
        return 'student';
      } else {
        return 'no account with this email';
      }
    }
  }

  // void updateStudentMood({
  //   String studentUid,
  //   String classId,
  //   String newMood,
  // }) {
  //   _firestore
  //       .collection('students')
  //       .document(studentUid)
  //       .collection('classes')
  //       .document(classId)
  //       .updateData({
  //     'mood': newMood,
  //     'date': DateFormat.yMMMMd('en_US').format(
  //       DateTime.now(),
  //     ),
  //   });

  // _firestore
  //     .collection('classes')
  //     .document(classId)
  //     .collection('students')
  //     .document(studentUid)
  //     .updateData(
  //   {
  //     'mood': newMood,
  //     'date': DateFormat.yMMMMd('en_US').format(
  //       DateTime.now(),
  //     ),
  //   },
  // );

  void updateStudentMood({String studentUid, String classId, String newMood}) {
    _firestore
        .collection('UserData')
        .document(studentUid)
        .collection('Classes')
        .document(classId)
        .updateData({
      'mood': newMood,
      'date': DateFormat.yMMMMd('en_US').format(
        DateTime.now(),
      ),
    });

    _firestore
        .collection('Classes')
        .document(classId)
        .collection('Students')
        .document(studentUid)
        .updateData({
      'mood': newMood,
      'date': DateFormat.yMMMMd('en_US').format(
        DateTime.now(),
      )
    });
  }

  // void setStudentSelectedClass({
  //   String studentUid,
  //   String classId,
  // }) {
  //   _firestore.collection('students').document(studentUid).updateData(
  //     {'selected class': classId},
  //   );
  // }

  void setStudentSelectedClass({String studentUid, String classId}) {
    _firestore
        .collection('UserData')
        .document(studentUid)
        .updateData({'selected class': classId});
  }

  // void setTeacherSelectedClass({String teacherUid, String classId}) {
  //   _firestore.collection('teachers').document(teacherUid).updateData(
  //     {'selected class': classId},
  //   );
  // }

  void setTeacherSelectedClass({String teacherUid, String classId}) {
    _firestore
        .collection('UserData')
        .document(teacherUid)
        .updateData({'selected class': classId});
  }

  // void createClass({
  //   String teacherUid,
  //   String className,
  //   String classId,
  //   String teacherName,
  // }) {
  //   var _randomString = randomAlphaNumeric(30);
  //   _firestore.collection('classes').document(_randomString).setData({
  //     'class name': className,
  //     'teacher': teacherName,
  //   });

  //   _firestore
  //       .collection('teachers')
  //       .document(teacherUid)
  //       .collection('classes')
  //       .document(_randomString)
  //       .setData(
  //     {
  //       'class name': className,
  //       'class id': classId,
  //     },
  //   );
  // }

  void createClass({String teacherUid, String className, String teacherName}) {
    var _randomString = randomAlphaNumeric(30);
    int _classCode = int.parse(randomNumeric(5)).toInt();

    _firestore.collection('classes').document(_randomString).setData({
      'ClassName': className,
      'class id': _randomString,
      'Code': _classCode.toString(),
      'teacher': teacherName,
    });

    _firestore
        .collection('UserData')
        .document(teacherUid)
        .collection('Classes')
        .document(_randomString)
        .setData({
      'ClassName': className,
      'class id': _randomString,
      'Code': _classCode.toString(),
    });

    _firestore
        .collection('UserData')
        .document(teacherUid)
        .setData({'selected class': _randomString});
  }

  // Future<String> inviteStudent({
  //   String studentEmail,
  //   String classId,
  //   String teacherName,
  //   String className,
  // }) async {
  //   try {
  //     String studentUid = await _firestore
  //         .collection('students')
  //         .where('email', isEqualTo: studentEmail)
  //         .getDocuments()
  //         .then(
  //           (querySnap) => querySnap.documents[0].documentID.toString(),
  //         );

  //     _firestore
  //         .collection('students')
  //         .document(studentUid)
  //         .collection('invitations')
  //         .document(classId)
  //         .setData({
  //       'teacher name': teacherName,
  //       'class name': className,
  //       'class id': classId,
  //     });
  //     return 'success';
  //   } catch (e) {
  //     return 'fail';
  //   }
  // }

  // Future<String> inviteStudent(
  //     {String studentEmail,
  //     String classId,
  //     String teacherName,
  //     String className}) async {
  //   try {
  //     String studentUid = await _firestore
  //         .collection('user data')
  //         .where('email', isEqualTo: studentEmail)
  //         .where('account type', isEqualTo: 'student')
  //         .getDocuments()
  //         .then(
  //           (querySnap) => querySnap.documents[0].documentID.toString(),
  //         );

  //     _firestore
  //         .collection('user data')
  //         .document(studentUid)
  //         .collection('invitations')
  //         .document(classId)
  //         .setData({
  //       'teacher name': teacherName,
  //       'class name': className,
  //       'class id': classId,
  //     });
  //     return 'success';
  //   } catch (e) {
  //     return 'fail';
  //   }
  // }

  // Future acceptInvitation(
  //     {String classId,
  //     String studentUid,
  //     String studentName,
  //     String className}) {
  //   print('trying to accept invite');
  //   //add to a student to the class
  //   _firestore
  //       .collection('classes')
  //       .document(classId)
  //       .collection('students')
  //       .document(studentUid)
  //       .setData({
  //     'date': DateFormat.yMMMMd('en_US').format(
  //       DateTime.now(),
  //     ),
  //     'mood': 'green',
  //     'student name': studentName,
  //   });

  //   //remove invite out of students
  //   _firestore
  //       .collection('students')
  //       .document(studentUid)
  //       .collection('invitations')
  //       .document(classId)
  //       .delete();
  //   print('complete!');

  //   //add to students classes
  //   _firestore
  //       .collection('students')
  //       .document(studentUid)
  //       .collection('classes')
  //       .document(classId)
  //       .setData({
  //     'class name': className,
  //     'date': DateFormat.yMMMMd('en_US').format(
  //       DateTime.now(),
  //     ),
  //     'mood': 'green',
  //   });
  // }

  // Future acceptInvitation(
  //     {String classId,
  //     String studentUid,
  //     String studentName,
  //     String className}) {
  //   print('trying to accept invite');
  //   //add to a student to the class
  //   _firestore
  //       .collection('classes')
  //       .document(classId)
  //       .collection('students')
  //       .document(studentUid)
  //       .setData({
  //     'date': DateFormat.yMMMMd('en_US').format(
  //       DateTime.now(),
  //     ),
  //     'mood': 'green',
  //     'student name': studentName,
  //   });

  //   //remove invite out of students
  //   _firestore
  //       .collection('user data')
  //       .document(studentUid)
  //       .collection('invitations')
  //       .document(classId)
  //       .delete();
  //   print('complete!');

  //   //add to students classes
  //   _firestore
  //       .collection('user data')
  //       .document(studentUid)
  //       .collection('classes')
  //       .document(classId)
  //       .setData({
  //     'class name': className,
  //     'date': DateFormat.yMMMMd('en_US').format(
  //       DateTime.now(),
  //     ),
  //     'mood': 'green',
  //   });
  // }

  Future<String> joinClass(
      {String studentUid, int classCode, String studentName}) async {
 
    try {
      //get id of class that student is joining
      String classId = await _firestore
          .collection('Classes')
          .where('Code', isEqualTo: classCode.toString())
          .getDocuments()
          .then((querySnap) => querySnap.documents[0].documentID);

      //get name of class that student is joining
      String className = await _firestore
          .collection('Classes')
          .document(classId)
          .get()
          .then((docSnap) => docSnap.data['ClassName']);

      //join class in classes collection
      _firestore
          .collection('Classes')
          .document(classId)
          .collection('Students')
          .document(studentUid)
          .setData({
        'date': DateFormat.yMMMMd('en_US').format(
          DateTime.now(),
        ),
        'mood': 'green',
        'student name': studentName,
      });

      //join class in user data collection
      _firestore
          .collection('UserData')
          .document(studentUid)
          .collection('Classes')
          .document(classId)
          .setData({
        'Code': classCode.toString(),
        'className': className,
        'student id': classId,
      });

      //set selected class to the new class
      setStudentSelectedClass(studentUid: studentUid, classId: classId);
      return 'success';
    } catch (e) {
      return 'failure';
    }
  }

  void pushAnnouncement(String classId, String content, String title) {
    _firestore
        .collection('Classes')
        .document(classId)
        .collection('Announcements')
        .document()
        .setData({
      'date': DateFormat.yMMMMd('en_US').format(
        DateTime.now(),
      ),
      'title': title,
      'content': content,
    });
  }

  // void setUpStudentMeeting(
  //     String title, String content, String date, String studentUid) {
  //   _firestore
  //       .collection('students')
  //       .document(studentUid)
  //       .collection('meetings')
  //       .document()
  //       .setData(
  //     {'title': title, 'content': content, 'date': date},
  //   );
  // }

  void setUpStudentMeeting(
      String title, String content, String date, String studentUid) {
    _firestore
        .collection('UserData')
        .document(studentUid)
        .collection('Meetings')
        .document()
        .setData(
      {'title': title, 'content': content, 'date': date},
    );
  }
}
