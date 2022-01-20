import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:groupchat/login/signup/welcome_screen.dart';

Future<User?> createAccount(String name, String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    User user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user as User;

    if (user != null) {
      print("Account creation successful");

      // user.updateProfile(displayName: name);
      user.updateDisplayName(name);

      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "Unavilable",
        "uid": _auth.currentUser!.uid,
      });

      return user;
    } else {
      print("Account creation failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    User user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user as User;

    if (user != null) {
      print("Login successful");
      return user;
    } else {
      print("Login failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future logOut(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    await _auth.signOut().then((value) {
      Navigator.of(context).pushNamed(WelcomeScreen.routeName);
    });
  } catch (e) {
    print("error");
  }
}
