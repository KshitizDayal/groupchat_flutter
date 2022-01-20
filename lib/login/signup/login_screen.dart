import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/home_screen.dart';
import 'package:groupchat/login/signup/signup.dart';
import 'package:groupchat/login/signup/welcome_screen.dart';
import 'package:groupchat/method_login_signup.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("loginScreen"),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed(WelcomeScreen.routeName);
          },
        ),
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.width / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Container(
                    alignment: Alignment.center,
                    height: size.height * 0.3,
                    width: double.infinity,
                    child: const Text(
                      'LOGIN SCREEN',
                      style: TextStyle(
                        fontSize: 32,
                      ),
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: size.width * 0.8,
                    decoration: BoxDecoration(
                      color: messageColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.person,
                          color: buttonColor,
                        ),
                        hintText: "your email",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    width: size.width * 0.8,
                    decoration: BoxDecoration(
                      color: messageColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _password,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.lock,
                          color: buttonColor,
                        ),
                        hintText: " password",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
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
                          if (_email.text.isNotEmpty &&
                              _password.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });
                            logIn(_email.text, _password.text).then(
                              (user) {
                                if (user != null) {
                                  setState(() {
                                    isLoading = false;
                                  });

                                  print("login successful");
                                  Navigator.of(context)
                                      .pushNamed(HomeScreen.routeName);
                                } else {
                                  print("login failed");
                                }
                              },
                            );
                          } else {
                            print("please enter the fields");
                          }
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
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have account?",
                        style: TextStyle(color: buttonColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(SignUpScreen.routeName);
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: buttonColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
