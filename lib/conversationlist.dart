import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConversationList extends StatefulWidget {
  String name;

  String text;
  String time;
  String sendBy;

  ConversationList({
    required this.name,
    required this.text,
    required this.time,
    required this.sendBy,
  });

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List docSnap = [];

  // void getNameDate() async {
  //   String id = widget.id;

  //   await _firestore.collection('groups').doc(id).get().then((value) {
  //     // docSnapmessage = value.data()!['lastMessage'];
  //     // docSnaptime = value.data()!['lastMessageSendTs'];
  //     // docSnapsendBy = value.data()!['lastMessageSendBy'];
  //     docSnap = value.data() as List;
  //   });

  //   print(docSnapsendBy);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Icon(Icons.group),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          children: [
                            Text(
                              widget.sendBy,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            Text('~'),
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            widget.time,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
