// import 'dart:convert';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:groupchat/appcolor.dart';
// import 'package:groupchat/groups/group_info.dart';
// import 'package:groupchat/groups/image_bubble.dart';
// import 'package:groupchat/groups/message_bubble.dart';
// import 'package:groupchat/home_screen.dart';
// import 'package:grouped_list/grouped_list.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// import 'package:encrypt/encrypt.dart' as encrypt;

// import '../encryption_decryption.dart';
// import 'message.dart';

// class GroupChatScreenComment extends StatelessWidget {
//   final String groupChatId, groupName;

//   GroupChatScreenComment(
//       {required this.groupChatId, required this.groupName, Key? key})
//       : super(key: key);
//   static const routeName = '/group-chat-screen';

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final TextEditingController _message = TextEditingController();

//   var _encryptedText, plainText, _decryptedText, encryptedmessage;

//   ScrollController _scrollController = ScrollController();

//   List<Message> messaging = [];

//   var chatlist = [];

//   var xyz;

//   // void lastMessage(String message, DateTime time, String sendBy) async {
//   //   Map<String, dynamic> lastMessageInfoMap = {
//   //     "lastMessage": message,
//   //     "lastMessageSendTs": time,
//   //     "lastMessageSendBy": sendBy
//   //   };
//   // }

//   void onSendMessage() async {
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
//       };

//       // _encryptedText = chatData['message'];

//       _message.clear();

//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: Duration(
//           milliseconds: 300,
//         ),
//         curve: Curves.easeOut,
//       );

//       await _firestore
//           .collection('groups')
//           .doc(groupChatId)
//           .collection('chats')
//           .add(chatData);

//       Map<String, dynamic> lastMessageInfoMap = {
//         "lastMessage": encryptedmessage,
//         "lastMessageSendTs": timenow,
//         "lastMessageSendBy": _auth.currentUser!.displayName.toString(),
//       };

//       await _firestore
//           .collection('groups')
//           .doc(groupChatId)
//           .collection('lastmessage')
//           .add(lastMessageInfoMap);

//       await _firestore
//           .collection('groups')
//           .doc(groupChatId)
//           .update(lastMessageInfoMap);

//       String uid = _auth.currentUser!.uid;
//       var grpid;

//       await _firestore
//           .collection('users')
//           .doc(uid)
//           .collection('groups')
//           .get()
//           .then((value) {
//         grpid = value.docs[0].id.toString();
//       });
//       print(grpid);

//       await _firestore
//           .collection('users')
//           .doc(uid)
//           .collection('groups')
//           .doc(grpid)
//           .update(lastMessageInfoMap);
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

//     String uid = _auth.currentUser!.uid;
//     var grpid;

//     var timenow = DateTime.now();

//     Map<String, dynamic> lastMessageInfoMap = {
//       "lastMessage": "Photo",
//       "lastMessageSendTs": timenow,
//       "lastMessageSendBy": _auth.currentUser!.displayName.toString(),
//     };

//     await _firestore
//         .collection('groups')
//         .doc(groupChatId)
//         .collection('lastmessage')
//         .add(lastMessageInfoMap);

//     await _firestore
//         .collection('groups')
//         .doc(groupChatId)
//         .update(lastMessageInfoMap);
//   }

//   Future uploadImage() async {
//     String fileName = Uuid().v1();
//     int status = 1;

//     var timenow = DateTime.now();

//     await _firestore
//         .collection('groups')
//         .doc(groupChatId)
//         .collection('chats')
//         .doc(fileName)
//         .set({
//       "sendBy": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       // "time": FieldValue.serverTimestamp().toString(),
//       "time": timenow,
//     });

//     var ref =
//         FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('groups')
//           .doc(groupChatId)
//           .collection('chats')
//           .doc(fileName)
//           .delete();

//       status = 0;
//     });

//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();
//       await _firestore
//           .collection('groups')
//           .doc(groupChatId)
//           .collection('chats')
//           .doc(fileName)
//           .update({
//         "sendBy": _auth.currentUser!.displayName,
//         "message": imageUrl,
//         "type": "img",
//         // "time": FieldValue.serverTimestamp().toString(),
//         "time": DateTime.now().toString(),
//       });

//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: Duration(
//           milliseconds: 300,
//         ),
//         curve: Curves.easeOut,
//       );

//       print(imageUrl);

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

//   // void chatDatas() async {
//   //   await _firestore
//   //       .collection('groups')
//   //       .doc(groupChatId)
//   //       .collection('chats')
//   //       .get()
//   //       .then(
//   //     (value) {
//   //       chatlist = value.docs;
//   //     },
//   //   );
//   //   print(chatlist.length);

