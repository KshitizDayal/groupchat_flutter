import 'package:flutter/cupertino.dart';

class Message {
  // final String key;
  // final String msgid;
  final String text;
  final DateTime time;
  final String sendBy;
  final String type;

  const Message({
    // required this.key,
    // required this.msgid,
    required this.text,
    required this.time,
    required this.sendBy,
    required this.type,
  });
}
