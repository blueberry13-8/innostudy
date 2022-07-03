import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work/permission_system/permission_master.dart';
import 'files_page.dart';
import 'folder.dart';
import 'group.dart';
import 'firebase_functions.dart';
import 'permission_system/permission_dialog.dart';
import 'permission_system/permissions_entity.dart';
import 'permission_system/permissions_functions.dart';
import 'permission_system/permissions_page.dart';
import 'pessimistic_toast.dart';

///Widget that represent folders page
class FoldersPage extends StatefulWidget {
  const FoldersPage(
      {required this.openedGroup, required this.parentPermissions, Key? key})
      : super(key: key);

  final Group openedGroup;
  final PermissionEntity parentPermissions;

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  late List<Folder> _folderList;

  final TextEditingController _textController = TextEditingController();

  String _lastFolderName = '';

  ///Adds new folder to widget
  void _addFolder(Folder folder) {
    setState(() {
      _folderList.add(folder);
      //widget.openedGroup.folders.add(folder);
      //deleteGroup(group);
      //addGroup(group);
      addFolderInGroup(widget.openedGroup, folder);
    });
  }

  ///Removes folder from widget
  void _removeFolder(Folder folder) {
    setState(() {
      _folderList.remove(folder);
      //widget.openedGroup.folders.remove(folder);
      deleteFolderFromGroup(widget.openedGroup, folder);
    });
  }

  void openFolder(int index, PermissionEntity permissionEntity) {
    if (kDebugMode) {
      print('${_folderList[index].folderName} is opened');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilesPage(
          openedFolder: _folderList[index],
          openedGroup: widget.openedGroup,
          parentPermissionsFolder: permissionEntity,
          parentPermissionsGroup: widget.parentPermissions,
        ),
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
            _removeFolder(widget.openedGroup.folders[index]);
            Navigator.of(context).pop();
            setState(() {});
          },
        );
        var alertDialog = AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Deleting of folder ${widget.openedGroup.folders[index].folderName}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Text(
            'Are you sure about deleting this folder? It will be deleted without ability to restore.',
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

    //_folderList = super.widget.openedGroup.folders;

    _textController.text = _lastFolderName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.openedGroup.groupName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('groups_normalnie')
              .doc(widget.openedGroup.groupName)
              .collection('folders')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.hasData) {
              _folderList = querySnapshotToFoldersList(
                  snapshot.data!, widget.openedGroup);
              widget.openedGroup.folders = _folderList;
              List<PermissionEntity> permissionEntitites =
                  querySnapshotToListOfPermissionEntities(snapshot.data!);
              return ListView.builder(
                itemCount: _folderList.length + 1,
                padding: const EdgeInsets.all(5),
                itemBuilder: (context, index) {
                  if (index == _folderList.length) {
                    return const SizedBox(
                      height: 80,
                    );
                  }
                  _folderList[index].parentGroup = widget.openedGroup;
                  RightsEntity rights = checkRightsForFolder(_folderList[index],
                      permissionEntitites[index], widget.parentPermissions);
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        _folderList[index].folderName,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      leading: Icon(
                        Icons.folder,
                        color: Theme.of(context).primaryColor,
                      ),
                      trailing: rights.openFoldersSettings
                          ? PopupMenuButton<int>(
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
                                          'Delete folder',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      _showAlertDialog(context, index);
                                    },
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: GestureDetector(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.settings,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Settings',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PermissionsPage(
                                            permissionEntity:
                                                permissionEntitites[index],
                                            permissionableObject:
                                                PermissionableObject.fromFolder(
                                                    _folderList[index]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              offset: const Offset(0, 50),
                              color: Theme.of(context).backgroundColor,
                              elevation: 3,
                            )
                          : IconButton(
                              icon: Icon(
                                rights.addFiles
                                    ? Icons.edit
                                    : Icons.remove_red_eye_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                if (!rights.addFiles) {
                                  if (permissionEntitites[index]
                                      .password
                                      .isEmpty) {
                                    pessimisticToast(
                                        "Only creator can invite you to manage this folder.",
                                        1);
                                    return;
                                  }
                                  showPermissionDialog(
                                      permissionEntitites[index],
                                      PermissionableObject.fromFolder(
                                          _folderList[index]),
                                      context);
                                } else {
                                  openFolder(index, permissionEntitites[index]);
                                }
                              },
                            ),
                      onTap: () {
                        if (rights.seeFiles) {
                          openFolder(index, permissionEntitites[index]);
                        } else {
                          pessimisticToast(
                              "You don't have rights for this action.", 1);
                        }
                      },
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "folders page",
        onPressed: () {
          if (checkRightsForGroup(widget.openedGroup, widget.parentPermissions)
              .addFolders) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _textController,
                        autofocus: true,
                        onChanged: (value) {
                          _lastFolderName = value;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text != '') {
                            _addFolder(Folder(
                                folderName: _textController.text,
                                files: [],
                                creator:
                                    FirebaseAuth.instance.currentUser!.email!));
                            Navigator.pop(context);
                            _textController.text = '';
                            _lastFolderName = '';
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            pessimisticToast("You don't have rights for this action.", 1);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
