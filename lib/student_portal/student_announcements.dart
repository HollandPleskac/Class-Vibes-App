import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';
import '../app_drawer.dart';

final _appDrawer = AppDrawer();
final Firestore _firestore = Firestore.instance;

class StudentAnnouncements extends StatefulWidget {
  @override
  _StudentAnnouncementsState createState() => _StudentAnnouncementsState();
}

class _StudentAnnouncementsState extends State<StudentAnnouncements> {
  String studentUid = '';
  String studentSelectedClassId = '';
  String studentSelectedClassName;

  Future getStudentUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    studentUid = userUid;
    print(studentUid);
  }

  Future getStudentClassId(String uid) async {
    try {
      String classIdentification =
          await _firestore.collection('UserData').document(uid).get().then(
                (docSnap) => docSnap.data['selected class'],
              );
      studentSelectedClassId = classIdentification;
    } catch (e) {
      studentSelectedClassId = null;
    }
  }

  Future getStudentClassName(uid, selectedClassId) async {
    try {
      String className = await _firestore
          .collection('Classes')
          .document(selectedClassId)
          .get()
          .then(
            (docSnap) => docSnap.data['class-name'],
          );

      studentSelectedClassName = className;
    } catch (e) {
      studentSelectedClassName = 'No Classes';
    }
  }

  @override
  void initState() {
    getStudentUid().then((_) {
      print("got uid");
      getStudentClassId(studentUid).then((_) {
        print("got class id");
        getStudentClassName(studentUid, studentSelectedClassId).then(
          (_) {
            print('got class name');

            setState(() {
              print('uid ' + studentUid);
              print('class id ' + studentSelectedClassId);
              print('class name display' + studentSelectedClassName);
            });
          },
        );
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
      body: Column(
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
                                  'Welcome Back',
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
            Text('note : add in announcements to this screen later'),
          // Container(
          //   height: 300,
          //   child: StreamBuilder(
          //     stream: _firestore
          //         .collection('classes')
          //         .document(studentSelectedClassId)
          //         .collection('announcements')
          //         .snapshots(),
          //     builder:
          //         (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //       if (snapshot.hasError) {
          //         return Text('Error: ${snapshot.error}');
          //       }
          //       switch (snapshot.connectionState) {
          //         case ConnectionState.waiting:
          //           return Center(
          //             child: CircularProgressIndicator(),
          //           );

          //         default:
          //           return snapshot.data == null ||
          //                   snapshot.data.documents.isEmpty == true
          //               ? Container(
          //                   child: Text('no announcements'),
          //                 )
          //               : Center(
          //                   child: ListView(
          //                     children: snapshot.data.documents
          //                         .map(
          //                           (DocumentSnapshot document) => Announcement(
          //                             content: document['content'],
          //                             title: document['title'],
          //                             date: document['date'],
          //                           ),
          //                         )
          //                         .toList(),
          //                   ),
          //                 );
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

class Announcement extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  Announcement({
    this.title,
    this.content,
    this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: [
            Text('announcement title : ' + title),
            Text('announcement content: ' + content),
            Text('announcement date: ' + date)
          ],
        ),
      ),
    );
  }
}
