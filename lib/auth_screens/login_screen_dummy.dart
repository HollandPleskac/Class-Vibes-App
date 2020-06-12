import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constant.dart';
import '../student_portal/student_dash.dart';
import '../teacher_portal/teacher_dash.dart';

final Firestore _firestore = Firestore();

class LoginScreenDummy extends StatefulWidget {
  @override
  _LoginScreenDummyState createState() => _LoginScreenDummyState();
}

class _LoginScreenDummyState extends State<LoginScreenDummy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              color: kPrimaryColor.withOpacity(0.8),
              child: Text(
                'Go To Student Portal',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDash(),
                  ),
                );
              },
            ),
            FlatButton(
              color: kRedColor.withOpacity(0.7),
              child: Text(
                'Go To Teacher Portal',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherDash(),
                  ),
                );
              },
            ),
            
          ],
        ),
      ),
    );
  }
}
