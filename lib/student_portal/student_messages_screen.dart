import 'dart:ui';

import 'package:cyber_dojo_app/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore _firestore = Firestore.instance;

class StudentMessages extends StatefulWidget {
  static const routeName = 'student-chat';
  @override
  _StudentMessagesState createState() => _StudentMessagesState();
}

class _StudentMessagesState extends State<StudentMessages> {
  final TextEditingController _controller = TextEditingController();
  void _showModalSheet() {
    showModalBottomSheet(
        barrierColor: Colors.white.withOpacity(0),
        elevation: 0,
        context: context,
        builder: (builder) {
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade300.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Options',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    ListTile(
                      onTap: () {},
                      leading: Icon(
                        Icons.do_not_disturb,
                        color: Colors.black87,
                      ),
                      title: Text(
                        'Mute Messages',
                        style: TextStyle(color: Colors.black87),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final String chatId = routeArguments['class id'];
    final String studentName = routeArguments['student name'];
    final String studentUid = routeArguments['student uid'];
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: Text(
          'Teacher Chat (as student)',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: _showModalSheet,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(
                            'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
                        fit: BoxFit.cover)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: StreamBuilder(
                  stream: _firestore
                      .collection("Chats")
                      .document(chatId)
                      .collection('Chat')
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
                                return SentChat(
                                  title: document['title'],
                                  content: document['content'],
                                );
                              },
                            ).toList(),
                          ),
                        );
                    }
                  },
                ),
                // child: ListView(
                //   reverse: true,
                //   children: <Widget>[
                //     SentChat(
                //       title: "TITLE",
                //       content:
                //           "The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps",
                //     ),
                //     RecievedChat(
                //       title: "TITLE",
                //       content:
                //           "The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps",
                //     ),
                //     SentChat(
                //       title: "TITLE",
                //       content:
                //           "The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps",
                //     ),
                //     RecievedChat(
                //       title: "TITLE",
                //       content:
                //           "The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps",
                //     ),
                //     SentChat(
                //       title: "TITLE",
                //       content:
                //           "The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps",
                //     ),
                //     RecievedChat(
                //       title: "TITLE",
                //       content:
                //           "The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps",
                //     ),
                //   ],
                // ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      await _firestore
                                          .collection('Classes')
                                          .document(
                                              'nwkptKrupotVavqfgk6msHEr83ygsm')
                                          .collection('Students')
                                          .document('HmXq850f5Wz42i1CgdCw')
                                          .collection('Chats')
                                          .document()
                                          .setData({
                                        'date': DateTime.now(),
                                        'content': _controller.text,
                                        'title': 'student user name',
                                        'sent type': 'student'
                                      });
                                      _controller.clear();
                                    }),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  // child: Center(
                                  //   child: Text(
                                  //     'Hello Mr. Shea I need help with math',
                                  //     style: TextStyle(color: Colors.black),
                                  //   ),
                                  // ),
                                  child: Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: TextField(
                                        controller: _controller,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SentChat extends StatelessWidget {
  final String title;
  final String content;

  SentChat({
    this.title,
    this.content,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 100, bottom: 30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15)),
          color: kPrimaryColor.withOpacity(0.5),
          //color: Colors.redAccent.shade400.withOpacity(0.3),
        ),
        width: 100,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              Text(
                content,
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RecievedChat extends StatelessWidget {
  final String title;
  final String content;

  RecievedChat({this.title, this.content});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 100, bottom: 30),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(15),
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15)),
            color: Colors.grey.shade200),
        width: 100,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "TITLE",
                style: TextStyle(
                    color: Colors.grey[800], fontWeight: FontWeight.w800),
              ),
              Text(
                "The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps",
                style: TextStyle(color: Colors.grey[800]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
