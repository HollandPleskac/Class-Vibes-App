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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String sortedChoice = 'yellow';
  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String className = routeArguments['class name'];
    final String classId = routeArguments['class id'];
    final String teacherName = routeArguments['teacher name'];
    final int classCode = routeArguments['class code'];

    //meeting controllers
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    //announcement controllers
    final TextEditingController _pushAnnouncementContentController =
        TextEditingController();
    final TextEditingController _pushAnnouncementTitleController =
        TextEditingController();

    return Scaffold(
      key: _scaffoldKey,
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
      body: SingleChildScrollView(
        child: Column(
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
                      contentController: _pushAnnouncementContentController,
                      titleController: _pushAnnouncementTitleController,
                      classId: classId,
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
                    classId: classId,
                    className: className,
                    teacherName: teacherName,
                    classCode: classCode,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            //Sorting Bar

            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        sortedChoice = 'All Students';
                      });
                      print(sortedChoice);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      height: 40,
                      width: 80,
                      color: kPrimaryColor,
                      child: Center(
                          child: Text(
                        'all',
                        style: kSubTextStyle.copyWith(color: Colors.white),
                      )),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        sortedChoice = 'green';
                      });
                      print(sortedChoice);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      height: 40,
                      width: 80,
                      color: kPrimaryColor,
                      child: Center(
                          child: Text(
                        'green',
                        style: kSubTextStyle.copyWith(color: Colors.white),
                      )),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        sortedChoice = 'yellow';
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      height: 40,
                      width: 80,
                      color: kPrimaryColor,
                      child: Center(
                          child: Text(
                        'yellow',
                        style: kSubTextStyle.copyWith(color: Colors.white),
                      )),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        sortedChoice = 'red';
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 4, right: 4),
                      height: 40,
                      width: 80,
                      color: kPrimaryColor,
                      child: Center(
                          child: Text(
                        'red',
                        style: kSubTextStyle.copyWith(color: Colors.white),
                      )),
                    ),
                  ),
                ],
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
                    .where('mood', isEqualTo: sortedChoice)
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
                                  contentController: contentController,
                                  dateController: dateController,
                                  studentUid: document.documentID,
                                  titleController: titleController,
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
      ),
    );
  }
}

class PushAnnouncement extends StatefulWidget {
  final TextEditingController contentController;
  final TextEditingController titleController;
  final String classId;
  final TextEditingController dateController;
  final String studentUid;

  PushAnnouncement({
    this.contentController,
    this.titleController,
    this.classId,
    this.dateController,
    this.studentUid,
  });

  @override
  _PushAnnouncementState createState() => _PushAnnouncementState();
}

class _PushAnnouncementState extends State<PushAnnouncement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 190,
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
                    onPressed: () {
                      _fire.pushAnnouncement(
                          widget.classId,
                          widget.contentController.text,
                          widget.titleController.text);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, top: 00),
              child: TextField(
                controller: widget.titleController,
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
                  hintText: 'title',
                  icon: Icon(Icons.near_me),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 50, top: 00),
              child: TextField(
                controller: widget.contentController,
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
                  hintText: 'content',
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
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController dateController;
  final String studentUid;

  Student({
    this.color,
    this.studentName,
    this.moodSelectionDate,
    this.titleController,
    this.dateController,
    this.contentController,
    this.studentUid,
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
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          studentMeeting(
                            context,
                            titleController,
                            contentController,
                            dateController,
                            studentUid,
                          ),
                          StudentChat(
                            color: color,
                          ),
                        ],
                      ),
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

Widget studentMeeting(
  BuildContext context,
  TextEditingController titleController,
  TextEditingController contentController,
  TextEditingController dateController,
  String studentUid,
) {
  return Padding(
    padding: const EdgeInsets.only(right: 5),
    child: IconButton(
      icon: Icon(
        Icons.schedule,
        color: kRedColor,
        size: 30,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Setup a meeting (title,content,date)'),
              content: Column(
                children: [
                  TextField(
                    controller: titleController,
                  ),
                  TextField(
                    controller: contentController,
                  ),
                  TextField(
                    controller: dateController,
                  ),
                  FlatButton(
                    child: Text('setup'),
                    onPressed: () {
                      _fire.setUpStudentMeeting(
                        titleController.text,
                        contentController.text,
                        dateController.text,
                        studentUid,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TeacherMessages(),
        //   ),
        // );
      },
    ),
  );
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
  final int classCode;

  AddStudentIcon({
    this.teacherName,
    this.classId,
    this.className,
    this.classCode,
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
                        child: Text('Class Code : ' + widget.classCode.toString()),
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
