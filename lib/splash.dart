import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './constant.dart';
import 'dart:async';

import './auth_screens/login_screen_dummy.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreenDummy(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.school,
                        color: kPrimaryColor,
                        size: 40,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'ClassVibe',
                      style: kHeadingTextStyle.copyWith(
                          color: Colors.white, fontSize: 23),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    SpinKitWave(
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Classrooms made efficient',
                      style: kHeadingTextStyle.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
