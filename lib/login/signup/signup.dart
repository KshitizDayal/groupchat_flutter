import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/home_screen.dart';
import 'package:groupchat/login/signup/login_screen.dart';
import 'package:groupchat/login/signup/welcome_screen.dart';
import 'package:groupchat/method_login_signup.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  static const routeName = '/signup-screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("SignUpScreen"),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            logOut(context);
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
                    height: size.height * 0.2,
                    width: double.infinity,
                    child: const Text(
                      'SIGN UP SCREEN',
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
                      controller: _name,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.person,
                          color: buttonColor,
                        ),
                        hintText: "Name",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
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
                        hintText: "Email",
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
                        hintText: " Password",
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
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(30),
                      // ),

                      color: buttonColor,
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          if (_name.text.isNotEmpty &&
                              _email.text.isNotEmpty &&
                              _password.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });
                            createAccount(
                                    _name.text, _email.text, _password.text)
                                .then((user) {
                              if (user != null) {
                                setState(() {
                                  isLoading = false;
                                });

                                print("account creation successful successful");
                                Navigator.of(context)
                                    .pushNamed(HomeScreen.routeName);
                              } else {
                                print("account creation successful failed");
                              }
                            });
                          } else {
                            print("please enter the fields");
                          }
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
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have account?",
                        style: TextStyle(color: buttonColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(LoginScreen.routeName);
                        },
                        child: Text(
                          "Login",
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
