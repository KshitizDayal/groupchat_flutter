import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/login/signup/login_screen.dart';
import 'package:groupchat/login/signup/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  static const routeName = '/welcome-screen';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: size.height * 0.5,
              width: double.infinity,
              child: const Text(
                'Group Chat App',
                style: TextStyle(
                  fontSize: 36,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: size.height * 0.1,
                width: size.width * 0.8,
                // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                color: buttonColor,
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: size.height * 0.1,
                width: size.width * 0.8,
                color: buttonColor,
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(SignUpScreen.routeName);
                  },
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
