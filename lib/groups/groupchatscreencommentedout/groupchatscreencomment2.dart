// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:groupchat/groups/message_bubble_receiver.dart';
// import 'package:groupchat/groups/message_bubble_sender.dart';

// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:encrypt/encrypt.dart' as encrypt;

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// import 'package:dash_chat/dash_chat.dart';

// import 'package:group_list_view/group_list_view.dart';
// import 'package:groupchat/appcolor.dart';
// import 'package:groupchat/groups/group_info.dart';
// import 'package:groupchat/groups/image_bubble.dart';
// import 'package:groupchat/groups/message_bubble.dart';
// import 'package:groupchat/home_screen.dart';
// import 'package:grouped_list/grouped_list.dart';

// import '../encryption_decryption.dart';
// import 'message.dart';

// class GroupChatScreenComment2 extends StatefulWidget {
//   final String groupChatId, groupName;

//   GroupChatScreenComment2(
//       {required this.groupChatId, required this.groupName, Key? key})
//       : super(key: key);
//   static const routeName = '/group-chat-screen';

//   @override
//   State<GroupChatScreenComment2> createState() => _GroupChatScreenState();
// }

// class _GroupChatScreenState extends State<GroupChatScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final TextEditingController _message = TextEditingController();

//   var _encryptedText, plainText, _decryptedText, encryptedmessage;

//   ScrollController _scrollController = ScrollController();

//   // List<Message> messages = [];
//   List messages = [];

//   // var chatlist = [];
//   // List _messaging = [];

//   var item;

//   var xyz;

//   List temp = [];

//   // void lastMessage(String message, DateTime time, String sendBy) async {
//   void onSendMessage() async {
//     String fileName = Uuid().v1();
//     var timenow = DateTime.now();

//     plainText = _message.text;
//     encrypt.Encrypted _encryptedText =
//         EncryptionDecryption.encryptAES(plainText);
//     encryptedmessage = _encryptedText is encrypt.Encrypted
//         ? _encryptedText.base64
//         : _encryptedText;
//     if (_message.text.isNotEmpty) {
//       Map<String, dynamic> chatData = <String, dynamic>{
//         "sendBy": _auth.currentUser!.displayName,
//         "message": encryptedmessage,
//         "type": "text",
//         // "time": FieldValue.serverTimestamp().toString(),
//         "time": timenow,
//         "msgid": fileName,
//       };

//       // _encryptedText = chatData['message'];

//       _message.clear();

//       // _scrollController.animateTo(
//       //   _scrollController.position.maxScrollExtent,
//       //   duration: Duration(
//       //     milliseconds: 300,
//       //   ),
//       //   curve: Curves.easeOut,
//       // );

//       await _firestore
//           .collection('groups')
//           .doc(widget.groupChatId)
//           .collection('chats')
//           .doc(fileName)
//           .set(chatData);

//       Map<String, dynamic> lastMessageInfoMap = {
//         "lastMessage": encryptedmessage,
//         "lastMessageSendTs": timenow,
//         "lastMessageSendBy": _auth.currentUser!.displayName.toString(),
//         "msgid": fileName,
//       };

//       await _firestore
//           .collection('groups')
//           .doc(widget.groupChatId)
//           .collection('lastmessage')
//           .add(lastMessageInfoMap);

//       await _firestore
//           .collection('groups')
//           .doc(widget.groupChatId)
//           .update(lastMessageInfoMap);

//       String uid = _auth.currentUser!.uid;
//       var grpid;

//       // await _firestore
//       //     .collection('users')
//       //     .doc(uid)
//       //     .collection('groups')
//       //     .get()
//       //     .then((value) {
//       //   grpid = value.docs[0].id.toString();
//       // });
//       // print(grpid);

//       // await _firestore
//       //     .collection('users')
//       //     .doc(uid)
//       //     .collection('groups')
//       //     .doc(grpid)
//       //     .update(lastMessageInfoMap);
//     }
//   }

//   File? imageFile;

//   Future getImage() async {
//     ImagePicker _picker = ImagePicker();

//     await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
//       if (xFile != null) {
//         imageFile = File(xFile.path);
//         uploadImage();
//       }
//     });

//     // String uid = _auth.currentUser!.uid;
//     // var grpid;

//     // var timenow = DateTime.now();
//   }

//   Future uploadImage() async {
//     int status = 1;
//     String fileName = Uuid().v1();
//     var timenow = DateTime.now();

//     await _firestore
//         .collection('groups')
//         .doc(widget.groupChatId)
//         .collection('chats')
//         .doc(fileName)
//         .set({
//       "sendBy": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       // "time": FieldValue.serverTimestamp().toString(),
//       "time": timenow,
//       "msgid": fileName,
//     });

