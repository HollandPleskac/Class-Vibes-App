import 'package:cyber_dojo_app/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String studentSelectedClassName;
  String studentMood = '';

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

  Future getStudentClassNameDisplay(uid, selectedClassId) async {
    try {
      String className = await _firestore
          .collection('classes')
          .document(selectedClassId)
          .get()
          .then(
            (docSnap) => docSnap.data['class name'],
          );

      studentSelectedClassNameDisplay = className;
    } catch (e) {
      studentSelectedClassNameDisplay = 'No Classes';
    }
  }

  Future getStudentStatus(uid, classId) async {
    try {
      String status = await _firestore
          .collection('classes')
          .document(classId)
          .collection('students')
          .document(uid)
          .get()
          .then(
            (docSnap) => docSnap.data['mood'],
          );
      studentMood = status;
    } catch (e) {
      studentMood = '';
    }
  }

  Future setStudentNewSelectedClassID(String newSelectedClassName) async {
    String newSelectedClassId = await _firestore
        .collection('students')
        .document(studentUid)
        .collection('classes')
        .where('class name', isEqualTo: newSelectedClassName)
        .getDocuments()
        .then((value) => value.documents[0].documentID);

    updateStudentSelectedClassDataInApp(
        newSelectedClassId, newSelectedClassName);

    _fire.setStudentSelectedClass(
      classId: newSelectedClassId,
      studentUid: studentUid,
    );
  }

  void updateStudentSelectedClassDataInApp(newClassId, newClassName) {
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
            getStudentStatus(studentUid, studentSelectedClassId).then(
              (_) {
                print('get mood for selected class');
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
                    .collection("students")
                    .document(studentUid)
                    .collection('classes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Text('');
                  else {
                    List<DropdownMenuItem> dropdownEvents = [];
                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                      DocumentSnapshot documentSnapshot =
                          snapshot.data.documents[i];
                      dropdownEvents.add(
                        DropdownMenuItem(
                          child: Text(
                            documentSnapshot['class name'],
                            style: kSubTextStyle.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: "${documentSnapshot['class name']}",
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
                          color: kPrimaryColor,
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
                              child: const Icon(Icons.arrow_drop_down),
                            ),
                            value: studentSelectedClassName,
                            items: dropdownEvents,
                            onChanged: (newEventSelected) async {
                              print('testing');
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
                }),
          ),

          // Example of a dropdown with a list instead of firebase
          // Container(
          //   margin: EdgeInsets.symmetric(
          //     horizontal: MediaQuery.of(context).size.width * 0.045,
          //   ),
          //   padding: EdgeInsets.symmetric(
          //     vertical: MediaQuery.of(context).size.height * 0.02,
          //     horizontal: MediaQuery.of(context).size.width * 0.045,
          //   ),
          //   height: MediaQuery.of(context).size.height * 0.073,
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(25),
          //     border: Border.all(
          //       color: Color(0xFFE5E5E5),
          //     ),
          //   ),
          //   child: Row(
          //     children: <Widget>[
          //       SizedBox(
          //         width: 5,
          //       ),
          //       Icon(
          //         Icons.school,
          //         color: kPrimaryColor,
          //       ),
          //       SizedBox(
          //         width: 30,
          //       ),
          //       Expanded(
          //         child: DropdownButton<String>(
          //           isExpanded: true,
          //           underline: SizedBox(),
          //           icon: Icon(Icons.arrow_drop_down),
          //           value: selectedClassDisplay,
          //           items: studentClasses
          //               .map<DropdownMenuItem<String>>((String dropDownItem) {
          //             return DropdownMenuItem<String>(
          //               value: dropDownItem,
          //               child: Text(dropDownItem),
          //             );
          //           }).toList(),
          //           hint: Text(
          //             selectedClassDisplay,
          //             style: TextStyle(
          //               color: Colors.black,
          //             ),
          //           ),
          //           onChanged: (String value) {
          //             setState(() {
          //               this.selectedClass = value;
          //               this.selectedClassDisplay = value;
          //               studentSelectedClassName = value;
          //               _fire.setStudentSelectedClass(
          //                 studentUid: studentUid,
          //                 classId: 'newClassddsId',
          //               );
          //             });
          //           },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
                        studentSelectedClassId == 'no selected class' ||
                                studentSelectedClassId == ''
                            ? Text(
                                "No selected class",
                                style: TextStyle(
                                  color: kTextLightColor,
                                  fontSize: 15,
                                ),
                              )
                            : StreamBuilder(
                                stream: Firestore.instance
                                    .collection('classes')
                                    .document(studentSelectedClassId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(
                                      "Error : ${snapshot.error}",
                                      style: TextStyle(
                                        color: kTextLightColor,
                                        fontSize: 15,
                                      ),
                                    );
                                  } else {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return CircularProgressIndicator();
                                      default:
                                        return Padding(
                                          padding: EdgeInsets.only(left: 2),
                                          child: Text(
                                            snapshot.data['teacher'],
                                            style: TextStyle(
                                              color: kTextLightColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        );
                                    }
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentMessages(),
                          ),
                        );
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

                    StreamBuilder(
                      stream: Firestore.instance
                          .collection('classes')
                          .document(studentSelectedClassId)
                          .collection('students')
                          .document(studentUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text("Error : ${snapshot.error}");
                        } else {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return CircularProgressIndicator();
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
                                                            color: Colors.grey,
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
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/happy face.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
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
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/thinking face.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
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
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/sad face.png',
                                      width: 80,
                                      height: 80,
                                    ),
                                  ),
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
