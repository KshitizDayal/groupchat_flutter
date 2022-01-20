import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/groups/add_member_in_exixting_group.dart';

import '../home_screen.dart';

class GroupInfo extends StatefulWidget {
  final String groupName, groupId;
  GroupInfo({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List memberList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGroupMembers();
  }

  void getGroupMembers() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        memberList = value['members'];
        isLoading = false;
      });
    });
  }

  bool checkAdmin() {
    bool isAdmin = false;

    memberList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });

    return isAdmin;
  }

  void showRemoveDialog(int index) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: ListTile(
              onTap: () => removeUser(index),
              title: Text("remove this member"),
            ),
          );
        });
  }

  void removeUser(int index) async {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != memberList[index]['uid']) {
        setState(() {
          isLoading = true;
        });
        String uid = memberList[index]['uid'];

        memberList.removeAt(index);

        await _firestore
            .collection('groups')
            .doc(widget.groupId)
            .update({"members": memberList});

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc(widget.groupId)
            .delete();
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print("only admin can remove the user");
    }
  }

  void onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });
      String uid = _auth.currentUser!.uid;

      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['uid'] == uid) {
          memberList.removeAt(i);
        }
      }
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .update({"members": memberList});

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);

      setState(() {
        isLoading = false;
      });
    } else {
      print("can't left group");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          Container(
                            height: size.height / 8,
                            width: size.width / 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: size.width / 10,
                            ),
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.groupName,
                                style: TextStyle(
                                  fontSize: size.width / 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${memberList.length} members",
                        style: TextStyle(
                          fontSize: size.width / 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Flexible(
                      child: ListView.builder(
                          itemCount: memberList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () => showRemoveDialog(index),
                              leading: Icon(Icons.account_circle),
                              title: Text(
                                memberList[index]['name'],
                                style: TextStyle(
                                    fontSize: size.width / 22,
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                memberList[index]['email'],
                              ),
                              trailing: Text(
                                  memberList[index]['isAdmin'] ? "Admin" : ""),
                            );
                          }),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddMemberInExistingGroup(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                            memberList: memberList,
                          ),
                        ),
                      ),
                      leading: Icon(
                        Icons.add,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Add members",
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: onLeaveGroup,
                      leading: Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Leave Group",
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
