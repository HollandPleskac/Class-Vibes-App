import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore _firestore = Firestore();

class ClassViewStudent extends StatefulWidget {
  static const routeName = 'class-view-student';
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
    final String studentUid = routeArguments['student uid'];
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            child: StreamBuilder(
              stream: _firestore
                  .collection('Classes')
                  .document(classId)
                  .collection('Announcements')
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
          ),
          Container(
            height: 300,
            child: StreamBuilder(
                stream: _firestore
                    .collection('UserData')
                    .document(studentUid)
                    .collection('Meetings')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      print(snapshot.connectionState.toString());
                      return Center(
                        child: CircularProgressIndicator(),
                      );

                    default:
                      return snapshot.data == null ||
                              snapshot.data.documents.isEmpty == true
                          ? Container(
                              child: Text('no meetings'),
                            )
                          : Center(
                              child: ListView(
                                children: snapshot.data.documents
                                    .map(
                                      (DocumentSnapshot document) => Meeting(
                                        content: document['content'],
                                        title: document['title'],
                                        date: document['date'],
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                  }
                },
              ),
          ),
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



class Meeting extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  Meeting({
    this.title,
    this.content,
    this.date,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('title ' + title),
          Text('content ' + content),
          Text('date ' + date),
        ],
      ),
    );
  }
}