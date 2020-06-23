import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class Testing extends StatefulWidget {
  @override
  _TestingState createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  DateTime currentD = DateTime.now();
  var date = 'June 29, 2020';
  var date2 = DateFormat.yMMMMd('en_US')
      .format(
        DateTime.now(),
      )
      .toString();
  var date4 = DateFormat.yMMMMd('en_US').parse(
    DateFormat.yMMMMd('en_US').format(
      DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    String date3 = DateFormat.yMMMMd().format(
      currentD,
    );
    DateTime date3ConvertedToDateTime = DateFormat.yMMMMd('en_US').parse(date3);
    return Scaffold(
      body: Center(
        child: Container(
          child: RaisedButton(
            child: Text('Click me'),
            onPressed: () {
              print('FOUR : ' + date4.toString());
              print('THREE : ' + date3.toString());
              print('TWO : ' + date2.toString());
              print('ONE : ' + date.toString());
              // print(
              //   DateFormat.yMMMMd('en_US').parse(
              //     DateFormat.yMMMMd('en_US').format(
              //       DateTime.now(),
              //     ),
              //   ),
              // );
              print(
                DateFormat.yMMMMd('en_US')
                    .parse(date3)
                    .difference(DateFormat.yMMMMd('en_US').parse(date2))
                    .inDays
                    .toString(),
              );
              print(DateFormat.yMMMMd('en_US')
                  .parse('July 22, 2004')
                  .difference(
                    DateFormat.yMMMMd('en_US').parse(date3),
                  )
                  .inDays);
              print(
                'SUBTRACTION ' +
                    //  DateTime.parse(date3ConvertedToDateTime.subtract(Duration(days: 100)).toString()).toString()
                    Jiffy(DateTime.parse(date3ConvertedToDateTime
                            .subtract(Duration(days: 100)).toString()))
                        .yMMMMd,
              );
              // Jiffy("2019-10-18").yMMMMd);
            },
          ),
        ),
      ),
    );
  }
}
