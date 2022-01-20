import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:groupchat/firebase/authenticate.dart';

import 'package:groupchat/groups/group_chat_screen.dart';
import 'package:groupchat/groups/create_group_name.dart';
import 'package:groupchat/home_screen.dart';
import 'package:groupchat/groups/new_group.dart';
import 'package:groupchat/login/signup/login_screen.dart';
import 'package:groupchat/login/signup/signup.dart';
import 'package:groupchat/login/signup/welcome_screen.dart';

import 'package:groupchat/appcolor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GroupChat',
      theme: ThemeData(
        primaryColor: appBarColor,
        scaffoldBackgroundColor: const Color(0xFFDDCBF5),
      ),
      home: Authenticate(),
      routes: {
        WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
        LoginScreen.routeName: (ctx) => LoginScreen(),
        SignUpScreen.routeName: (ctx) => SignUpScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        NewGroup.routeName: (ctx) => NewGroup(),
        CreateGroupName.routeName: (ctx) => CreateGroupName(
              memberList: [],
            ),
        // GroupChatScreen.routeName: (ctx) => GroupChatScreen(),
      },
    );
  }
}
