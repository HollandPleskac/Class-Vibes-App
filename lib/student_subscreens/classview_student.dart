import 'package:flutter/material.dart';

class ClassViewStudent extends StatefulWidget {
  static const routeName = 'class-view-teacher';
  @override
  _ClassViewStudentState createState() => _ClassViewStudentState();
}

class _ClassViewStudentState extends State<ClassViewStudent> {
  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String className = routeArguments['class name'];
    final String classId = routeArguments['class id'];
    final String studentName = routeArguments['student name'];
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            child: Text('view announcements'),
          ),
          Container(
            height: 300,
            child: Text('view meetings'),
          ),
        ],
      ),
    );
  }
}
