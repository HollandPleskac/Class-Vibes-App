import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


import './login_screen.dart';
import '../teacher_portal/teacher_dash.dart';

import '../constant.dart';
import '../logic/auth.dart';

final _auth = Auth();
final _firestore = Firestore.instance;

class SignupAsTeacherScreen extends StatefulWidget {
  @override
  _SignupAsTeacherScreenState createState() => _SignupAsTeacherScreenState();
}

class _SignupAsTeacherScreenState extends State<SignupAsTeacherScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  var errorMessage = '';

  void signup() async {
    ///
    ///
    void setUid(String uidValue) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'uid',
        uidValue,
      );
    }

    if (_userNameController.text != null && _userNameController.text != '') {
      if (_passwordController.text == _passwordConfirmController.text) {
        List authPackage = await _auth.signUpAsTeacher(
          context: context,
          email: _emailController.text,
          password: _passwordConfirmController.text,
          userName: _userNameController.text,
        );

        //authPackage[0] is either success or contains the error message
        //authPackage[1] is either the user uid or null

        if (authPackage[0] == 'success') {
          // sets the uid - authPackage[1] is the uid
          setUid(authPackage[1]);
          print('signed up as teacher');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherDash(),
            ),
          );
        } else {
          setState(() {
            errorMessage = authPackage[0];
          });
          print('error  ' + authPackage[0]);
        }
      } else {
        setState(() {
          errorMessage = 'Password and Confirm Password must be equal';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Fill out all fields';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              signInText(context),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.0525,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Icon(
                  Icons.school,
                  color: kPrimaryColor,
                  size: 100,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.0725,
              ),
              signInInput(
                context: context,
                controller: _userNameController,
                hintText: 'user name',
                icon: Icon(
                  Icons.email,
                  color: kPrimaryColor,
                ),
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              signInInput(
                context: context,
                controller: _emailController,
                hintText: 'email',
                icon: Icon(
                  Icons.email,
                  color: kPrimaryColor,
                ),
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              signInInput(
                context: context,
                controller: _passwordController,
                hintText: 'password',
                icon: Icon(
                  Icons.lock,
                  color: kPrimaryColor,
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              signInInput(
                context: context,
                controller: _passwordConfirmController,
                hintText: 'confirm password',
                icon: Icon(
                  Icons.lock,
                  color: kPrimaryColor,
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009,
              ),
              signUpErrorText(context, errorMessage),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.009,
              ),
              signInButton(context, () => signup()),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.024,
              ),
              signInAlreadyHaveAccount(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget signInText(BuildContext context) {
  return Text(
    'Teacher Sign Up',
    style: kHeadingTextStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: kPrimaryColor,
      fontSize: 45,
    ),
  );
}

Widget signInInput({
  BuildContext context,
  String hintText,
  Icon icon,
  TextInputType keyboardType,
  TextEditingController controller,
  bool obscureText,
}) {
  return Center(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: kPrimaryColor,
          width: 2.25,
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding:
            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.045),
        child: TextFormField(
          controller: controller,
          maxLines: 1,
          keyboardType: keyboardType,
          style: kSubTextStyle.copyWith(color: kPrimaryColor),
          autofocus: false,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintStyle: kSubTextStyle.copyWith(color: kPrimaryColor),
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            hintText: hintText,
            icon: icon,
          ),
          // dont need a validator - solving the issue is done in the return from the sign in function
        ),
      ),
    ),
  );
}

Widget signInButton(BuildContext context, Function signinFunction) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.061,
    width: MediaQuery.of(context).size.width * 0.6,
    child: FlatButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: kPrimaryColor,
      child: Text(
        'Sign Up',
        style: kSubTextStyle.copyWith(color: Colors.white, fontSize: 21),
      ),
      onPressed: signinFunction,
    ),
  );
}

Widget signInAlreadyHaveAccount(BuildContext context) {
  return InkWell(
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "Already have an account? ",
            style: kSubTextStyle.copyWith(fontSize: 15.5),
          ),
          TextSpan(
            text: "Sign In!",
            style: TextStyle(color: kPrimaryColor, fontSize: 16),
          ),
        ],
      ),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    },
  );
}

Widget signUpErrorText(BuildContext context, String errorMessage) {
  if (errorMessage ==
      'The given password is invalid. [ Password should be at least 6 characters ]') {
    errorMessage = 'Password should be at least 6 characters';
  } else if (errorMessage == 'Given String is empty or null') {
    errorMessage = 'Fill out all fields';
  }
  return Container(
    child: Text(
      errorMessage,
      style: kErrorTextstyle,
    ),
  );
}
