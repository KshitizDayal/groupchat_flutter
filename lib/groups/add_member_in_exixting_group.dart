import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/home_screen.dart';

class AddMemberInExistingGroup extends StatefulWidget {
  final String groupId, groupName;
  final List memberList;

  AddMemberInExistingGroup(
      {required this.memberList,
      required this.groupName,
      required this.groupId,
      Key? key})
      : super(key: key);

  @override
  _AddMemberInExistingGroupState createState() =>
      _AddMemberInExistingGroupState();
}

class _AddMemberInExistingGroupState extends State<AddMemberInExistingGroup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  List memberList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    memberList = widget.memberList;
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection("users")
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onAddMembers() async {
    memberList.add({
      "name": userMap!['name'],
      "email": userMap!['email'],
      "uid": userMap!['uid'],
      "isAdmin": false,
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": memberList,
    });

    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('groups')
        .doc(widget.groupId)
        .set({
      "name": widget.groupName,
      "id": widget.groupId,
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);

    // await _firestore
    //     .collection('groups')
    //     .doc(widget.groupId)
    //     .collection('chats')
    //     .add({
    //   "message":
    //       "${_auth.currentUser!.displayName} added ${newAddedMember['name']}.",
    //   "type": "notify",
    //   "time": FieldValue.serverTimestamp(),
    // });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Members'),
        backgroundColor: appBarColor,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(CreateGroupName.routeName);
        //     },
        //     icon: Icon(Icons.forward_rounded),
        //   ),
        // ],
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.of(context).pushNamed(HomeScreen.routeName);
        //   },
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: size.height / 20),
            Container(
              height: size.height / 15,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 15,
                width: size.width / 1.2,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Search",
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
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.width / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: onSearch,
                    child: Text("Search"),
                  ),
            userMap != null
                ? ListTile(
                    onTap: onAddMembers,
                    leading: Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: Icon(Icons.add),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
