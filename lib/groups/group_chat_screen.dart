import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/groups/group_info.dart';
import 'package:groupchat/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupChatScreen extends StatelessWidget {
  final String groupChatId, groupName;

  GroupChatScreen(
      {required this.groupChatId, required this.groupName, Key? key})
      : super(key: key);
  static const routeName = '/group-chat-screen';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _message = TextEditingController();

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  File? imageFile;
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({
        "sendBy": _auth.currentUser!.displayName,
        "message": imageUrl,
        "type": "img",
        "time": FieldValue.serverTimestamp(),
      });

      print(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed(HomeScreen.routeName);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.groups),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GroupInfo(
                  groupName: groupName,
                  groupId: groupChatId,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.3,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        return messageTile(size, chatMap, context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    Container(
                      height: size.height / 12,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () => getImage(),
                            icon: Icon(Icons.photo),
                          ),
                          hintText: "Send Message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: onSendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget messageTile(Size size, Map<String, dynamic> chatMap) {
  //   return Container(
  //     width: size.width,
  //     alignment: chatMap['sendBy'] == currentUserName
  //         ? Alignment.centerRight
  //         : Alignment.centerLeft,
  //     padding: EdgeInsets.symmetric(
  //       horizontal: size.width / 100,
  //       vertical: size.height / 400,
  //     ),
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         vertical: size.height / 50,
  //         horizontal: size.width / 40,
  //       ),
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(15), color: Colors.blue),
  //       child: Text(chatMap['message']),
  //     ),
  //   );
  // }

  Widget messageTile(
      Size size, Map<String, dynamic> chatMap, BuildContext context) {
    return Builder(
      builder: (_) {
        if (chatMap['type'] == "notify") {
          return Container(
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: appBarColor,
              ),
              child: Text(
                chatMap['message'],
                style: const TextStyle(
                  color: buttonColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else if (chatMap['type'] == "text") {
          return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: messageColor,
              ),
              child: Column(children: [
                Text(
                  chatMap['sendBy'],
                  style: const TextStyle(
                    color: nameDisplayColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: size.height / 250,
                ),
                Text(
                  chatMap['message'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
            ),
          );
        } else if (chatMap['type'] == "img") {
          return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              // padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: messageColor,
              ),
              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: const TextStyle(
                      color: nameDisplayColor,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 250,
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShowImage(
                          imageurl: chatMap['message'],
                        ),
                      ),
                    ),
                    child: Container(
                      height: size.height / 3,
                      width: size.width / 2,
                      decoration: BoxDecoration(border: Border.all()),
                      alignment:
                          chatMap['message'] != "" ? null : Alignment.center,
                      child: chatMap['message'] != ""
                          ? Image.network(
                              chatMap['message'],
                              fit: BoxFit.cover,
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageurl;
  const ShowImage({required this.imageurl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: appBarColor,
        child: Image.network(imageurl),
      ),
    );
  }
}
