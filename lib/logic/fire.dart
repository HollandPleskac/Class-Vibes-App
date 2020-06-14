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
  }) {
    var _randomString = randomAlphaNumeric(30);
    _firestore.collection('classes').document(_randomString).setData({
      'class name': className,
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
}

Future<void> inviteStudent({
  String studentUid,
  String classId,
  String teacherName,
  String className,
}) {
  _firestore
      .collection('students')
      .document(studentUid)
      .collection('invitations')
      .document(classId)
      .setData({
    'teacher name': teacherName,
    'class name': className,
  });
}
