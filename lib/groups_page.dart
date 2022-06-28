import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'folders_page.dart';
import 'group.dart';
import 'firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'consumer.dart';
import 'package:fluttertoast/fluttertoast.dart';

///Widget that represent groups page
class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPage();
}

class _GroupsPage extends State<GroupsPage> {
  //List of existing groups
  late List<Group> _groupList;

  String _lastGroupName = '';

  var topAppBar = AppBar(
    elevation: 0.1,
    // backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
    title: const Text('Group page'),
    centerTitle: true,
    /// Here we can add button to change mode from light to dark and vice versa
    // actions: <Widget>[
    //   IconButton(
    //     icon: const Icon(Icons.light_mode),
    //     onPressed: () {},
    //   )
    // ],
  );

  ///Controller to get text from user for new group name
  final TextEditingController _textController = TextEditingController();

  ///Adds new group to widget
  void _addGroup(Group group) {
    setState(() {
      _groupList.add(group);
      addGroup(group);
    });
  }

  ///Removes group from widget
  void _removeGroup(Group group) {
    setState(() {
      _groupList.remove(group);
      deleteGroup(group);
    });
  }

  void openGroup(int index) {
    if (kDebugMode) {
      print("${_groupList[index].groupName} is opened");
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoldersPage(openedGroup: _groupList[index]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _textController.text = _lastGroupName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topAppBar,
        //Dynamically build widget
        body: SafeArea(
            child: StreamBuilder(
          stream: groupsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Idiot");
            } else if (snapshot.hasData) {
              _groupList = querySnapshotToGroupList(snapshot.data!);
              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _groupList.length,
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.yellow[100],
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        _groupList[index].groupName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFFBCAAA4),
                          //border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(7), //<--- border radius here
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 5),
                          child: Text(
                            _groupList[index].creator,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      leading: const Icon(
                        Icons.group,
                        color: Colors.black87,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.black87,
                        ),
                        onPressed: () async {
                          if (_groupList[index].creator ==
                              Consumer.data.email) {
                            _removeGroup(_groupList[index]);
                          } else {
                            Fluttertoast.showToast(
                                msg: "You don't have rights for this action",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        },
                      ),
                      onTap: () {
                        openGroup(index);
                      },
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 30,
              bottom: 10,
              child: FloatingActionButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Icon(Icons.exit_to_app),
              ),
            ),
            // const SizedBox(
            //   width: 10,
            // ),
            Positioned(
              right: 30,
              bottom: 10,
              child: FloatingActionButton(
                onPressed: () {
                  //Bottom menu for adding new groups
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 15,
                              left: 15,
                              right: 15,
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _textController,
                                autofocus: true,
                                onChanged: (value) {
                                  _lastGroupName = value;
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_textController.text != "") {
                                    _addGroup(Group(
                                        groupName: _textController.text,
                                        folders: [],
                                        creator: FirebaseAuth
                                            .instance.currentUser!.email!));
                                    Navigator.pop(context);
                                    _textController.text = '';
                                    _lastGroupName = '';
                                  }
                                },
                                child: const Text("Add"),
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ));
  }
}
