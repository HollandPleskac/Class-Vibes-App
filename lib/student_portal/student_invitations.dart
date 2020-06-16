import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_drawer.dart';
import '../logic/fire.dart';
import '../constant.dart';

final Firestore _firestore = Firestore.instance;
final _appDrawer = AppDrawer();
final _fire = Fire();

class StudentInvitations extends StatefulWidget {
  @override
  _StudentInvitationsState createState() => _StudentInvitationsState();
}

class _StudentInvitationsState extends State<StudentInvitations> {
  String uid = '';
  String studentName = '';

  Future getStudentUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    uid = userUid;
    print(uid);
  }

  Future getStudentName(uid) async {
    String nameOfStudent =
        await _firestore.collection('students').document(uid).get().then(
              (docSnap) => docSnap.data['user name'],
            );

    studentName = nameOfStudent;
    print(studentName);
  }

  @override
  void initState() {
    getStudentUid().then((_) {
      print("got uid");
      getStudentName(uid).then((_) {
        print("got name");
        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: _appDrawer.studentDrawer(context),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.1,
                top: MediaQuery.of(context).size.height * 0.06,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              height: MediaQuery.of(context).size.height * 0.4,
              //height:350
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [
                    kPrimaryColor,
                    Colors.blue[700],
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState.openDrawer(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.085),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                Text(
                                  'Invitations',
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white, fontSize: 32),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Holland Pleskac',
                                  style: kSubTextStyle.copyWith(
                                      color: Colors.white, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 400,
              child: StreamBuilder(
                stream: _firestore
                    .collection("students")
                    .document(uid)
                    .collection('invitations')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');

                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );

                    default:
                      return (snapshot.data == null ||
                              snapshot.data.documents.isEmpty == true)
                          ? Center(
                              child: Container(
                                child: Text('no invitations'),
                              ),
                            )
                          : Center(
                              child: ListView(
                                children: snapshot.data.documents
                                    .map((DocumentSnapshot document) {
                                  return invitation(
                                    className: document['class name'],
                                    teacherName: document['teacher name'],
                                    uid: uid,
                                    classId: document['class id'],
                                    studentName: studentName,
                                  );
                                }).toList(),
                              ),
                            );
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

Widget invitation({
  String teacherName,
  String className,
  String uid,
  String classId,
  String studentName,
}) {
  return Container(
    child: Column(
      children: [
        Text('class name: ' + className.toString()),
        Text('teacher name: ' + teacherName.toString()),
        RaisedButton(
          child: Text('accept'),
          onPressed: () {
            // _fire.acceptInvitation(
            //   studentUid: uid,
            //   classId: classId,
            //   studentName: studentName,
            //   className:className,
            // );
          },
        ),
      ],
    ),
  );
}
