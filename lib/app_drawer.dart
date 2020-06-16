import 'package:cyber_dojo_app/teacher_portal/teacher_dash.dart';
import 'package:cyber_dojo_app/teacher_portal/teacher_profile.dart';
import 'package:flutter/material.dart';


import './student_portal/student_dash.dart';
import './student_portal/student_profile.dart';
import './teacher_portal/teacher_classes.dart';
import './student_portal/student_view_classes.dart';
import './student_portal/student_announcements.dart';
import './student_portal/student_meetings.dart';
import './student_portal/student_join_class.dart';
class AppDrawer {
  Widget studentDrawer(context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            // put image here
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Student Dashboard'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDash(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('View Classes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentClassesView(),
                ),
              );
              // Update the state of the app.
              // ...
              
            },
          ),
          ListTile(
            title: Text('student join class'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentJoinClassScreen(),
                ),
              );
              // Update the state of the app.
              // ...
            },
          ),
         
          ListTile(
            title: Text('Student Announcements'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAnnouncements(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Student Meetings'),
            onTap: () {
              // Update the state of the app.
              // ...
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentMeetings(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentProfile(),
                ),
              );
              // Update the state of the app.
              // ...
            },
            
          ),
          
        ],
      ),
    );
  }

  Widget teacherDrawer(context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            // put image here
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Teacher Dashboard'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherDash(),
                ),
              );
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: Text('View Classes'),
            onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherClassesScreen(),
                ),
              );
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherProfile(),
                ),
              );
              // Update the state of the app.
              // ...
            },
          ),
          
        ],
      ),
    );
  }
}
