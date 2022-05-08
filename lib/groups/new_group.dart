import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/appcolor.dart';
import 'package:groupchat/groups/create_group_name.dart';
import 'package:groupchat/home_screen.dart';

class NewGroup extends StatefulWidget {
  static const routeName = '/new-group';

  NewGroup({Key? key}) : super(key: key);

  @override
  State<NewGroup> createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> memberList = [];
  bool isLoading = false;

  Map<String, dynamic>? userMap;

  List userList = [];

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        memberList.add({
          "name": map['name'],
          "email": map['email'],
          "uid": map['uid'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection("users")
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < memberList.length; i++) {
      if (memberList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        memberList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (memberList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        memberList.removeAt(index);
      });
    }
  }

  final Stream<QuerySnapshot> users =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Make a new Group'),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CreateGroupName.routeName);
            },
            icon: Icon(Icons.forward_rounded),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed(HomeScreen.routeName);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: memberList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveMembers(index),
                    leading: Icon(Icons.account_circle),
                    title: Text(memberList[index]['name']),
                    subtitle: Text(memberList[index]['email']),
                    trailing: Icon(Icons.close),
                  );
                },
              ),
            ),
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
                    onTap: onResultTap,
                    leading: Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: Icon(Icons.add),
                  )
                : SizedBox(),
          ],
        ),
      ),
      //                                      code for showing all the users of the app
      // body: SingleChildScrollView(
      //   child: StreamBuilder(
      //       stream: users,
      //       builder: (
      //         BuildContext context,
      //         AsyncSnapshot<QuerySnapshot> snapshot,
      //       ) {
      //         if (snapshot.hasError) {
      //           return Text('something is wrong');
      //         }
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return CircularProgressIndicator();
      //         }

      //         final data = snapshot.requireData;

      //         return Expanded(
      //           child: ListView.builder(
      //               scrollDirection: Axis.vertical,
      //               shrinkWrap: true,
      //               itemCount: data.size,
      //               itemBuilder: ((context, index) {
      //                 return ListTile(
      //                   leading: Icon(Icons.account_box),
      //                   title: Text(data.docs[index]['name']),
      //                   subtitle: Text(data.docs[index]['email']),
      //                   trailing: Icon(Icons.add),
      //                 );
      //               })),
      //         );
      //       }),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateGroupName(
                memberList: memberList,
              ),
            ),
          );
        },
        child: Icon(Icons.forward_rounded),
        backgroundColor: appBarColor,
      ),
    );
  }
}
