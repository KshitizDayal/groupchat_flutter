import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/conversationlist.dart';
import 'package:groupchat/encryption_decryption.dart';
import 'package:intl/intl.dart';

class ListViewHomePage extends StatefulWidget {
  String name;
  String id;

  ListViewHomePage({
    required this.name,
    required this.id,
  });

  @override
  State<ListViewHomePage> createState() => _ListViewHomePageState();
}

class _ListViewHomePageState extends State<ListViewHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List docSnap = [];

  //  String id = widget.id;

  // void getNameDate() async {

  //   String id = widget.id;

  //   await _firestore.collection('groups').doc(id).get().then((value) {

  //     docSnap = value.data() as List;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // return ConversationList(
    //   name: widget.name,
    //   text: "hi",
    //   time: "12:42",
    // );
    // var xxx = _firestore
    //     .collection('groups')
    //     .doc(widget.id)
    //     .snapshots()
    //     .listen(((event) {}));

    return StreamBuilder(
        stream: _firestore.collection('groups').doc(widget.id).snapshots(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: new CircularProgressIndicator(),
            );
          }
          var userdoc = snapshot.data;
          // print(snapshot.requireData.docChanges.last.doc['lastMessage']);

          return ConversationList(
            name: userdoc['name'],
            sendBy: userdoc['lastMessageSendBy'],
            text: (userdoc['lastMessage'] == "" ||
                    userdoc['lastMessage'] == "Photo")
                ? "Photo"
                : EncryptionDecryption.decryptAES(userdoc['lastMessage']),
            time: userdoc['lastMessageSendTs'] == ""
                ? ""
                : DateFormat('kk:mm')
                    .format(userdoc['lastMessageSendTs'].toDate())
                    .toString(),
          );
        });
  }
}