//     var ref =
//         FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('groups')
//           .doc(widget.groupChatId)
//           .collection('chats')
//           .doc(fileName)
//           .delete();

//       status = 0;
//     });

//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();
//       await _firestore
//           .collection('groups')
//           .doc(widget.groupChatId)
//           .collection('chats')
//           .doc(fileName)
//           .update({
//         "sendBy": _auth.currentUser!.displayName,
//         "message": imageUrl,
//         "type": "img",
//         // "time": FieldValue.serverTimestamp().toString(),
//         "time": timenow,
//       });

//       // _scrollController.animateTo(
//       //   _scrollController.position.maxScrollExtent,
//       //   duration: Duration(
//       //     milliseconds: 300,
//       //   ),
//       //   curve: Curves.easeOut,
//       // );

//       // print(imageUrl);

//       Map<String, dynamic> lastMessageInfoMap = {
//         "lastMessage": "Photo",
//         "lastMessageSendTs": timenow,
//         "lastMessageSendBy": _auth.currentUser!.displayName.toString(),
//         "msgid": fileName,
//       };

//       await _firestore
//           .collection('groups')
//           .doc(widget.groupChatId)
//           .collection('lastmessage')
//           .add(lastMessageInfoMap);

//       await _firestore
//           .collection('groups')
//           .doc(widget.groupChatId)
//           .update(lastMessageInfoMap);
//     }
//   }

//   // void chatDatas() async {
//   //   Stream<QuerySnapshot<Map<String, dynamic>>> snapshot = await _firestore
//   //       .collection('groups')
//   //       .doc(widget.groupChatId)
//   //       .collection('chats')
//   //       .snapshots();

//   //   snapshot.forEach((element) {
//   //     var elm = element.docs;
//   //     for (var i in elm) {
//   //       var temp = i.data().entries;

//   //       item.add(temp);
//   //       print(item);
//   //     }
//   //   });
//   // }

//   // ChatUser user = ChatUser();

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
//     var i = 0;

