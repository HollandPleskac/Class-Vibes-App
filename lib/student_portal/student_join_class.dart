import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../app_drawer.dart';
import '../logic/fire.dart';

final _appDrawer = AppDrawer();
final Firestore _firestore = Firestore.instance;
final _fire = Fire();

class StudentJoinClassScreen extends StatefulWidget {
  @override
  _StudentJoinClassScreenState createState() => _StudentJoinClassScreenState();
}

class _StudentJoinClassScreenState extends State<StudentJoinClassScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   final TextEditingController _joinClassController = TextEditingController();

  String studentUid = '';

  String studentName = '';

  Future getStudentUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userUid = prefs.getString('uid');

    studentUid = userUid;
    print(studentUid);
  }

  Future getStudentName(uid) async {
    String nameOfStudent = await _firestore
        .collection('UserData')
        .document(uid)
        .get()
        .then((docSnap) => docSnap.data['username']);

    studentName = nameOfStudent;
  }

  @override
  void initState() {
    getStudentUid().then((_) {
      print("got uid");
      getStudentName(studentUid).then((_) {
        print("got student name ");
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
                                  'Join a class',
                                  style: kHeadingTextStyle.copyWith(
                                      color: Colors.white, fontSize: 32),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'as Holland Pleskac',
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
            Text('Join a class (enter class code)'),
            TextField(
              controller: _joinClassController,
            ),
            RaisedButton(
              child: Text('join'),
              onPressed: () async {
                String success = await _fire.joinClass(
                  classCode: int.parse(_joinClassController.text).toInt(),
                  studentName: studentName,
                  studentUid: studentUid,
                );
                print('is success : ' + success);
                if (success == 'failure') {
                  final snackBar = SnackBar(
                    content: Text('That Code Does Not Exist!'),
                    action: SnackBarAction(
                      label: 'Hide',
                      onPressed: () {
                        _scaffoldKey.currentState.hideCurrentSnackBar();
                      },
                    ),
                  );
                 
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
