import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/home_screen.dart';
import 'package:groupchat/login/signup/welcome_screen.dart';

class Authenticate extends StatelessWidget {
  Authenticate({Key? key}) : super(key: key);
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return HomeScreen();
    } else {
      return WelcomeScreen();
    }
  }
}
