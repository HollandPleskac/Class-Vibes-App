import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Testing extends StatefulWidget {
  @override
  _TestingState createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  var date = 'June 15, 2020';
  var date2 = DateFormat.yMMMMd('en_US')
      .format(
        DateTime.now(),
      )
      .toString();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: RaisedButton(
            child: Text('Click me'),
            onPressed: () {
              print(DateFormat.yMMMMd('en_US')
                  .parse(date2)
                  .difference(DateFormat.yMMMMd('en_US').parse(date)).inDays
                  .toString());
            },
          ),
        ),
      ),
    );
  }
}
