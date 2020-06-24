//Testing the chat feature

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final Firestore _firestore = Firestore.instance;

class Testing extends StatefulWidget {
  @override
  _TestingState createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                height: 500,
                padding: EdgeInsets.only(top: 25),
                child: StreamBuilder(
                  stream: _firestore
                      .collection("Classes")
                      .document("nwkptKrupotVavqfgk6msHEr83ygsm")
                      .collection('Students')
                      .document('HmXq850f5Wz42i1CgdCw')
                      .collection('Chats')
                      .orderBy("date", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        return Center(
                          child: ListView(
                            reverse: true,
                            children: snapshot.data.documents.map(
                              (DocumentSnapshot document) {
                                return Text(document['content']);
                              },
                            ).toList(),
                          ),
                        );
                    }
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.7,
                    child: TextField(
                      controller: _controller,
                    ),
                  ),
                  RaisedButton(
                    child: Text('submit'),
                    onPressed: () async {
                      await _firestore
                          .collection('Classes')
                          .document('nwkptKrupotVavqfgk6msHEr83ygsm')
                          .collection('Students')
                          .document('HmXq850f5Wz42i1CgdCw')
                          .collection('Chats')
                          .document()
                          .setData({
                        'date': DateTime.now(),
                        'content': _controller.text,
                      });
                      _controller.clear();
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
