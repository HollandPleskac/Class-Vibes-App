import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../teacher_portal/teacher_messages_screen.dart';
import '../logic/fire.dart';

final _fire = Fire();
final Firestore _firestore = Firestore();

class StudentGreen extends StatefulWidget {
  @override
  _StudentGreenState createState() => _StudentGreenState();
}

class _StudentGreenState extends State<StudentGreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String teacherUid = '';
  String teacherSelectedClassId = '';

  Future getTeacherUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    teacherUid = userUid;
    print(teacherUid);
  }

  Future getTeacherClassId(String uid) async {
    String classIdentification =
        await _firestore.collection('user data').document(uid).get().then(
              (docSnap) => docSnap.data['selected class'],
            );
    teacherSelectedClassId = classIdentification;
  }

  @override
  void initState() {
    getTeacherUid().then((_) {
      print("got uid");
      getTeacherClassId(teacherUid).then((_) {
        print("got class id");
        setState(() {
          print('uid ' + teacherUid);
          print('class id ' + teacherSelectedClassId);
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreenColor,
        centerTitle: true,
        title: Text('Students who are doing great'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 25),
          child: StreamBuilder(
            stream: _firestore
                .collection("classes")
                .document(teacherSelectedClassId)
                .collection('students')
                .where('mood', isEqualTo: 'green')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');

              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  return Center(
                    child: ListView(
                      children: snapshot.data.documents.map(
                        (DocumentSnapshot document) {
                          return GreenStudent(
                            studentName: document['student name'],
                            moodSelectionDate: document['date'],
                            contentController: contentController,
                            titleController: titleController,
                            dateController: dateController,
                            studentUid: document.documentID,
                          );
                        },
                      ).toList(),
                    ),
                  );
              }
            },
          ),
        ),
      ),
      // body: Center(
      //   child: Padding(
      //     padding: EdgeInsets.only(top: 25),
      //     child: ListView(
      //       children: [
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Nayeli Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //         GreenStudent(studentName: 'Holland Pleskac'),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

class GreenStudent extends StatelessWidget {
  final String studentName;
  final String moodSelectionDate;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController dateController;
  final String studentUid;

  const GreenStudent({
    @required this.studentName,
    @required this.moodSelectionDate,
    @required this.titleController,
    @required this.contentController,
    @required this.dateController,
    @required this.studentUid,
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
                  color: kGreenColor,
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
                        hexagon(context),
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
                                color: kGreenColor,
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
                          studentChat(context),
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
          color: kGreenColor,
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

Widget hexagon(BuildContext context) {
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
        color: kGreenColor,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 25,
        ),
      ),
    ),
  );
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

Widget studentChat(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(right: 20),
    child: IconButton(
      icon: Icon(
        Icons.chat,
        color: kGreenColor,
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
