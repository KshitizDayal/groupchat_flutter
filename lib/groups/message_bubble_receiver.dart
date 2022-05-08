import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';

class MessageBubbleReceiver extends StatelessWidget {
  MessageBubbleReceiver(
    this.message,
    // this.isMe,
    this.username,
    this.day,
    this.date,
    this.time,
    // this.userImage,
  );

  String message;
  // bool isMe;
  // final Key? key;
  final String username;
  final String time;
  final String day;
  final String date;

  // final String userImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: greyclr,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: nameDisplayColor,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(time),
              Text(day),
              Text(date),
            ],
          ),
        ],
      ),
    );
  }
}
