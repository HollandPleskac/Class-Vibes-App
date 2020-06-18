import 'package:cyber_dojo_app/student_subscreens/classview_student.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../app_drawer.dart';

final _appDrawer = AppDrawer();

final Firestore _firestore = Firestore.instance;

class StudentClassesView extends StatefulWidget {
  @override
  _StudentClassesViewState createState() => _StudentClassesViewState();
}

class _StudentClassesViewState extends State<StudentClassesView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String studentUid;
  String studentName;

  Future getStudentUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    studentUid = userUid;
    print(studentUid);
  }

  Future getStudentName(uid) async {
    String nameOfStudent =
        await _firestore.collection('user data').document(uid).get().then(
              (docSnap) => docSnap.data['user name'],
            );
    studentName = nameOfStudent;
    print(studentName);
  }

  @override
  void initState() {
    getStudentUid().then((_) {
      print("got uid");
      getStudentName(studentUid).then((_) {
        print("got name");
        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _appDrawer.studentDrawer(context),
      body: Column(
        children: [
          ClipPath(
            clipper: MyClipper(),
            child: Container(
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
                                  'Classes',
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white, fontSize: 32),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Spring 2020',
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
          ),
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Courses",
                      style: kTitleTextstyle.copyWith(fontSize: 26),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                ],
              ),
              Spacer(),
              // Padding(
              //   padding: const EdgeInsets.only(right: 15),
              //   child: Text(
              //     "View All",
              //     style: TextStyle(
              //       color: kPrimaryColor,
              //       fontWeight: FontWeight.w600,
              //       fontSize: 15,
              //     ),
              //   ),
              // ),
            ],
          ),
          Container(
            height: 450,
            child: StreamBuilder(
              stream: _firestore
                  .collection('user data')
                  .document(studentUid)
                  .collection('classes')
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
                  case ConnectionState.active:
                    if (snapshot.data != null &&
                        snapshot.data.documents.isEmpty == false) {
                      return Center(
                        child: GridView.count(
                          primary: false,
                          padding: const EdgeInsets.all(40),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 15,
                          crossAxisCount: 2,
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            return Course(
                              color: Colors.teal[200],
                              className: document['class name'],
                              classId: document.documentID,
                              studentName: studentName,
                              studentUid: studentUid,
                            );
                          }).toList(),
                        ),
                      );
                    }
                    return Center(
                      child: Text('No Classes'),
                    );
                  case ConnectionState.none:
                    return Center(
                      child: Text('No classes'),
                    );
                  case ConnectionState.done:
                    return Text('Error Connection State is complete');
                  default:
                    return Text('default');
                }
              },
            ),
          ),
          // Container(
          //   height: 450,
          //   child: GridView.count(
          //     primary: false,
          //     padding: const EdgeInsets.all(40),
          //     crossAxisSpacing: 20,
          //     mainAxisSpacing: 15,
          //     crossAxisCount: 2,
          //     children: <Widget>[
          //       Course(
          //         color: Colors.teal[100],
          //         text: 'Honors Chemistry',
          //         function: () {},
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'AP Biology',
          //         function: () {},
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'Math 3 Honors',
          //         function: () {},
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'English 10 Honors',
          //         function: () {},
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'AP World History',
          //         function: () {},
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'Physics in the Universe',
          //         function: () {},
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'Intro to Business',
          //         function: () {},
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class Course extends StatelessWidget {
  final Color color;

  final String classId;
  final String studentName;
  final String className;
  final String studentUid;

  const Course({
    Key key,
    this.color,
    this.classId,
    this.studentName,
    this.className,
    this.studentUid,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: Card(
          elevation: 2,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: kPrimaryColor.withOpacity(0.8),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                      ),
                      child: Text(
                        className,
                        style: kSubTextStyle.copyWith(
                            color: Colors.black, fontSize: 15.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          ClassViewStudent.routeName,
          arguments: {
            'class name': className,
            'class id': classId,
            'student name': studentName,
            'student uid':studentUid,
          },
        );
      },
    );
  }
}