//     var msg, send, time, type;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.groupName),
//         backgroundColor: appBarColor,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pushNamed(HomeScreen.routeName);
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.groups),
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => GroupInfo(
//                   groupName: widget.groupName,
//                   groupId: widget.groupChatId,
//                 ),
//               ),
//             ),
//           ),
//           // IconButton(onPressed: chatDatas, icon: Icon(Icons.add))
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: size.height / 1.3,
//               width: size.width,
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('groups')
//                     .doc(widget.groupChatId)
//                     .collection('chats')
//                     .orderBy('time')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     // DateFormat('kk:mm').format(chatMap['time'].toDate()).toString(),

//                     // if (DateFormat('yyyy-MM-dd')
//                     //         .format(chatName['time'].toDate())
//                     //         .toString() !=
//                     //     DateFormat('yyyy-MM-dd').format(DateTime.now())) {

//                     return ListView.builder(
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         Map<String, dynamic> chatMap =
//                             snapshot.data!.docs[index].data()
//                                 as Map<String, dynamic>;
//                         return messageTile(size, chatMap, context);
//                       },
//                     );
//                   } else {
//                     return Container();
//                   }
//                   // return Column(
//                   //   children: [
//                   //     Container(
//                   //       width: size.width,
//                   //       alignment: Alignment.center,
//                   //       child: Container(
//                   //         padding: EdgeInsets.symmetric(
//                   //             vertical: 8, horizontal: 14),
//                   //         margin: EdgeInsets.symmetric(
//                   //             vertical: 5, horizontal: 8),
//                   //         decoration: BoxDecoration(
//                   //           borderRadius: BorderRadius.circular(15),
//                   //           color: appBarColor,
//                   //         ),
//                   //         child: Text(
//                   //           DateFormat('yyyy-MM-dd')
//                   //               .format(chatName['time'].toDate())
//                   //               .toString(),
//                   //           style: const TextStyle(
//                   //             color: buttonColor,
//                   //             fontSize: 20,
//                   //             fontWeight: FontWeight.w500,
//                   //           ),
//                   //         ),
//                   //       ),
//                   //     ),
//                   //     ListView.builder(
//                   //         itemCount: snapshot.data!.docs.length,
//                   //         itemBuilder: (context, index) {
//                   //           Map<String, dynamic> chatMap =
//                   //               snapshot.data!.docs[index].data()
//                   //                   as Map<String, dynamic>;

//                   //           return messageTile(size, chatMap, context);
//                   //         }),
//                   //   ],
//                   // );
//                   // }
//                 },
//               ),
//             ),

//             // Container(
//             //   height: size.height / 1.3,
//             //   width: size.width,
//             //   child: Row(
//             //     children: [
//             //       Expanded(
//             //         child: StreamBuilder<QuerySnapshot>(
//             //             stream: _firestore
//             //                 .collection('groups')
//             //                 .doc(widget.groupChatId)
//             //                 .collection('chats')
//             //                 .orderBy('time')
//             //                 .snapshots(),
//             //             builder: (context, snapshot) {
//             //               if (!snapshot.hasData) {
//             //                 return const Center(
//             //                   child: CircularProgressIndicator(),
//             //                 );
//             //               }

//             //               return GroupedListView(
//             //                 padding: const EdgeInsets.all(8),
//             //                 // controller: _scrollController,
//             //                 reverse: true,
//             //                 order: GroupedListOrder.DESC,
//             //                 useStickyGroupSeparators: true,
//             //                 floatingHeader: true,
//             //                 shrinkWrap: true,
//             //                 // itemExtent: snapshot.data!.docs.length,
//             //                 elements: snapshot.data!.docs,
//             //                 groupBy: (message) => message['time'],
//             //                 // DateTime(
//             //                 //   message.date.year,
//             //                 //   message.date.month,
//             //                 //   message.date.day,
//             //                 // ),

//             //                 groupHeaderBuilder: (dynamic message) => SizedBox(
//             //                   height: 40,
//             //                   child: Center(
//             //                     child: Card(
//             //                       color: Theme.of(context).primaryColor,
//             //                       child: Padding(
//             //                         padding: EdgeInsets.all(8),
//             //                         child: Text(
//             //                           DateFormat.yMMMd().format(message.time),
//             //                           style: TextStyle(color: Colors.white),
//             //                         ),
//             //                       ),
//             //                     ),
//             //                   ),
//             //                 ),
//             //                 itemBuilder: (dynamic context, dynamic index) {
//             //                   if (index == snapshot.data!.docs.length) {
//             //                     return Container(
//             //                       height: 65,
//             //                     );
//             //                   }
//             //                   Map<String, dynamic> chatMap =
//             //                       snapshot.data!.docs[index].data()
//             //                           as Map<String, dynamic>;

//             //                   return messageTile(size, chatMap, context);

//             //                   // return messageTile(
//             //                   //   size,
//             //                   //   msg,
//             //                   //   send,
//             //                   //   time,
//             //                   //   type,
//             //                   //   context,
//             //                   // );
//             //                 },
//             //               );
//             //             }),
//             //       ),
//             //     ],
//             //   ),
//             // ),

//             // return ListView.builder(
//             //   // reverse: true,
//             //   controller: _scrollController,
//             //   shrinkWrap: true,
//             //   itemCount: snapshot.data!.docs.length + 1,
//             // itemBuilder: (context, index) {
//             //     if (index == snapshot.data!.docs.length) {
//             //       return Container(
//             //         height: 65,
//             //       );
//             //     }
//             //     Map<String, dynamic> chatMap =
//             //         snapshot.data!.docs[index].data()
//             //             as Map<String, dynamic>;

//             //     return messageTile(size, chatMap, context);
//             //   },
//             // );

//             // body: Container(
//             //   height: size.height,
//             //   width: size.width,
//             //   child: Column(
//             //     children: [
//             //       Expanded(
//             //         // height: size.height - 140,
//             //         child: StreamBuilder<QuerySnapshot>(
//             //           stream: _firestore
//             //               .collection('groups')
//             //               .doc(widget.groupChatId)
//             //               .collection('chats')
//             //               .orderBy(
//             //                 'time',
//             //                 descending: true,
//             //               )
//             //               .snapshots(),
//             //           builder: (context, snapshot) {
//             //             if (snapshot.hasData) {
//             //               // return GroupedListView<Message, DateTime>(
//             //               //   padding: const EdgeInsets.all(8),
//             //               //   controller: _scrollController,
//             //               //   reverse: true,
//             //               //   order: GroupedListOrder.DESC,
//             //               //   useStickyGroupSeparators: true,
//             //               //   floatingHeader: true,
//             //               //   shrinkWrap: true,
//             //               //   // itemExtent: snapshot.data!.docs.length,
//             //               //   elements: messaging,
//             //               //   groupBy: (message) => DateTime(
//             //               //     message.time.year,
//             //               //     message.time.month,
//             //               //     message.time.day,
//             //               //   ),
//             //               //   groupHeaderBuilder: (dynamic message) => SizedBox(
//             //               //     height: 40,
//             //               //     child: Center(
//             //               //       child: Card(
//             //               //         color: Theme.of(context).primaryColor,
//             //               //         child: Padding(
//             //               //           padding: EdgeInsets.all(8),
//             //               //           child: Text(
//             //               //             DateFormat.yMMMd().format(message.time),
//             //               //             style: TextStyle(color: Colors.white),
//             //               //           ),
//             //               //         ),
//             //               //       ),
//             //               //     ),
//             //               //   ),
//             //               //   itemBuilder: (context, Message index) {
//             //               //     for (int i = 0; i < messaging.length; i++) {
//             //               //       Map<String, dynamic> chatMap = snapshot.data!.docs[i]
//             //               //           .data() as Map<String, dynamic>;
//             //               //       return messageTile(size, chatMap, context);
//             //               //     }
//             //               //     return Container();
//             //               //   },
//             //               // );

//             //               return ListView.builder(
//             //                 reverse: true,
//             //                 controller: _scrollController,
//             //                 shrinkWrap: true,
//             //                 itemCount: snapshot.data!.docs.length + 1,
//             //                 itemBuilder: (context, index) {
//             //                   if (index == snapshot.data!.docs.length) {
//             //                     return Container(
//             //                       height: 65,
//             //                     );
//             //                   }
//             //                   Map<String, dynamic> chatMap =
//             //                       snapshot.data!.docs[index].data()
//             //                           as Map<String, dynamic>;

//             //                   return messageTile(size, chatMap, context);
//             //                 },
//             //               );
//             //             } else {
//             //               return Container();
//             //             }
//             //           },
//             //         ),
//             //       ),

//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: 58,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           width: size.width - 55,
//                           child: Card(
//                             margin:
//                                 EdgeInsets.only(left: 2, right: 2, bottom: 8),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             child: TextFormField(
//                               controller: _message,
//                               textAlignVertical: TextAlignVertical.center,
//                               keyboardType: TextInputType.multiline,
//                               maxLines: 5,
//                               minLines: 1,
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 hintText: "Type a message",
//                                 contentPadding: EdgeInsets.all(5),
//                                 suffixIcon: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       onPressed: getImage,
//                                       icon: Icon(Icons.photo),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             right: 2,
//                             bottom: 8.0,
//                           ),
//                           child: CircleAvatar(
//                             radius: 25,
//                             child: IconButton(
//                               icon: Icon(Icons.send),
//                               onPressed: onSendMessage,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget messageTile(
//       Size size, Map<String, dynamic> chatMap, BuildContext context) {
//     return Builder(
//       builder: (_) {
//         if (chatMap['type'] == "notify") {
//           return Container(
//             width: size.width,
//             alignment: Alignment.center,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: appBarColor,
//               ),
//               child: Text(
//                 chatMap['message'],
//                 style: const TextStyle(
//                   color: buttonColor,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         } else if (chatMap['type'] == "text") {
//           return MessageBubble(
//             EncryptionDecryption.decryptAES(chatMap['message']),
//             chatMap['sendBy'] == _auth.currentUser!.displayName,
//             chatMap['sendBy'],
//             DateFormat('EEEE').format(chatMap['time'].toDate()).toString(),
//             DateFormat.yMMMMEEEEd().format(chatMap['time'].toDate()).toString(),
//             DateFormat('kk-mm').format(chatMap['time'].toDate()).toString(),
//           );
//         } else if (chatMap['type'] == "img") {
//           return ImageBubble(
//             chatMap['message'],
//             chatMap['sendBy'] == _auth.currentUser!.displayName,
//             chatMap['sendBy'],
//             DateFormat('kk:mm').format(chatMap['time'].toDate()).toString(),
//           );
//         } else {
//           return SizedBox();
//         }
//       },
//     );
//   }

//   // Widget messageTileSender(
//   //     Size size, Map<String, dynamic> chatMap, BuildContext context) {
//   //   return Builder(
//   //     builder: (_) {
//   //       if (chatMap['type'] == "notify") {
//   //         return Container(
//   //           width: size.width,
//   //           alignment: Alignment.center,
//   //           child: Container(
//   //             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//   //             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//   //             decoration: BoxDecoration(
//   //               borderRadius: BorderRadius.circular(15),
//   //               color: appBarColor,
//   //             ),
//   //             child: Text(
//   //               chatMap['message'],
//   //               style: const TextStyle(
//   //                 color: buttonColor,
//   //                 fontSize: 20,
//   //                 fontWeight: FontWeight.w500,
//   //               ),
//   //             ),
//   //           ),
//   //         );
//   //       } else if (chatMap['type'] == "text") {
//   //         return MessageBubbleSender(
//   //           EncryptionDecryption.decryptAES(chatMap['message']),
//   //           // chatMap['sendBy'] == _auth.currentUser!.displayName,
//   //           chatMap['sendBy'],
//   //           DateFormat('EEEE').format(chatMap['time'].toDate()).toString(),
//   //           DateFormat.yMMMMEEEEd().format(chatMap['time'].toDate()).toString(),
//   //           DateFormat('kk-mm').format(chatMap['time'].toDate()).toString(),
//   //         );
//   //       } else if (chatMap['type'] == "img") {
//   //         return ImageBubble(
//   //           chatMap['message'],
//   //           chatMap['sendBy'] == _auth.currentUser!.displayName,
//   //           chatMap['sendBy'],
//   //           DateFormat('kk:mm').format(chatMap['time'].toDate()).toString(),
//   //         );
//   //       } else {
//   //         return SizedBox();
//   //       }
//   //     },
//   //   );
//   // }

//   // Widget messageTileReceiver(
//   //     Size size, Map<String, dynamic> chatMap, BuildContext context) {
//   //   return Builder(
//   //     builder: (_) {
//   //       if (chatMap['type'] == "notify") {
//   //         return Container(
//   //           width: size.width,
//   //           alignment: Alignment.center,
//   //           child: Container(
//   //             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//   //             margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//   //             decoration: BoxDecoration(
//   //               borderRadius: BorderRadius.circular(15),
//   //               color: appBarColor,
//   //             ),
//   //             child: Text(
//   //               chatMap['message'],
//   //               style: const TextStyle(
//   //                 color: buttonColor,
//   //                 fontSize: 20,
//   //                 fontWeight: FontWeight.w500,
//   //               ),
//   //             ),
//   //           ),
//   //         );
//   //       } else if (chatMap['type'] == "text") {
//   //         return MessageBubbleReceiver(
//   //           EncryptionDecryption.decryptAES(chatMap['message']),
//   //           // chatMap['sendBy'] == _auth.currentUser!.displayName,
//   //           chatMap['sendBy'],
//   //           DateFormat('EEEE').format(chatMap['time'].toDate()).toString(),
//   //           DateFormat.yMMMMEEEEd().format(chatMap['time'].toDate()).toString(),
//   //           DateFormat('kk-mm').format(chatMap['time'].toDate()).toString(),
//   //         );
//   //       } else if (chatMap['type'] == "img") {
//   //         return ImageBubble(
//   //           chatMap['message'],
//   //           chatMap['sendBy'] == _auth.currentUser!.displayName,
//   //           chatMap['sendBy'],
//   //           DateFormat('kk:mm').format(chatMap['time'].toDate()).toString(),
//   //         );
//   //       } else {
//   //         return SizedBox();
//   //       }
//   //     },
//   //   );
//   // }

// //   Widget messageTile(
// //     Size size,
// //     message,
// //     sendBy,
// //     time,
// //     type,
// //     BuildContext context,
// //   ) {
// //     return Builder(
// //       builder: (_) {
// //         print(message);
// //         print(sendBy);
// //         print(time);
// //         print(type);
// //         if (type == "notify") {
// //           return Container(
// //             width: size.width,
// //             alignment: Alignment.center,
// //             child: Container(
// //               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
// //               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(15),
// //                 color: appBarColor,
// //               ),
// //               child: Text(
// //                 message,
// //                 style: const TextStyle(
// //                   color: buttonColor,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ),
// //           );
// //         } else if (type == "text") {
// //           print(message);
// //           return MessageBubble(
// //             EncryptionDecryption.decryptAES(message),
// //             sendBy == _auth.currentUser!.displayName,
// //             sendBy,
// //             DateFormat('kk:mm').format(time.toDate()).toString(),
// //           );
// //         } else if (type == "img") {
// //           // print(DateFormat.Hm().parse(chatMap['time'].toString()));
// //           // print(chatMap);

// //           return ImageBubble(
// //             message,
// //             sendBy == _auth.currentUser!.displayName,
// //             sendBy,
// //             DateFormat('kk:mm').format(time.toDate()).toString(),
// //           );
// //         } else {
// //           return SizedBox();
// //         }
// //       },
// //     );
// //   }
// // }

// // class ShowImage extends StatelessWidget {
// //   final String imageurl;
// //   const ShowImage({required this.imageurl, Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final Size size = MediaQuery.of(context).size;
// //     return Scaffold(
// //       body: Container(
// //         height: size.height,
// //         width: size.width,
// //         color: appBarColor,
// //         child: Image.network(imageurl),
// //       ),
// //     );
// //   }
// // }
// }
