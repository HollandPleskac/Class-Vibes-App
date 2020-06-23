import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore _firestore = Firestore.instance;

class Testing extends StatefulWidget {
  @override
  _TestingState createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: RaisedButton(
            child: Text('Click Me'),
            onPressed: () {
              print(DateTime.now());
              _firestore
                  .collection("Classes")
                  .document('testingg')
                  .setData({'date': DateTime.now()});
            },
          ),
        ),
      ),
    );
  }
}
