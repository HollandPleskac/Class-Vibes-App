import 'package:cyber_dojo_app/constant.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constant.dart';
import '../app_drawer.dart';

import '../teacher_subscreens/student_red.dart';
import '../teacher_subscreens/student_green.dart';
import '../teacher_subscreens/student_yellow.dart';
import '../logic/fire.dart';

final _appDrawer = AppDrawer();
final _fire = Fire();
final Firestore _firestore = Firestore.instance;

class TeacherDash extends StatefulWidget {
  @override
  _TeacherDashState createState() => _TeacherDashState();
}

class _TeacherDashState extends State<TeacherDash> {
  List<String> studentClasses = [
    'AP Biology',
    'Honors Chemistry',
    'Math 3 Honors'
  ];

  //String selectedClass = 'AP Biology';
  //String selectedClassDisplay = 'AP Biology';

  String teacherUid = '';
  String teacherSelectedClassId = '';
  String teacherSelectedClassName;
  String teacherSelectedClassNameDisplay = 'loading';

  Future getTeacherUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    teacherUid = userUid;
    print(teacherUid);
  }

  Future getTeacherClassId(String uid) async {
    try {
      String classIdentification =
          await _firestore.collection('UserData').document(uid).get().then(
                (docSnap) => docSnap.data['selected class'],
              );
      teacherSelectedClassId = classIdentification;
    } catch (e) {
      teacherSelectedClassId = null;
    }
  }

  Future getTeacherClassNameDisplay(uid, selectedClassId) async {
    try {
      String className = await _firestore
          .collection('Classes')
          .document(selectedClassId)
          .get()
          .then(
            (docSnap) => docSnap.data['class-name'],
          );

      teacherSelectedClassNameDisplay = className;
    } catch (e) {
      teacherSelectedClassNameDisplay = 'No Classes';
    }
  }

  Future setTeacherNewSelectedClassID(String newSelectedClassName) async {
    String newSelectedClassId = await _firestore
        .collection('UserData')
        .document(teacherUid)
        .collection('Classes')
        .where('class-name', isEqualTo: newSelectedClassName)
        .getDocuments()
        .then((value) => value.documents[0].documentID);

    updateTeacherSelectedClassDataInApp(
        newSelectedClassId, newSelectedClassName);

    _fire.setTeacherSelectedClass(
      classId: newSelectedClassId,
      teacherUid: teacherUid,
    );
  }

  void updateTeacherSelectedClassDataInApp(newClassId, newClassName) {
    setState(() {
      teacherSelectedClassId = newClassId;

      teacherSelectedClassName = newClassName;

      teacherSelectedClassNameDisplay = newClassName;
    });
  }

  @override
  void initState() {
    getTeacherUid().then((_) {
      print("got uid");
      getTeacherClassId(teacherUid).then((_) {
        print("got class id");
        getTeacherClassNameDisplay(teacherUid, teacherSelectedClassId).then(
          (_) {
            print('got class name');
            setState(() {
              print('uid ' + teacherUid);
              print('class id ' + teacherSelectedClassId);
              print('class name display' + teacherSelectedClassNameDisplay);
              // print(
              //   _firestore
              //       .collection('classes')
              //       .document(teacherSelectedClassId)
              //       .collection("students")
              //       .where((documentSnapshot) =>
              //           documentSnapshot.data['green'] == true)
              //       .toString(),
              // );
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
                //   alignment: Alignment.bottomRight,
                //   image: AssetImage('assets/images/virus.png'),
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
                                  'Teacher Dashboard',
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white, fontSize: 32),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  teacherSelectedClassNameDisplay == null ||
                                          teacherSelectedClassNameDisplay ==
                                              '' ||
                                          teacherSelectedClassNameDisplay ==
                                              'No Classes'
                                      ? 'No Selected Class'
                                      : teacherSelectedClassNameDisplay,
                                  //'Spring 2020',
                                  style: kSubTextStyle.copyWith(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.07,right:20,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SvgPicture.asset(
                              'assets/images/undraw_donut_love_kau1.svg',
                              width: MediaQuery.of(context).size.height * 0.23,
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
                    .document(teacherUid)
                    .collection('Classes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
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
                        Text(
                          'No Classes',
                          style: kSubTextStyle,
                        ),
                        Spacer(),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: const Icon(Icons.arrow_drop_down),
                        ),
                      ],
                    );
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
                                value: teacherSelectedClassName,
                                items: dropdownEvents,
                                onChanged: (newEventSelected) async {
                                  await setTeacherNewSelectedClassID(
                                    newEventSelected,
                                  );
                                  // setState(() {});
                                },
                                hint: Text(teacherSelectedClassNameDisplay,
                                    style: kSubTextStyle.copyWith(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
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
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'What\'s the mood of your class?',
                    style: kTitleTextstyle.copyWith(
                        color: Colors.black, fontSize: 22),
                  ),
                ),
                teacherSelectedClassNameDisplay == null ||
                        teacherSelectedClassNameDisplay == '' ||
                        teacherSelectedClassNameDisplay == 'No Classes'
                    ? PieChartSample1()
                    : PieChartSample2(
                        selectedClassId: teacherSelectedClassId,
                      ),
              ],
            ),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: _appDrawer.teacherDrawer(context),
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

class PieChartSample2 extends StatefulWidget {
  final String selectedClassId;
  const PieChartSample2({
    @required this.selectedClassId,
  });

  @override
  State<StatefulWidget> createState() => PieChart2State(selectedClassId);
}

// This class needs info
class PieChart2State extends State {
  int touchedIndex;
  String selectedClassId;
  PieChart2State(this.selectedClassId);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: StreamBuilder(
                stream: _firestore
                    .collection('Classes')
                    .document(selectedClassId)
                    .collection("Students")
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
                        return PieChart(
                          PieChartData(
                            pieTouchData:
                                PieTouchData(touchCallback: (pieTouchResponse) {
                              print(pieTouchResponse.touchedSectionIndex);
                              setState(() {
                                //getting variables for green,yellow, and red students
                                var greenStudents = snapshot.data.documents
                                    .where((documentSnapshot) =>
                                        documentSnapshot.data['mood'] ==
                                        'green')
                                    .length
                                    .toDouble();
                                var yellowStudents = snapshot.data.documents
                                    .where((documentSnapshot) =>
                                        documentSnapshot.data['mood'] ==
                                        'yellow')
                                    .length
                                    .toDouble();
                                var redStudents = snapshot.data.documents
                                    .where((documentSnapshot) =>
                                        documentSnapshot.data['mood'] == 'red')
                                    .length
                                    .toDouble();
                                var totalStudents = (snapshot.data.documents
                                        .where((documentSnapshot) =>
                                            documentSnapshot.data['mood'] ==
                                            'green')
                                        .length
                                        .toDouble() +
                                    snapshot.data.documents
                                        .where((documentSnapshot) =>
                                            documentSnapshot.data['mood'] ==
                                            'yellow')
                                        .length
                                        .toDouble() +
                                    snapshot.data.documents
                                        .where((documentSnapshot) =>
                                            documentSnapshot.data['mood'] ==
                                            'red')
                                        .length
                                        .toDouble());

                                // if (
                                //   pieTouchResponse.touchInput
                                //         is FlLongPressEnd ||
                                //     pieTouchResponse.touchInput is FlPanEnd
                                //     ) {
                                //   touchedIndex = -1;
                                // } else {

                                //regular way to get the touched index
                                touchedIndex =
                                    pieTouchResponse.touchedSectionIndex;

                                ///
                                ///
                                ///
                                //fixes error where you cannot click on graph if it is 100% of one value
                                if ((yellowStudents / totalStudents * 100)
                                            .toStringAsFixed(0) +
                                        '%' ==
                                    '100%') {
                                  print('100 percent yellow');
                                  touchedIndex = 1;
                                } else if ((greenStudents / totalStudents * 100)
                                            .toStringAsFixed(0) +
                                        '%' ==
                                    '100%') {
                                  print('100 percent green');
                                  touchedIndex = 0;
                                } else if ((redStudents / totalStudents * 100)
                                            .toStringAsFixed(0) +
                                        '%' ==
                                    '100%') {
                                  print('100 percent red');
                                  touchedIndex = 2;
                                }

                                //end of error fixing
                                ///
                                ///
                                ///
                                print(pieTouchResponse.touchedSection);
                                if (touchedIndex == 0) {
                                  print('touched students doing great');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentGreen(),
                                    ),
                                  );
                                } else if (touchedIndex == 1) {
                                  print('touched help students');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentYellow(),
                                    ),
                                  );
                                } else if (touchedIndex == 2) {
                                  print('touched frustrated students');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentRed(),
                                    ),
                                  );
                                }
                                //}
                              });
                            }),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            // startDegreeOffset: 255,
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: showingSections(
                              // filters the students based on color - returns list of students w/ that color - then gives length of that color to showingSection()
                              greenStudents: snapshot.data.documents
                                  .where((documentSnapshot) =>
                                      documentSnapshot.data['mood'] == 'green')
                                  .length
                                  .toDouble(),
                              yellowStudents: snapshot.data.documents
                                  .where((documentSnapshot) =>
                                      documentSnapshot.data['mood'] == 'yellow')
                                  .length
                                  .toDouble(),
                              redStudents: snapshot.data.documents
                                  .where((documentSnapshot) =>
                                      documentSnapshot.data['mood'] == 'red')
                                  .length
                                  .toDouble(),
                              totalStudents: (snapshot.data.documents
                                      .where((documentSnapshot) =>
                                          documentSnapshot.data['mood'] ==
                                          'green')
                                      .length
                                      .toDouble() +
                                  snapshot.data.documents
                                      .where((documentSnapshot) =>
                                          documentSnapshot.data['mood'] ==
                                          'yellow')
                                      .length
                                      .toDouble() +
                                  snapshot.data.documents
                                      .where((documentSnapshot) =>
                                          documentSnapshot.data['mood'] ==
                                          'red')
                                      .length
                                      .toDouble()),
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: Text('No Students'),
                      );
                    case ConnectionState.none:
                      return Text('Connection state returned none');
                    case ConnectionState.done:
                      return Text('Connection state finished');
                    default:
                      return Text('default');
                  }
                },
              ),

              //OLD STREAMBUILDER WHICH CALCULATES BASED ON A QUERY THAT CRASHES
              // child: StreamBuilder(
              //     stream: Firestore.instance
              //         .collection('classes')
              //         .document(selectedClassId)
              //         .snapshots(),
              //     builder: (context, snapshot) {
              //       if (!snapshot.hasData) {
              //         return CircularProgressIndicator();
              //       }

              //       return PieChart(
              //         PieChartData(
              //           pieTouchData:
              //               PieTouchData(touchCallback: (pieTouchResponse) {
              //             setState(() {
              //               if (pieTouchResponse.touchInput is FlLongPressEnd ||
              //                   pieTouchResponse.touchInput is FlPanEnd) {
              //                 touchedIndex = -1;
              //               } else {
              //                 touchedIndex =
              //                     pieTouchResponse.touchedSectionIndex;
              //                 if (touchedIndex == 0) {
              //                   print('touched students doing great');
              //                   Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                       builder: (context) => StudentGreen(),
              //                     ),
              //                   );
              //                 } else if (touchedIndex == 1) {
              //                   print('touched help students');
              //                   Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                       builder: (context) => StudentYellow(),
              //                     ),
              //                   );
              //                 } else if (touchedIndex == 2) {
              //                   print('touched frustrated students');
              //                   Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                       builder: (context) => StudentRed(),
              //                     ),
              //                   );
              //                 }
              //               }
              //             });
              //           }),
              //           borderData: FlBorderData(
              //             show: false,
              //           ),
              //           startDegreeOffset: 255,
              //           sectionsSpace: 0,
              //           centerSpaceRadius: 40,
              //           sections: showingSections(
              //             // greenStudents: double.parse(snapshot.data['green students']),
              //             // yellowStudents: double.parse(snapshot.data['yellow students']),
              //             // redStudents: double.parse(snapshot.data['red students']),
              //             greenStudents:
              //                 snapshot.data['green students'].toDouble(),
              //             yellowStudents:
              //                 snapshot.data['yellow students'].toDouble(),
              //             redStudents: snapshot.data['red students'].toDouble(),
              //             totalStudents: (snapshot.data['green students'] +
              //                     snapshot.data['yellow students'] +
              //                     snapshot.data['red students'])
              //                 .toDouble(),
              //           ),
              //         ),
              //       );
              //     }),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Indicator(
                color: kGreenColor,
                text: 'Doing Great',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Color(0xfff8b250),
                text: 'Need Help',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: kRedColor,
                text: 'Frustrated',
                isSquare: true,
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      {double greenStudents,
      double yellowStudents,
      double redStudents,
      double totalStudents}) {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      //final double fontSize = isTouched ? 20 : 16;
      final double fontSize = 16;
      // final double radius = isTouched ? 60 : 50;
      final double radius = 50;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: kGreenColor,
            value: greenStudents,
            title: greenStudents != 0
                ? (greenStudents / totalStudents * 100).toStringAsFixed(0) + '%'
                : '',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: yellowStudents,
            title: yellowStudents != 0
                ? (yellowStudents / totalStudents * 100).toStringAsFixed(0) +
                    '%'
                : '',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

        case 2:
          return PieChartSectionData(
            color: kRedColor,
            value: redStudents,
            title: redStudents != 0
                ? (redStudents / totalStudents * 100).toStringAsFixed(0) + '%'
                : '',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          return null;
      }
    });
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

//sample that is shown if there is no data
class PieChartSample1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PieChart1State();
}

class PieChart1State extends State {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                    pieTouchData:
                        PieTouchData(touchCallback: (pieTouchResponse) {
                      setState(() {
                        if (pieTouchResponse.touchInput is FlLongPressEnd ||
                            pieTouchResponse.touchInput is FlPanEnd) {
                          touchedIndex = -1;
                        } else {
                          touchedIndex = pieTouchResponse.touchedSectionIndex;
                        }
                      });
                    }),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections()),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Indicator(
                color: kGreenColor,
                text: 'Doing Great',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Color(0xfff8b250),
                text: 'Need Help',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: kRedColor,
                text: 'Frustrated',
                isSquare: true,
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(1, (i) {
      final isTouched = i == touchedIndex;
      // final double fontSize = isTouched ? 25 : 16;
      final double fontSize = 16;
      // final double radius = isTouched ? 60 : 50;
      final double radius = 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 100,
            title: '',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );

        default:
          return null;
      }
    });
  }
}
