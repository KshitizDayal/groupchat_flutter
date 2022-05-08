import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/groups/new_group.dart';
import 'package:groupchat/home_screen.dart';
import 'package:uuid/uuid.dart';

class CreateGroupName extends StatefulWidget {
  final List<Map<String, dynamic>> memberList;

  const CreateGroupName({required this.memberList, Key? key}) : super(key: key);
  static const routeName = '/create-group-name';

  @override
  State<CreateGroupName> createState() => _CreateGroupNameState();
}

class _CreateGroupNameState extends State<CreateGroupName> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _groupName = TextEditingController();
  bool isLoading = false;

  void createGroup() async {
    setState(() {
      isLoading = true;
    });
    String groupId = const Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "uid": groupId,
      "name": _groupName.text,
      "members": widget.memberList,
      "lastMessage": "",
      "lastMessageSendTs": "",
      "lastMessageSendBy": "",
    });

    for (int i = 0; i < widget.memberList.length; i++) {
      String uid = widget.memberList[i]['uid'];

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupName.text,
        "id": groupId,
        "lastMessage": "",
        "lastMessageSendTs": "",
        "lastMessageSendBy": "",
      });

      // String memberid = groupId;

      // final Stream<QuerySnapshot> members =
      //     FirebaseFirestore.instance.collection('groups').snapshots();
    }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message": "${_auth.currentUser!.displayName} Created This Group.",
      "type": "notify",
      "time": DateTime.now(),
      "sendBy": "",
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create name for Group'),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(HomeScreen.routeName);
            },
            icon: Icon(Icons.forward_rounded),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed(NewGroup.routeName);
          },
        ),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 10,
                ),
                Container(
                  height: size.height / 15,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 15,
                    width: size.width / 1.2,
                    child: TextField(
                      controller: _groupName,
                      decoration: InputDecoration(
                        hintText: "Enter the group name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        child: Icon(Icons.check_circle),
        backgroundColor: appBarColor,
      ),
    );
  }
}
