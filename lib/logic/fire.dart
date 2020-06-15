import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

final Firestore _firestore = Firestore();

class Fire {
  void createStudentAccount({String userUid, String email, String userName
      //String school,
      //String studentId,
      }) {
    _firestore.collection('students').document(userUid).setData(
      {
        'email': email,
        'user name': userName,
        //'school': school,
        //'student id': studentId,
        'selected class': 'no selected class',
      },
    );
  }

  void createTeacherAccount({
    String userUid,
    String email,
    String userName,
    //String school,
    //String professionalName,
  }) {
    _firestore.collection('teachers').document(userUid).setData(
      {
        'email': email,
        'user name': userName,
        'selected class': 'no selected class',
        'student display name': userName,
        //'professional name': professionalName,
      },
    );
  }

  Future<String> getLoginType({
    String email,
  }) async {
    try {
      String teacherQueryResult = await _firestore
          .collection('teachers')
          .where('email', isEqualTo: email)
          .getDocuments()
          .then(
            (querySnap) => querySnap.documents[0].documentID.toString(),
          );
      print(
        'teacher result ' + teacherQueryResult.toString(),
      );
      return 'teacher';
    } catch (e) {
      return 'student';
    }
  }

  void updateStudentMood({
    String studentUid,
    String classId,
    String newMood,
  }) {
    _firestore
        .collection('students')
        .document(studentUid)
        .collection('classes')
        .document(classId)
        .updateData({
      'mood': newMood,
      'date': DateFormat.yMMMMd('en_US').format(
        DateTime.now(),
      ),
    });

    _firestore
        .collection('classes')
        .document(classId)
        .collection('students')
        .document(studentUid)
        .updateData(
      {
        'mood': newMood,
        'date': DateFormat.yMMMMd('en_US').format(
          DateTime.now(),
        ),
      },
    );
  }

  void setStudentSelectedClass({
    String studentUid,
    String classId,
  }) {
    _firestore.collection('students').document(studentUid).updateData(
      {'selected class': classId},
    );
  }

  void setTeacherSelectedClass({String teacherUid, String classId}) {
    _firestore.collection('teachers').document(teacherUid).updateData(
      {'selected class': classId},
    );
  }

  void createClass({
    String teacherUid,
    String className,
    String classId,
    String teacherName,
  }) {
    var _randomString = randomAlphaNumeric(30);
    _firestore.collection('classes').document(_randomString).setData({
      'class name': className,
      'teacher': teacherName,
    });

    _firestore
        .collection('teachers')
        .document(teacherUid)
        .collection('classes')
        .document(_randomString)
        .setData(
      {
        'class name': className,
        'class id': classId,
      },
    );
  }

  Future<String> inviteStudent({
    String studentEmail,
    String classId,
    String teacherName,
    String className,
  }) async {
    try {
      String studentUid = await _firestore
          .collection('students')
          .where('email', isEqualTo: studentEmail)
          .getDocuments()
          .then(
            (querySnap) => querySnap.documents[0].documentID.toString(),
          );

      _firestore
          .collection('students')
          .document(studentUid)
          .collection('invitations')
          .document(classId)
          .setData({
        'teacher name': teacherName,
        'class name': className,
        'class id': classId,
      });
      return 'success';
    } catch (e) {
      return 'fail';
    }
  }

  Future acceptInvitation(
      {String classId,
      String studentUid,
      String studentName,
      String className}) {
    print('trying to accept invite');
    //add to a student to the class
    _firestore
        .collection('classes')
        .document(classId)
        .collection('students')
        .document(studentUid)
        .setData({
      'date': DateFormat.yMMMMd('en_US').format(
        DateTime.now(),
      ),
      'mood': 'green',
      'student name': studentName,
    });

    //remove invite out of students
    _firestore
        .collection('students')
        .document(studentUid)
        .collection('invitations')
        .document(classId)
        .delete();
    print('complete!');

    //add to students classes
    _firestore
        .collection('students')
        .document(studentUid)
        .collection('classes')
        .document(classId)
        .setData({
      'class name': className,
      'date': DateFormat.yMMMMd('en_US').format(
        DateTime.now(),
      ),
      'mood': 'green',
    });
  }

  void pushAnnouncement(String classId, String content, String title) {
    _firestore
        .collection('classes')
        .document(classId)
        .collection('announcements')
        .document()
        .setData({
      'date': DateFormat.yMMMMd('en_US').format(
        DateTime.now(),
      ),
      'title':title,
      'content': content,

    });
  }
}
