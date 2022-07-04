import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work/permission_system/permission_dialog.dart';
import 'package:work/permission_system/permission_master.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/permission_system/permissions_page.dart';
import 'package:work/utils/pessimistic_toast.dart';
import 'package:work/widgets/action_progress.dart';
import 'package:work/widgets/explorer_list_widget.dart';
import '../widgets/vladislav_alert.dart';
import 'folders_page.dart';
import '../core/group.dart';
import '../firebase/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../permission_system/permission_object.dart';

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
  Future<void> _addGroup(Group group) async {
    await addGroup(group);
  }

  ///Removes group from widget
  Future<void> _removeGroup(Group group) async {
    await deleteGroup(group);
    setState(() {
      _groupList.remove(group);
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
          path: const [],
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
              List<PermissionableObject> listObjects = [];
              for (int i = 0; i < _groupList.length; i++) {
                _groupList[i].permissions = permissionEntitites[i];
                listObjects.add(PermissionableObject.fromGroup(_groupList[i]));
              }
              return ExplorerList(
                  listObjects: listObjects,
                  objectIcon: Icons.group,
                  openSettingsCondition: (index) {
                    RightsEntity rights =
                        checkRightsForGroup(_groupList[index]);
                    return rights.openGroupSettings;
                  },
                  readactorCondition: (index) {
                    RightsEntity rights =
                        checkRightsForGroup(_groupList[index]);
                    return rights.addFolders;
                  },
                  onOpen: (index) {
                    RightsEntity rights =
                        checkRightsForGroup(_groupList[index]);
                    if (rights.seeFolders) {
                      openGroup(index, permissionEntitites[index]);
                    } else {
                      pessimisticToast(
                          "You don't have rights for this action.", 1);
                    }
                  },
                  onDelete: (index) {
                    RightsEntity rights =
                        checkRightsForGroup(_groupList[index]);
                    if (rights.openGroupSettings) {
                      showVladanchik(context, _groupList[index].groupName, () {
                        showDialog(
                          barrierDismissible: false,
                          context: this.context,
                          builder: (context) {
                            return ActionProgress(parentContext: this.context);
                          },
                        );
                        _removeGroup(_groupList[index]).then((value) {
                          Navigator.of(this.context).pop();
                        });
                      });
                    } else {
                      pessimisticToast(
                          "You don't have rights for this action.", 1);
                    }
                  },
                  onOpenSettings: (index) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PermissionsPage(
                          path: const [],
                          permissionEntity: permissionEntitites[index],
                          permissionableObject:
                              PermissionableObject.fromGroup(_groupList[index]),
                        ),
                      ),
                    );
                  },
                  onEyePressed: (index) {
                    RightsEntity rights =
                        checkRightsForGroup(_groupList[index]);
                    if (!rights.addFolders) {
                      if (permissionEntitites[index].password.isEmpty) {
                        pessimisticToast(
                            "Only creator can invite you to manage this group.",
                            1);
                      } else {
                        showPermissionDialog(
                            permissionEntitites[index],
                            PermissionableObject.fromGroup(_groupList[index]),
                            [],
                            context);
                      }
                    }
                  });
            } else {
              return ActionProgress(parentContext: this.context);
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
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) =>
                                    //           const ActionProgress()),
                                    // );
                                    _addGroup(Group(
                                            groupName: _textController.text,
                                            folders: [],
                                            creator: FirebaseAuth
                                                .instance.currentUser!.email!))
                                        .then((value) {
                                      //Navigator.pop(context);
                                    });
                                    _textController.text = '';
                                    _lastGroupName = '';
                                    Navigator.pop(context);
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
