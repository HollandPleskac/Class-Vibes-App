import 'package:flutter/material.dart';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../teacher_portal/teacher_messages_screen.dart';

final Firestore _firestore = Firestore();

class StudentYellow extends StatefulWidget {
  @override
  _StudentYellowState createState() => _StudentYellowState();
}

class _StudentYellowState extends State<StudentYellow> {
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
        await _firestore.collection('teachers').document(uid).get().then(
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
        backgroundColor: kYellowColor,
        centerTitle: true,
        title: Text('Students who need help'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 25),
          child: StreamBuilder(
            stream: _firestore
                .collection("classes")
                .document(teacherSelectedClassId)
                .collection('students')
                .where('mood', isEqualTo: 'yellow')
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
                          return YellowStudent(
                            studentName: document['student name'],
                            moodSelectionDate: document['date'],
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
    );
  }
}

class YellowStudent extends StatelessWidget {
  final String studentName;
  final String moodSelectionDate;

  const YellowStudent({
    @required this.studentName,
    @required this.moodSelectionDate,
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
                  color: kYellowColor,
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
                                color: kYellowColor,
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
                    studentChat(context),
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
          color: kYellowColor,
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
        color: kYellowColor,
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 25,
        ),
      ),
    ),
  );
}

Widget studentChat(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(right: 20),
    child: IconButton(
      icon: Icon(
        Icons.chat,
        color: kYellowColor,
        size: 30,
      ),
      onPressed: () {Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherMessages(),
          ),
        );},
    ),
  );
}
