import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
    this.message,
    this.isMe,
    this.username,
    this.day,
    this.date,
    this.time,
    // this.userImage,
  );

  String message;
  bool isMe;
  // final Key? key;
  final String username;
  final String time;
  final String day;
  final String date;

  // final String userImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: isMe ? textclr : greyclr,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft:
                        !isMe ? Radius.circular(0) : Radius.circular(12),
                    bottomRight:
                        isMe ? Radius.circular(0) : Radius.circular(12),
                  ),
                ),
                width: 180,
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 2,
                  left: 2,
                  right: 2,
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 7,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: nameDisplayColor,
                          ),
                          textAlign: isMe ? TextAlign.end : TextAlign.start,
                        ),
                        Text(
                          message,
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          day,
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.black,
                          ),
                        ),
                        // Text(
                        //   date,
                        //   style: TextStyle(
                        //     // ignore: deprecated_member_use
                        //     color: Colors.black,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Positioned(
        //   top: -3,
        //   left: isMe ? null : 155,
        //   right: isMe ? 155 : null,
        //   child: Icon(Icons.account_box),
        // ),
      ],
      // overflow: Overflow.visible,
    );
  }
}
