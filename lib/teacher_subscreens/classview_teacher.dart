import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polygon_clipper/polygon_clipper.dart';

import '../constant.dart';
import '../logic/fire.dart';
import '../teacher_portal/teacher_messages_screen.dart';

final Firestore _firestore = Firestore.instance;
final _fire = Fire();

class ClassViewTeacher extends StatefulWidget {
  static const routeName = 'class-view-teacher';
  @override
  _ClassViewTeacherState createState() => _ClassViewTeacherState();
}

class _ClassViewTeacherState extends State<ClassViewTeacher> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String className = routeArguments['class name'];
    final String classId = routeArguments['class id'];
    final String teacherName = routeArguments['teacher name'];
    final TextEditingController _pushAnnouncementController =
        TextEditingController();
    final TextEditingController _searchController = TextEditingController();
    final TextEditingController _inviteStudentController =
        TextEditingController();

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(className),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.edit),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {},
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Column(
        children: [
          // PUSH ANNOUNCEMENT
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
              ),
              child: Column(
                children: [
                  PushAnnouncement(
                    controller: _pushAnnouncementController,
                  ),
                ],
              ),
            ),
          ),
          //STUDENTS TEXT/ADD STUDENT ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40.0, top: 20),
                child: Text(
                  'Students',
                  style: kHeadingTextStyle.copyWith(
                    fontSize: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 40.0, top: 20),
                child: AddStudentIcon(
                  inviteStudentController: _inviteStudentController,
                  classId: classId,
                  className: className,
                  teacherName: teacherName,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          //SEARCH BAR
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 52,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  border: Border.all(color: kPrimaryColor, width: 2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: TextFormField(
                      controller: _searchController,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      style: kSubTextStyle.copyWith(color: kPrimaryColor),
                      autofocus: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        //hintStyle: kSubTextStyle.copyWith(color: kPrimaryColor),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        hintText: 'search',
                        icon: Icon(Icons.person),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),

          //STUDENTS ENROLLED
          Container(
            height: 380,
            child: StreamBuilder(
              stream: _firestore
                  .collection('classes')
                  .document(classId)
                  .collection('students')
                  .orderBy('mood', descending: true)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.data == null) {
                  return Center(
                    child: Text('No students'),
                  );
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                    //if there is snapshot data and the list of doucments it returns is empty
                    if (snapshot.data != null &&
                        snapshot.data.documents.isEmpty == false) {
                      return Center(
                        child: ListView(
                          children: snapshot.data.documents.map(
                            (DocumentSnapshot document) {
                              return Student(
                                color: document['mood'] == "green"
                                    ? kGreenColor
                                    : document['mood'] == "yellow"
                                        ? kYellowColor
                                        : document['mood'] == "red"
                                            ? kRedColor
                                            : document['mood'] == "black"
                                                ? Colors.black
                                                : Colors.grey,
                                studentName: document['student name'],
                                moodSelectionDate: document['date'],
                              );
                            },
                          ).toList(),
                        ),
                      );
                    }
                    // need in both places?? prevent error with no return statement
                    return Center(
                      child: Text('no students'),
                    );

                  case ConnectionState.none:
                    return Text('Connection state returned none');
                    break;
                  case ConnectionState.done:
                    return Text('Connection state finished');
                    break;
                  default:
                    return Text('nothing here');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PushAnnouncement extends StatelessWidget {
  final TextEditingController controller;
  PushAnnouncement({
    this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 175,
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 20,
                  ),
                  child: Text(
                    'Push Announcement',
                    style: kHeadingTextStyle.copyWith(
                      fontSize: 19,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, top: 10),
              child: TextFormField(
                controller: controller,
                maxLines: 1,
                keyboardType: TextInputType.text,
                style: kSubTextStyle.copyWith(color: kPrimaryColor),
                autofocus: false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  //hintStyle: kSubTextStyle.copyWith(color: kPrimaryColor),
                  labelStyle: TextStyle(
                    color: Colors.white,
                  ),
                  hintText: 'announcement',
                  icon: Icon(Icons.near_me),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Student extends StatelessWidget {
  final String studentName;
  final Color color;
  final String moodSelectionDate;

  Student({
    this.color,
    this.studentName,
    this.moodSelectionDate,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Card(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Hexagon(
                          color: color,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(),
                            Text(
                              studentName,
                              style: kHeadingTextStyle.copyWith(
                                fontSize: 20,
                                color: color,
                              ),
                            ),
                            Text(
                              moodSelectionDate,
                              style: kSubTextStyle.copyWith(
                                fontSize: 15,
                              ),
                            ),
                            Container(),
                          ],
                        ),
                      ],
                    ),
                    StudentChat(
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Hexagon extends StatelessWidget {
  final Color color;

  Hexagon({
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      child: ClipPolygon(
        sides: 6,
        borderRadius: 5.0, // Default 0.0 degrees
        rotate: 0.0, // Default 0.0 degrees
        // boxShadows: [
        //   PolygonBoxShadow(color: Colors.black, elevation: 1.0),
        //   PolygonBoxShadow(color: Colors.grey, elevation: 5.0)
        // ],
        child: Container(
          color: color,
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}

class StudentChat extends StatelessWidget {
  final Color color;

  StudentChat({
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: IconButton(
        icon: Icon(
          Icons.chat,
          color: color,
          size: 30,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherMessages(),
            ),
          );
        },
      ),
    );
  }
}

class AddStudentIcon extends StatefulWidget {
  final String teacherName;
  final String classId;
  final String className;
  final TextEditingController inviteStudentController;

  AddStudentIcon({
    this.teacherName,
    this.classId,
    this.className,
    this.inviteStudentController,
  });

  @override
  _AddStudentIconState createState() => _AddStudentIconState();
}

class _AddStudentIconState extends State<AddStudentIcon> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Column(
              children: [
                AlertDialog(
                  title: Text('Invite a Student'),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Container(
                        child: Column(
                          children: [
                            TextField(
                              controller: widget.inviteStudentController,
                            ),
                            FlatButton(
                              child: Text('Invite'),
                              onPressed: () async {
                                String isValidEmail = await _fire.inviteStudent(
                                  teacherName: widget.teacherName,
                                  classId: widget.classId,
                                  className: widget.className,
                                  studentEmail:
                                      widget.inviteStudentController.text,
                                );
                                if (isValidEmail == 'success') {
                                  Navigator.pop(context);
                                } else {
                                  print(
                                      'there was an error - email is not in database');
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
