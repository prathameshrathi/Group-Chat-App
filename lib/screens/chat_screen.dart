import 'dart:collection';

import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final _auth = FirebaseAuth.instance;
User loggedInUser;

class _ChatScreenState extends State<ChatScreen> {
  final msgTextController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String message;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  // void getMessage() async {
  //   var snapshotList = _firestore.collection('messages').snapshots();
  //   await for (var snapshot in snapshotList) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
                //getMessage();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                  );
                }
                final messages = snapshot.data.docs;
                List<BubbleMessage> messageWidgetList = [];
                for (var message in messages) {
                  final msg = message.data();
                  final messageText = msg;
                  final messageWidget = BubbleMessage(messageText);
                  messageWidgetList.add(messageWidget);
                }
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      children: messageWidgetList,
                      // controller: 
                    ),
                  ),
                );
              },
              stream: _firestore.collection('messages').orderBy('createdAt',descending: true).snapshots(),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      var data = {'text': message, 'sender': loggedInUser.email,'createdAt': DateTime.now()};
                      _firestore
                          .collection('messages').add(data);
                      // _firestore.collection('messages').orderBy('createdAt',descending: true);
                      // _firestore.collection("messages")
                      //   .orderBy("createdAt", "asc");
                      msgTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleMessage extends StatelessWidget {
  LinkedHashMap messageText;
  BubbleMessage(this.messageText);
  bool isMe = false;
  @override
  Widget build(BuildContext context) {
    if (messageText['sender'] == loggedInUser.email) {
      isMe = true;
    }
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text(
            messageText['sender'],
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          SizedBox(
            height: 3,
          ),
          Material(
              elevation: 7,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  messageText['text'],
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),

                ),
              )),
        ],
      ),
    );
  }
}
