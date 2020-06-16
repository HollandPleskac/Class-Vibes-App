import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../app_drawer.dart';
import '../constant.dart';

final _appDrawer = AppDrawer();
final Firestore _firestore = Firestore.instance;

class StudentMeetings extends StatefulWidget {
  @override
  _StudentMeetingsState createState() => _StudentMeetingsState();
}

class _StudentMeetingsState extends State<StudentMeetings> {
  String studentUid = '';

  Future getStudentUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    studentUid = userUid;
    print(studentUid);
  }

  @override
  void initState() {
    getStudentUid().then((_) {
      print("got uid");
      setState(() {
        print('uid ' + studentUid);
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
                                  'Meetings',
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white, fontSize: 32),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'meetings',
                                  style: kSubTextStyle.copyWith(
                                      color: Colors.white, fontSize: 18),
                                ),
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
              height: 300,
              child: StreamBuilder(
                stream: _firestore
                    .collection('user data')
                    .document(studentUid)
                    .collection('meetings')
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
    return Container();
  }
}
