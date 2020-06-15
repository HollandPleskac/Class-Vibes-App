import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../app_drawer.dart';
import '../teacher_subscreens/classview_teacher.dart';
import '../logic/fire.dart';

final _firestore = Firestore.instance;

final _appDrawer = AppDrawer();
final _fire = Fire();

class TeacherClassesScreen extends StatefulWidget {
  @override
  _TeacherClassesScreenState createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _classIdController = TextEditingController();

  String teacherUid;
  String teacherName = '';

  Future getTeacherUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    teacherUid = userUid;
    print(teacherUid);
  }

  Future getTeacherName(uid) async {
    String nameOfTeacher =
        await _firestore.collection('teachers').document(uid).get().then(
              (docSnap) => docSnap.data['user name'],
            );
    teacherName = nameOfTeacher;
    print(teacherName);
  }

  @override
  void initState() {
    getTeacherUid().then((_) {
      print("got uid");
      getTeacherName(teacherUid).then((_) {
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
      drawer: _appDrawer.teacherDrawer(context),
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
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: AddClass(
                    teacherUid: teacherUid,
                    classNameController: _classNameController,
                    classIdController: _classIdController,
                    teacherName: teacherName,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 380,
            child: StreamBuilder(
              stream: _firestore
                  .collection('teachers')
                  .document(teacherUid)
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
                              text: document['class name'],
                              classId: document.documentID,
                              teacherName: teacherName,
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
          //   height: 380,
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
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'AP Biology',
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'Math 3 Honors',
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'English 10 Honors',
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'AP World History',
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'Physics in the Universe',
          //       ),
          //       Course(
          //         color: Colors.teal[200],
          //         text: 'Intro to Business',
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
  final String text;
  final String classId;
  final String teacherName;

  const Course({
    Key key,
    this.color,
    this.text,
    this.classId,
    this.teacherName,
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
                          text,
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
          print('pushing classview teacher');
          Navigator.pushNamed(context, ClassViewTeacher.routeName, arguments: {
            'class name': text,
            'class id': classId,
            'teacher name': teacherName,
          });
        });
  }
}

class AddClass extends StatelessWidget {
  final String teacherUid;
  final TextEditingController classIdController;
  final TextEditingController classNameController;
  final String teacherName;

  AddClass({
    this.teacherUid,
    this.classIdController,
    this.classNameController,
    this.teacherName,
  });
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              // this container and single child scroll view allow for the sheet being pushed up
              child: AddClassBottomSheet(
                teacherUid: teacherUid,
                classIdController: classIdController,
                classNameController: classNameController,
                teacherName: teacherName,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddClassBottomSheet extends StatelessWidget {
  final String teacherUid;
  final TextEditingController classNameController;
  final TextEditingController classIdController;
  final String teacherName;

  AddClassBottomSheet({
    this.teacherUid,
    this.classNameController,
    this.classIdController,
    this.teacherName,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF737373),
      //wrap with new container and set color to 0xFF737373 to see round corners
      //height: 300,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Add a Class',
                style: kHeadingTextStyle,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: AddClassForm(
                classIdController: classIdController,
                classNameController: classNameController,
                teacherUid: teacherUid,
                teacherName: teacherName,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddClassForm extends StatelessWidget {
  final Key formKey;
  final TextEditingController classNameController;
  final TextEditingController classIdController;
  final String teacherUid;
  final String teacherName;

  AddClassForm({
    this.formKey,
    this.classNameController,
    this.classIdController,
    this.teacherUid,
    this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: AddClassTextEntry(
                hintText: 'Class Name',
                icon: Icon(Icons.email),
                validator: 'class name cannot be blank',
                controller: classNameController,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: AddClassTextEntry(
                hintText: 'Class Id',
                icon: Icon(Icons.email),
                validator: 'class id cannot be blank',
                controller: classIdController,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FlatButton(
                  color: Colors.white,
                  child: Text('Create',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kPrimaryColor,
                      )),
                  onPressed: () {
                    _fire.createClass(
                      teacherUid: teacherUid,
                      className: classNameController.text,
                      classId: classIdController.text,
                      teacherName: teacherName,
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddClassTextEntry extends StatelessWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController controller;
  final String validator;

  AddClassTextEntry({
    @required this.hintText,
    @required this.icon,
    @required this.controller,
    @required this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      child: TextFormField(
        controller: controller,
        maxLines: 1,
        style: TextStyle(color: Colors.grey[700], fontSize: 16),
        autofocus: false,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Color.fromRGBO(126, 126, 126, 1),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[700],
          ),
          hintText: hintText,
          icon: icon,
        ),
        validator: (String value) {
          return validator;
        },
      ),
    );
  }
}
