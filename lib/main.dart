import 'package:flutter/material.dart';

import './splash.dart';
import './student_portal/student_dash.dart';
import './teacher_portal/teacher_dash.dart';
import './testing.dart';
import './teacher_subscreens/classview_teacher.dart';

import './auth_screens/login_screen.dart';
import './auth_screens/signup_as_student_screen.dart';
import './auth_screens/signup_as_teacher_screen.dart';
import './student_subscreens/classview_student.dart';
import './student_portal/student_messages_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StudentMessages(),
      routes: ({
        ClassViewTeacher.routeName: (context) => ClassViewTeacher(),
        ClassViewStudent.routeName: (context) => ClassViewStudent(),
      }),
    );
  }
}

//IMPORTANT NOTES - MUST READ
//SWAPPING EMAIL FOR USER UID TO BE CONSISTENT WITH THE WEBSITE

