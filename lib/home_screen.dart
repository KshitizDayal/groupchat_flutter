import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/groups/group_chat_screen.dart';
import 'package:groupchat/groups/new_group.dart';
import 'package:groupchat/login/signup/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final Stream<QuerySnapshot> users =
  //     FirebaseFirestore.instance.collection('users').snapshots();

  // final Stream<QuerySnapshot> groups =
  //     FirebaseFirestore.instance.collection('groups').snapshots();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('HomeScreen'),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(WelcomeScreen.routeName);
            },
            icon: Icon(Icons.person),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    // margin: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
                    alignment: Alignment.center,
                    height: size.height * 0.1,
                    width: double.infinity,
                    child: Text(
                      "Group List",
                      style: TextStyle(fontSize: 26),
                    ),
                  ),
                  Container(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: groupList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GroupChatScreen(
                                  groupName: groupList[index]['name'],
                                  groupChatId: groupList[index]['id'],
                                ),
                              ),
                            ),
                            leading: Icon(Icons.group),
                            title: Text(groupList[index]['name']),
                          );
                        }),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(NewGroup.routeName);
        },
        child: Icon(Icons.add),
        backgroundColor: appBarColor,
      ),
    );
  }
}
