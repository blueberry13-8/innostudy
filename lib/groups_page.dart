import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work/permission_system/permission_dialog.dart';
import 'package:work/permission_system/permission_master.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/permission_system/permissions_page.dart';
import 'package:work/pessimistic_toast.dart';
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

  void openGroup(int index, PermissionEntity inheritedPermissions) {
    if (kDebugMode) {
      print("${_groupList[index].groupName} is opened");
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoldersPage(
          openedGroup: _groupList[index],
          parentPermissions: inheritedPermissions,
        ),
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
              return const Text("Error");
            } else if (snapshot.hasData) {
              _groupList = querySnapshotToGroupList(snapshot.data!);
              List<PermissionEntity> permissionEntitites =
                  querySnapshotToListOfPermissionEntities(snapshot.data!);
              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _groupList.length,
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                itemBuilder: (BuildContext context, int index) {
                  RightsEntity rights = checkRightsForGroup(
                      _groupList[index], permissionEntitites[index]);
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
                            trailing: IconButton(
                              icon: Icon(
                                rights.openGroupSettings
                                    ? Icons.remove_circle_outline
                                    : (rights.addFolders
                                        ? Icons.lock_open
                                        : Icons.lock_outline),
                                color: Theme.of(context).primaryColor,
                                //color: Colors.black87,
                              ),
                              onPressed: () {
                                if (rights.openGroupSettings) {
                                  _removeGroup(_groupList[index]);
                                } else if (!rights.addFolders) {
                                  if (permissionEntitites[index]
                                      .password
                                      .isEmpty) {
                                    pessimisticToast(
                                        "Only creator can invite you to this group.",
                                        1);
                                    return;
                                  }
                                  showPermissionDialog(
                                      permissionEntitites[index],
                                      PermissionableObject.fromGroup(
                                          _groupList[index]),
                                      context);
                                }
                              },
                            ),
                            onTap: () {
                              if (rights.seeFolders) {
                                openGroup(index, permissionEntitites[index]);
                              } else {
                                pessimisticToast(
                                    "You don't have rights for this action.",
                                    1);
                              }
                            },
                            onLongPress: () {
                              if (!rights.openGroupSettings) {
                                pessimisticToast(
                                    "You don't have rights for this action.",
                                    1);
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PermissionsPage(
                                    permissionEntity:
                                        permissionEntitites[index],
                                    permissionableObject:
                                        PermissionableObject.fromGroup(
                                            _groupList[index]),
                                  ),
                                ),
                              );
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
                heroTag: "btn1",
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
