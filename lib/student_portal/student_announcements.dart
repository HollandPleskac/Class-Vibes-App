import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          await _firestore.collection('students').document(uid).get().then(
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
          .collection('classes')
          .document(selectedClassId)
          .get()
          .then(
            (docSnap) => docSnap.data['class name'],
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
    return Container(
            height: 300,
            child: StreamBuilder(
              stream: _firestore
                  .collection('classes')
                  .document(studentSelectedClassId)
                  .collection('announcements')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  default:
                    return snapshot.data == null || snapshot.data.documents.isEmpty == true
                        ? Container(
                            child: Text('no announcements'),
                          )
                        : Center(
                            child: ListView(
                              children: snapshot.data.documents
                                  .map(
                                    (DocumentSnapshot document) => Announcement(
                                      content: document['content'],
                                      title: document['title'],
                                      date: document['date'],
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                    ;
                }
              },
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
        padding: EdgeInsets.only(top:15),
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