//   //   for (int i = 0; i < chatlist.length; i++) {
//   //     var date = chatlist[i]['time'];
//   //     DateFormat inputFormat = DateFormat('yyyy-MM-dd hh:mm:ss a');

//   // messaging = [
//   //   Message(
//   //     text: chatlist[i]['message'],
//   // time: date.toDate(),
//   //     sendBy: chatlist[i]['sendBy'],
//   //   ),
//   // ];

//   //     // print(chatlist[i]['sendBy']);

//   //     //2022-05-02 13:58:06.518333
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(groupName),
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
//                   groupName: groupName,
//                   groupId: groupChatId,
//                 ),
//               ),
//             ),
//           ),
//           // IconButton(onPressed: chatDatas, icon: Icon(Icons.add))
//         ],
//       ),

//       // body: Stack(
//       //   children: <Widget>[
//       //     StreamBuilder<QuerySnapshot>(
//       //       stream: _firestore
//       //           .collection('groups')
//       //           .doc(groupChatId)
//       //           .collection('chats')
//       //           .orderBy('time')
//       //           .snapshots(),
//       //       builder: (context, snapshot) {
//       //         if (snapshot.hasData) {
                // return ListView.builder(
                //   itemCount: snapshot.data!.docs.length,
                //   itemBuilder: (context, index) {
                //     Map<String, dynamic> chatMap = snapshot.data!.docs[index]
                //         .data() as Map<String, dynamic>;
                //     return messageTile(size, chatMap, context);
                //   },
                // );
//       //         } else {
//       //           return Container();
//       //         }
//       //       },
//       //     ),
//       //     Align(
//       //       alignment: Alignment.bottomLeft,
//       //       child: Container(
//       //         padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
//       //         height: 60,
//       //         width: double.infinity,
//       //         color: Colors.white,
//       //         child: Row(
//       //           children: <Widget>[
//       //             GestureDetector(
//       //               child: Container(
//       //                 height: 30,
//       //                 width: 30,
//       //                 decoration: BoxDecoration(
//       //                   color: Colors.lightBlue,
//       //                   borderRadius: BorderRadius.circular(30),
//       //                 ),
//       //                 child: Icon(
//       //                   Icons.add,
//       //                   color: Colors.white,
//       //                   size: 20,
//       //                 ),
//       //               ),
//       //             ),
//       //             SizedBox(
//       //               width: 15,
//       //             ),
//       //             Expanded(
//       //               child: TextField(
//       //                 controller: _message,
//       //                 decoration: InputDecoration(
//       //                     suffixIcon: IconButton(
//       //                       onPressed: () => getImage(),
//       //                       icon: Icon(Icons.photo),
//       //                     ),
//       //                     hintText: "Write message...",
//       //                     hintStyle: TextStyle(color: Colors.black54),
//       //                     border: InputBorder.none),
//       //               ),
//       //             ),
//       //             SizedBox(
//       //               width: 15,
//       //             ),
//       //             FloatingActionButton(
//       //               onPressed: onSendMessage,
//       //               child: Icon(
//       //                 Icons.send,
//       //                 color: Colors.white,
//       //                 size: 18,
//       //               ),
//       //               backgroundColor: Colors.blue,
//       //               elevation: 0,
//       //             ),
//       //           ],
//       //         ),
//       //       ),
//       //     ),
//       //   ],
//       // ),

//       // body: SingleChildScrollView(
//       //   child: Column(
//       //     children: [
//       //       Container(
//       //         height: size.height / 1.3,
//       //         width: size.width,
//       //         child: StreamBuilder<QuerySnapshot>(
//       //           stream: _firestore
//       //               .collection('groups')
//       // .doc(groupChatId)
//       //               .collection('chats')
//       //               .orderBy('time')
//       //               .snapshots(),
//       //           builder: (context, snapshot) {
//       //             if (snapshot.hasData) {
//       //               return ListView.builder(
//       //                 itemCount: snapshot.data!.docs.length,
//       //                 itemBuilder: (context, index) {
//       //                   Map<String, dynamic> chatMap =
//       //                       snapshot.data!.docs[index].data()
//       //                           as Map<String, dynamic>;
//       //                   return messageTile(size, chatMap, context);
//       //                 },
//       //               );
//       //             } else {
//       //               return Container();
//       //             }
//       //           },
//       //         ),
//       //       ),
//       //       Container(
//       //         height: size.height / 10,
//       //         width: size.width,
//       //         alignment: Alignment.center,
//       //         child: Container(
//       //           height: size.height / 12,
//       //           width: size.width / 1.1,
//       //           child: Row(
//       //             children: [
//       //               Container(
//       //                 height: size.height / 12,
//       //                 width: size.width / 1.3,
//       //                 child: TextField(
//       //                   controller: _message,
//       //                   decoration: InputDecoration(
//       //                     suffixIcon: IconButton(
//       //                       onPressed: () => getImage(),
//       //                       icon: Icon(Icons.photo),
//       //                     ),
//       //                     hintText: "Send Message",
//       //                     border: OutlineInputBorder(
//       //                       borderRadius: BorderRadius.circular(8),
//       //                     ),
//       //                   ),
//       //                 ),
//       //               ),
//       //               IconButton(
//       //                 icon: Icon(Icons.send),
//       //                 onPressed: onSendMessage,
//       //               ),
//       //             ],
//       //           ),
//       //         ),
//       //       ),
//       //     ],
//       //   ),
//       // ),

