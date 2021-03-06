import 'package:cyber_dojo_app/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant.dart';
import '../app_drawer.dart';
import '../logic/fire.dart';
import './student_messages_screen.dart';

final _appDrawer = AppDrawer();
final Firestore _firestore = Firestore.instance;
final _firebaseAuth = FirebaseAuth.instance;

final _fire = Fire();

class StudentDash extends StatefulWidget {
  @override
  _StudentDashState createState() => _StudentDashState();
}

class _StudentDashState extends State<StudentDash> {
  List<String> studentClasses = [
    'AP Biology',
    'Honors Chemistry',
    'Math 3 Honors'
  ];

  //String selectedClass = 'AP Biology';
  //String selectedClassDisplay = 'AP Biology';

  String studentSelectedClassNameDisplay = '';

  String studentUid = '';
  String studentSelectedClassId = '';
  String studentSelectedClassName = 'loading';
  String studentMood = '';
  String studentName = '';
  String studentChatId = '';

  Future getStudentUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    studentUid = userUid;
    print(studentUid);
  }

  Future getStudentNameAndStudentChatId(uid) async {
    String nameOfStudent = await _firestore
        .collection("UserData")
        .document(uid)
        .get()
        .then((docSnap) => docSnap.data['username']);
    String chatIdOfStudent = await _firestore
        .collection("UserData")
        .document(uid)
        .get()
        .then((docSnap) => docSnap.data['chat id']);
    studentName = nameOfStudent;
    studentChatId = chatIdOfStudent;
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

  Future getStudentClassNameDisplay(uid, selectedClassId) async {
    try {
      String className = await _firestore
          .collection('Classes')
          .document(selectedClassId)
          .get()
          .then(
            (docSnap) => docSnap.data['class-name'],
          );

      studentSelectedClassNameDisplay = className;
    } catch (e) {
      studentSelectedClassNameDisplay = 'No Classes';
    }
  }

  Future setStudentNewSelectedClassID(String newSelectedClassName) async {
    String newSelectedClassId = await _firestore
        .collection('UserData')
        .document(studentUid)
        .collection('Classes')
        .where('class-name', isEqualTo: newSelectedClassName)
        .getDocuments()
        .then((value) => value.documents[0].documentID);

    updateStudentSelectedClassDataInApp(
        newSelectedClassId, newSelectedClassName);

    _fire.setStudentSelectedClass(
      classId: newSelectedClassId,
      studentUid: studentUid,
    );
  }

  void updateStudentSelectedClassDataInApp(newClassId, newClassName) async {
    setState(() {
      studentSelectedClassId = newClassId;

      studentSelectedClassName = newClassName;

      studentSelectedClassNameDisplay = newClassName;
    });
  }

  @override
  void initState() {
    getStudentUid().then((_) {
      print("got uid");
      getStudentClassId(studentUid).then((_) {
        print("got class id");
        getStudentClassNameDisplay(studentUid, studentSelectedClassId).then(
          (_) {
            print('got class name');

            getStudentNameAndStudentChatId(studentUid).then(
              (_) {
                print('got class name');

                setState(() {
                  print('uid ' + studentUid);
                  print('class id ' + studentSelectedClassId);
                  print('class name display' + studentSelectedClassNameDisplay);
                  print('mood/status ' + studentMood);
                });
              },
            );
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
      body: Column(
        children: [
          ClipPath(
            clipper: MyClipper(),
            child: Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                top: MediaQuery.of(context).size.height * 0.03,
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
                    Color(0xFF3383CD),
                    Color(0xFF11249F),
                  ],
                ),
                // image: DecorationImage(
                //   image: AssetImage("assets/images/virus.png"),
                // ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 0, top: 0.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () =>
                                _scaffoldKey.currentState.openDrawer(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.085),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                Text(
                                  'Student Dashboard',
                                  // studentSelectedClassNameDisplay == null ||
                                  //         studentSelectedClassNameDisplay == ''
                                  //     ? 'Student Dashboard'
                                  //     : studentSelectedClassNameDisplay,
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white, fontSize: 32),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  studentSelectedClassNameDisplay == null ||
                                          studentSelectedClassNameDisplay ==
                                              '' ||
                                          studentSelectedClassNameDisplay ==
                                              'No Classes'
                                      ? 'No Selected Class'
                                      : studentSelectedClassNameDisplay,
                                  // 'Spring 2020',
                                  style: kSubTextStyle.copyWith(
                                      color: Colors.white, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.058,
                            right: 00,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SvgPicture.asset(
                              'assets/images/undraw_Graduation_ktn0.svg',
                              width: MediaQuery.of(context).size.height * 0.18,
                              fit: BoxFit.fitWidth,
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

          // dropdown with firestore
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.045,
            ),
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02,
              horizontal: MediaQuery.of(context).size.width * 0.045,
            ),
            height: MediaQuery.of(context).size.height * 0.073,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Color(0xFFE5E5E5),
              ),
            ),
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("UserData")
                    .document(studentUid)
                    .collection('Classes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)

                    //TODO : this is a bandaid solution - if the snapshot is loading, just make it look like it is not
                    return Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.school,
                          color: kOffColor,
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        // Text(
                        //   'No Classes',
                        //   style: kSubTextStyle,
                        // ),
                        Spacer(),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: const Icon(Icons.arrow_drop_down),
                        ),
                      ],
                    );
                  // return Text('Loading...');
                  else {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return CircularProgressIndicator();
                      default:
                        List<DropdownMenuItem> dropdownEvents = [];
                        for (int i = 0;
                            i < snapshot.data.documents.length;
                            i++) {
                          DocumentSnapshot documentSnapshot =
                              snapshot.data.documents[i];
                          dropdownEvents.add(
                            DropdownMenuItem(
                              child: Text(
                                documentSnapshot['class-name'],
                                style: kSubTextStyle.copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: "${documentSnapshot['class-name']}",
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.school,
                              color: kOffColor,
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: DropdownButton(
                                isExpanded: true,
                                underline: SizedBox(),
                                icon: Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  child: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ),
                                ),
                                value: studentSelectedClassName,
                                items: dropdownEvents,
                                onChanged: (newEventSelected) async {
                                  await setStudentNewSelectedClassID(
                                    newEventSelected,
                                  );
                                },
                                hint: Text(
                                  studentSelectedClassNameDisplay,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                    }
                  }
                }),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.028),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.045),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Teacher",
                          style: kTitleTextstyle.copyWith(fontSize: 19),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        studentSelectedClassNameDisplay == 'No Classes' ||
                                studentSelectedClassNameDisplay == ''
                            ? Container()
                            : StreamBuilder(
                                stream: Firestore.instance
                                    .collection('Classes')
                                    .document(studentSelectedClassId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text('');
                                  } else {
                                    return Padding(
                                      padding: EdgeInsets.only(left: 2),
                                      child: Text(
                                        snapshot.data['Teacher'],
                                        style: TextStyle(
                                          color: kTextLightColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    );
                                  }
                                }),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      child: Text(
                        "Start Chat",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, StudentMessages.routeName,
                            arguments: {
                              'chat id': studentChatId,
                              'student name': studentName,
                              'student uid': studentUid,
                            });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                //see your status

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Your status : ',
                        style: kTitleTextstyle.copyWith(
                            color: Colors.black, fontSize: 22),
                      ),
                    ),
                    // dynamic

                    studentSelectedClassNameDisplay == 'No Classes' ||
                            studentSelectedClassNameDisplay == ''
                        ? Container(
                            child: Text(
                                'join a class before\nyou can select your mood'),
                          )
                        : StreamBuilder(
                            stream: Firestore.instance
                                .collection('Classes')
                                .document(studentSelectedClassId)
                                .collection('Students')
                                .document(studentUid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("Error : ${snapshot.error}");
                              } else {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container(
                                      height: 80,
                                      width: 80,
                                    );
                                  default:
                                    var document = snapshot.data;
                                    return Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        child: Center(
                                          child: document['mood'] == "green"
                                              ? Image.asset(
                                                  'assets/images/happy face.png',
                                                  width: 55,
                                                  height: 55,
                                                )
                                              : document['mood'] == 'red'
                                                  ? Image.asset(
                                                      'assets/images/sad face.png',
                                                      width: 55,
                                                      height: 55,
                                                    )
                                                  : document['mood'] == 'yellow'
                                                      ? Image.asset(
                                                          'assets/images/thinking face.png',
                                                          width: 55,
                                                          height: 55,
                                                        )
                                                      : Text(
                                                          '',
                                                          style: kHeadingTextStyle
                                                              .copyWith(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 18),
                                                        ),
                                        ),
                                      ),
                                    );
                                }
                              }
                            },
                          ),
                  ],
                ),

                SizedBox(
                  height: 40,
                ),

                //change status
                Container(
                  height: 180,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Change your status',
                          style: kTitleTextstyle.copyWith(
                              color: Colors.black, fontSize: 22),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle),
                                  // child: Center(
                                  //   child: Image.asset(
                                  //     'assets/images/happy face.png',
                                  //     width: 80,
                                  //     height: 80,
                                  //   ),
                                  // ),
                                  child: Center(
                                      child: Text(
                                    '😄',
                                    style: TextStyle(fontSize: 60),
                                  )),
                                ),
                                onTap: () {
                                  _fire.updateStudentMood(
                                    classId: studentSelectedClassId,
                                    newMood: 'green',
                                    studentUid: studentUid,
                                  );
                                },
                              ),
                              Indicator(
                                color: kGreenColor,
                                text: 'Doing Great',
                                isSquare: true,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle),
                                  // child: Center(
                                  //   child: Image.asset(
                                  //     'assets/images/thinking face.png',
                                  //     width: 80,
                                  //     height: 80,
                                  //   ),
                                  // ),
                                  child: Center(
                                      child: Text(
                                    '😕',
                                    style: TextStyle(fontSize: 60),
                                  )),
                                ),
                                onTap: () {
                                  _fire.updateStudentMood(
                                    classId: studentSelectedClassId,
                                    newMood: 'yellow',
                                    studentUid: studentUid,
                                  );
                                },
                              ),
                              Indicator(
                                color: Color(0xfff8b250),
                                text: 'Need Help',
                                isSquare: true,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle),
                                  // child: Center(
                                  //   child: Image.asset(
                                  //     'assets/images/sad face.png',
                                  //     width: 80,
                                  //     height: 80,
                                  //   ),
                                  // ),
                                  child: Center(
                                      child: Text(
                                    '😡',
                                    style: TextStyle(fontSize: 60),
                                  )),
                                ),
                                onTap: () {
                                  _fire.updateStudentMood(
                                    classId: studentSelectedClassId,
                                    newMood: 'red',
                                    studentUid: studentUid,
                                  );
                                },
                              ),
                              Indicator(
                                color: kRedColor,
                                text: 'Frustrated',
                                isSquare: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: _appDrawer.studentDrawer(context),
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

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key key,
    this.color,
    this.text,
    this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}
