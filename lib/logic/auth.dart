//SWAPPING EMAIL FOR USER UID TO BE CONSISTENT WITH THE WEBSITE

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './fire.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

final _fire = Fire();

class Auth {
  Future<List> signUpAsStudent({
    BuildContext context,
    String email,
    String password,
    String userName,
  }) async {
    try {
      AuthResult _result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseUser _user = _result.user;

      _fire.createStudentAccount(
          email: email, userName: userName, userUid: _user.uid);

      //return ['success', _user.uid];
      return ['success', email];
    } catch (e) {
      return [e.message.toString(), ''];
    }
  }

  Future<List> signUpAsTeacher({
    BuildContext context,
    String email,
    String password,
    String userName,
  }) async {
    try {
      AuthResult _result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseUser _user = _result.user;

      _fire.createTeacherAccount(
        email: email,
        userName: userName,
        userUid: _user.uid,

        //school: school,
      );

      return ['success', _user.uid];
    } catch (e) {
      return [e.message.toString(), ''];
    }
  }

  Future<List> signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      AuthResult _result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser _user = _result.user;

      //returns either a teacher or a student
      String loginType = await _fire.getLoginType(email: email);
      print("LOGIN TYPE :: " + loginType);
      print('EMAIL' + email.toString());

      return ['success', _user.uid, loginType];
    } catch (e) {
      return [e.message.toString(), ''];
    }
  }

  void signOut() async {
    await _firebaseAuth.signOut();
    print('signed out with email and password');
  }

  void deleteAccount() async {
    var user = await _firebaseAuth.currentUser();

    user.delete();
  }
}