//       body: Container(
//         height: size.height,
//         width: size.width,
//         child: Column(
//           children: [
//             Expanded(
//               // height: size.height - 140,
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firestore
//                     .collection('groups')
//                     .doc(groupChatId)
//                     .collection('chats')
//                     .orderBy(
//                       'time',
//                       descending: true,
//                     )
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     else {
//                             // snapshot.data!.docs.map((document) {
//                             //   messages[
//                             //     // Message(
//                             //     //   text: document['message'],
//                             //     //   time: document['time'].toDate(),
//                             //     //   sendBy: document['sendBy'],
//                             //     //   type: document['type'],
//                             //     // ),

//                             //     msg = document['message'],
//                             //     send = document['sendBy'],
//                             //     time = document['time'].toDate(),
//                             //     type = document['type'],
//                             // ];

//                             // }).toList();
//                             // for (var element in snapshot.data!.docs) {
//                             //   temp.add(
//                             //     Message(
//                             //       text: element['message'],
//                             //       time: element['time'].toDate(),
//                             //       sendBy: element['sendBy'],
//                             //       type: element['type'],
//                             //     ),
//                             //   );
//                             // }
//                             // print(temp);
//                             // for (int i = 0; i < temp.length; i++) {
//                             //   messages.add(Message(
//                             //       text: temp[i].text,
//                             //       time: temp[i].time,
//                             //       sendBy: temp[i].sendBy,
//                             //       type: temp[i].type));
//                             // }
//                             // print(messages);
//                     // return GroupedListView<Message, DateTime>(
//                     //   padding: const EdgeInsets.all(8),
//                     //   controller: _scrollController,
//                     //   reverse: true,
//                     //   order: GroupedListOrder.DESC,
//                     //   useStickyGroupSeparators: true,
//                     //   floatingHeader: true,
//                     //   shrinkWrap: true,
//                     //   // itemExtent: snapshot.data!.docs.length,
//                     //   elements: messaging,
//                     //   groupBy: (message) => DateTime(
//                     //     message.time.year,
//                     //     message.time.month,
//                     //     message.time.day,
//                     //   ),
//                     //   groupHeaderBuilder: (dynamic message) => SizedBox(
//                     //     height: 40,
//                     //     child: Center(
//                     //       child: Card(
//                     //         color: Theme.of(context).primaryColor,
//                     //         child: Padding(
//                     //           padding: EdgeInsets.all(8),
//                     //           child: Text(
//                     //             DateFormat.yMMMd().format(message.time),
//                     //             style: TextStyle(color: Colors.white),
//                     //           ),
//                     //         ),
//                     //       ),
//                     //     ),
//                     //   ),
//                     //   itemBuilder: (context, Message index) {
//                     //     for (int i = 0; i < messaging.length; i++) {
//                     //       Map<String, dynamic> chatMap = snapshot.data!.docs[i]
//                     //           .data() as Map<String, dynamic>;
//                     //       return messageTile(size, chatMap, context);
//                     //     }
//                     //     return Container();
//                     //   },
//                     // );

//                     return ListView.builder(
//                       reverse: true,
//                       controller: _scrollController,
//                       shrinkWrap: true,
//                       itemCount: snapshot.data!.docs.length + 1,
//                       itemBuilder: (context, index) {
//                         if (index == snapshot.data!.docs.length) {
//                           return Container(
//                             height: 65,
//                           );
//                         }
//                         Map<String, dynamic> chatMap =
//                             snapshot.data!.docs[index].data()
//                                 as Map<String, dynamic>;

//                         return messageTile(size, chatMap, context);
//                       },
//                     );
//                   } else {
//                     return Container();
//                   }
//                 },
//               ),
//             ),

//             // grouping logic

//             // bool isSameDate = true;
//             // final String dateString =
//             //     snapshot.data!.docs[index]['time'];
//             // final DateTime date = DateTime.parse(dateString);
//             // final item = snapshot.data!.docs[index];
//             // if (index == 0) {
//             //   isSameDate = false;
//             // } else {
//             //   final String prevDateString =
//             //       snapshot.data!.docs[index - 1]['time'];
//             //   final DateTime prevDate =
//             //       DateTime.parse(prevDateString);
//             // }
//             // if (index == 0 || !(isSameDate)) {
//             //   return Column(children: [
//             //     Text(date.formatDate()),
//             //     messageTile(size, chatMap, context),
//             //   ]);
//             // } else {
//             //   return messageTile(size, chatMap, context);
//             // }
//             //grouping logic ends

//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 height: 70,
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

//   // Widget messageTile(Size size, Map<String, dynamic> chatMap) {
//   //   return Container(
//   //     width: size.width,
//   //     alignment: chatMap['sendBy'] == currentUserName
//   //         ? Alignment.centerRight
//   //         : Alignment.centerLeft,
//   //     padding: EdgeInsets.symmetric(
//   //       horizontal: size.width / 100,
//   //       vertical: size.height / 400,
//   //     ),
//   //     child: Container(
//   //       padding: EdgeInsets.symmetric(
//   //         vertical: size.height / 50,
//   //         horizontal: size.width / 40,
//   //       ),
//   //       decoration: BoxDecoration(
//   //           borderRadius: BorderRadius.circular(15), color: Colors.blue),
//   //       child: Text(chatMap['message']),
//   //     ),
//   //   );
//   // }

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
//             DateFormat('kk:mm').format(chatMap['time'].toDate()).toString(),
//           );
//           // return Container(
//           //   width: size.width,
//           //   alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
//           //       ? Alignment.centerRight
//           //       : Alignment.centerLeft,
//           //   child: Container(
//           //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//           //     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//           //     decoration: BoxDecoration(
//           //       borderRadius: BorderRadius.circular(15),
//           //       color: messageColor,
//           //     ),
//           //     child: Column(children: [
//           //       Text(
//           //         chatMap['sendBy'],
//           //         style: const TextStyle(
//           //           color: nameDisplayColor,
//           //           fontSize: 14,
//           //           fontWeight: FontWeight.normal,
//           //         ),
//           //       ),
//           //       SizedBox(
//           //         height: size.height / 250,
//           //       ),
//           //       Text(
//           //         // _decryptedText == null ? "" : _decryptedText,
//           //         EncryptionDecryption.decryptAES(chatMap['message']),

//           //         style: const TextStyle(
//           //           color: Colors.white,
//           //           fontSize: 20,
//           //           fontWeight: FontWeight.w500,
//           //         ),
//           //       ),
//           //     ]),
//           //   ),
//           // );
//         } else if (chatMap['type'] == "img") {
//           return ImageBubble(
//             chatMap['message'],
//             chatMap['sendBy'] == _auth.currentUser!.displayName,
//             chatMap['sendBy'],
//             DateFormat('kk:mm').format(chatMap['time'].toDate()).toString(),
//           );
//           // return Container(
//           //   width: size.width,
//           //   alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
//           //       ? Alignment.centerRight
//           //       : Alignment.centerLeft,
//           //   child: Container(
//           //     // padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
//           //     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//           //     decoration: BoxDecoration(
//           //       borderRadius: BorderRadius.circular(20),
//           //       color: messageColor,
//           //     ),
//           //     child: Column(
//           //       children: [
//           //         Text(
//           //           chatMap['sendBy'],
//           //           style: const TextStyle(
//           //             color: nameDisplayColor,
//           //             fontSize: 14,
//           //             fontWeight: FontWeight.normal,
//           //           ),
//           //         ),
//           //         SizedBox(
//           //           height: size.height / 250,
//           //         ),
//           //         InkWell(
//           //           onTap: () => Navigator.of(context).push(
//           //             MaterialPageRoute(
//           //               builder: (_) => ShowImage(
//           //                 imageurl: chatMap['message'],
//           //               ),
//           //             ),
//           //           ),
//           //           child: Container(
//           //             height: size.height / 3,
//           //             width: size.width / 2,
//           //             decoration: BoxDecoration(border: Border.all()),
//           //             alignment:
//           //                 chatMap['message'] != "" ? null : Alignment.center,
//           //             child: chatMap['message'] != ""
//           //                 ? Image.network(
//           //                     chatMap['message'],
//           //                     fit: BoxFit.cover,
//           //                   )
//           //                 : CircularProgressIndicator(),
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // );
//         } else {
//           return SizedBox();
//         }
//       },
//     );
//   }
// }

// class ShowImage extends StatelessWidget {
//   final String imageurl;
//   const ShowImage({required this.imageurl, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Container(
//         height: size.height,
//         width: size.width,
//         color: appBarColor,
//         child: Image.network(imageurl),
//       ),
//     );
//   }
// }
