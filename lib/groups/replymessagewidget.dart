import 'package:flutter/material.dart';

class ReplyMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback onCancelreply;
  const ReplyMessageWidget({
    required this.message,
    required this.onCancelreply,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
