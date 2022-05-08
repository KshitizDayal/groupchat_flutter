import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';

class ImageBubble extends StatelessWidget {
  ImageBubble(
    this.message,
    this.isMe,
    this.username,
    this.time,
    // this.userImage,
  );

  String message;
  bool isMe;
  // final Key? key;
  final String username;
  final String time;

  // final String userImage;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? textclr : greyclr,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
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
                  Row(
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
                        time,
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShowImage(
                          imageurl: message,
                        ),
                      ),
                    ),
                    child: Container(
                      height: size.height / 3,
                      width: size.width / 2,
                      // decoration: BoxDecoration(border: Border.all()),
                      alignment: message != "" ? null : Alignment.center,
                      child: message != ""
                          ? Image.network(
                              message,
                              fit: BoxFit.cover,
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: -3,
          left: isMe ? null : 155,
          right: isMe ? 155 : null,
          child: Icon(Icons.account_box),
        ),
      ],
      // overflow: Overflow.visible,
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
