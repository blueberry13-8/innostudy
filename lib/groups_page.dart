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

    /// Here we can add button to change mode from light to dark and vice versa or a search button
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

  Future<void> _showAlertDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        var cancelButton = TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            if (kDebugMode) {
              print('Canceled');
            }
            Navigator.of(context).pop();
          },
        );
        var confirmButton = TextButton(
          child: Text(
            'Confirm',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () async {
            if (kDebugMode) {
              print('Confirmed');
            }
            _removeGroup(_groupList[index]);
            Navigator.of(context).pop();
            setState(() {});
          },
        );
        var alertDialog = AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Deleting of group ${_groupList[index].groupName}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Text(
            'Are you sure about deleting this group? It will be deleted without ability to restore.',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          actions: [
            cancelButton,
            confirmButton,
          ],
        );
        return alertDialog;
      },
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
              return const Text("Error");
            } else if (snapshot.hasData) {
              _groupList = querySnapshotToGroupList(snapshot.data!);
              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _groupList.length + 1,
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                itemBuilder: (BuildContext context, int index) {
                  return index < _groupList.length
                      ? Card(
                          //color: Colors.yellow[100],
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              _groupList[index].groupName,
                              style: Theme.of(context).textTheme.bodyText1,
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
                            leading: Icon(
                              Icons.group,
                              color: Theme.of(context).primaryColor,
                              //color: Colors.black87,
                            ),
                            trailing: PopupMenuButton<int>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Theme.of(context).primaryColor,
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: GestureDetector(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_forever,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Delete group',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      var email = Consumer.data.email;
                                      if (_groupList[index].creator == email) {
                                        Navigator.of(context).pop();
                                        _showAlertDialog(context, index);
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "You don't have rights for this action",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 3,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    },
                                  ),
                                ),

                                /// Here we can add more menu items for additional actions, for ex. field Info about group/folder/file
                                // PopupMenuItem(
                                //   value: 2,
                                //   child: Row(
                                //     children: const [
                                //       Icon(Icons.info_outline),
                                //       SizedBox(
                                //         width: 10,
                                //       ),
                                //       Text('Info'),
                                //     ],
                                //   ),
                                // ),
                              ],
                              offset: const Offset(0, 50),
                              color: Theme.of(context).backgroundColor,
                              elevation: 3,
                            ),
                            onTap: () {
                              openGroup(index);
                            },
                          ),
                        )
                      : const SizedBox(
                          height: 80,
                        );
                },
              );
            } else {
              return CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              );
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
                heroTag: "groups page",
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
