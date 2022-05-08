import 'dart:io';
import 'package:flutter/material.dart';
import 'package:groupchat/groups/message_bubble_receiver.dart';
import 'package:groupchat/groups/message_bubble_sender.dart';
import 'package:groupchat/groups/replymessagewidget.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:uuid/uuid.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:dash_chat/dash_chat.dart';

import 'package:group_list_view/group_list_view.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/groups/group_info.dart';
import 'package:groupchat/groups/image_bubble.dart';
import 'package:groupchat/groups/message_bubble.dart';
import 'package:groupchat/home_screen.dart';
import 'package:grouped_list/grouped_list.dart';

import '../encryption_decryption.dart';
import 'message.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupChatId, groupName;

  GroupChatScreen(
      {required this.groupChatId, required this.groupName, Key? key})
      : super(key: key);
  static const routeName = '/group-chat-screen';

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _message = TextEditingController();

  var _encryptedText, plainText, _decryptedText, encryptedmessage;

  ScrollController _scrollController = ScrollController();

  List messages = [];

  var item;

  var xyz;

  List temp = [];

  // void lastMessage(String message, DateTime time, String sendBy) async {
  void onSendMessage() async {
    String fileName = Uuid().v1();
    var timenow = DateTime.now();

    plainText = _message.text;
    encrypt.Encrypted _encryptedText =
        EncryptionDecryption.encryptAES(plainText);
    encryptedmessage = _encryptedText is encrypt.Encrypted
        ? _encryptedText.base64
        : _encryptedText;
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = <String, dynamic>{
        "sendBy": _auth.currentUser!.displayName,
        "message": encryptedmessage,
        "type": "text",
        // "time": FieldValue.serverTimestamp().toString(),
        "time": timenow,
        "msgid": fileName,
      };

      _message.clear();

      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: Duration(
      //     milliseconds: 300,
      //   ),
      //   curve: Curves.easeOut,
      // );

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .set(chatData);

      Map<String, dynamic> lastMessageInfoMap = {
        "lastMessage": encryptedmessage,
        "lastMessageSendTs": timenow,
        "lastMessageSendBy": _auth.currentUser!.displayName.toString(),
        "msgid": fileName,
      };

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('lastmessage')
          .add(lastMessageInfoMap);

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .update(lastMessageInfoMap);

      String uid = _auth.currentUser!.uid;
      var grpid;
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
    int status = 1;
    String fileName = Uuid().v1();
    var timenow = DateTime.now();

    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      // "time": FieldValue.serverTimestamp().toString(),
      "time": timenow,
      "msgid": fileName,
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({
        "sendBy": _auth.currentUser!.displayName,
        "message": imageUrl,
        "type": "img",
        // "time": FieldValue.serverTimestamp().toString(),
        "time": timenow,
      });

      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: Duration(
      //     milliseconds: 300,
      //   ),
      //   curve: Curves.easeOut,
      // );

      // print(imageUrl);

      Map<String, dynamic> lastMessageInfoMap = {
        "lastMessage": "Photo",
        "lastMessageSendTs": timenow,
        "lastMessageSendBy": _auth.currentUser!.displayName.toString(),
        "msgid": fileName,
      };

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('lastmessage')
          .add(lastMessageInfoMap);

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .update(lastMessageInfoMap);
    }
  }

  var replyMessage;
  final focusNode = FocusNode();
  late final VoidCallback onCancelreply;

  void onSwippedMessage(chatMap) {
    replytoMessage(chatMap);
    focusNode.requestFocus();
  }

  void replytoMessage(message) {
    setState(() {
      replyMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isReplying = replyMessage != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
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
                  groupName: widget.groupName,
                  groupId: widget.groupChatId,
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
                    .doc(widget.groupChatId)
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
                        return SwipeTo(
                          onRightSwipe: () => onSwippedMessage(chatMap),
                          child: messageTile(size, chatMap, context),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 58,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: size.width - 55,
                          child: Card(
                            margin:
                                EdgeInsets.only(left: 2, right: 2, bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(
                              children: [
                                if (isReplying) buildReply(),
                                TextFormField(
                                  focusNode: focusNode,
                                  controller: _message,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Type a message",
                                    contentPadding: EdgeInsets.all(5),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: getImage,
                                          icon: Icon(Icons.photo),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 2,
                            bottom: 8.0,
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            child: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: onSendMessage,
                            ),
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
    );
  }

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
          return MessageBubble(
            EncryptionDecryption.decryptAES(chatMap['message']),
            chatMap['sendBy'] == _auth.currentUser!.displayName,
            chatMap['sendBy'],
            DateFormat('EEEE').format(chatMap['time'].toDate()).toString(),
            DateFormat.yMMMMEEEEd().format(chatMap['time'].toDate()).toString(),
            DateFormat('kk-mm').format(chatMap['time'].toDate()).toString(),
          );
        } else if (chatMap['type'] == "img") {
          return ImageBubble(
            chatMap['message'],
            chatMap['sendBy'] == _auth.currentUser!.displayName,
            chatMap['sendBy'],
            DateFormat('kk:mm').format(chatMap['time'].toDate()).toString(),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget buildReply() => Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(24),
            )),
        child: ReplyMessageWidget(
          message: replyMessage,
          onCancelreply: onCancelreply,
        ),
      );
}
