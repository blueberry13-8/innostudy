import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'files_page.dart';
import 'folder.dart';
import 'group.dart';
import 'firebase_functions.dart';
import 'permission_system/permissions_entity.dart';
import 'permission_system/permissions_functions.dart';
import 'permission_system/permissions_page.dart';
import 'pessimistic_toast.dart';

///Widget that represent folders page
class FoldersPage extends StatefulWidget {
  const FoldersPage({required this.openedGroup, Key? key}) : super(key: key);

  final Group openedGroup;

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  //late List<Folder> _folderList;

  final TextEditingController _textController = TextEditingController();

  String _lastFolderName = '';

  ///Adds new folder to widget
  void _addFolder(Folder folder) {
    setState(() {
      //_folderList.add(folder);
      widget.openedGroup.folders.add(folder);
      //deleteGroup(group);
      //addGroup(group);
      addFolderInGroup(widget.openedGroup, folder);
    });
  }

  ///Removes folder from widget
  void _deleteFolder(Folder folder) {
    setState(() {
      widget.openedGroup.folders.remove(folder);
      deleteFolderFromGroup(widget.openedGroup, folder);
    });
  }

  void openFolder(int index) {
    if (kDebugMode) {
      print('${widget.openedGroup.folders[index].folderName} is opened');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilesPage(
          openedFolder: widget.openedGroup.folders[index],
          openedGroup: widget.openedGroup,
        ),
      ),
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
              widget.openedGroup.folders = querySnapshotToFoldersList(
                  snapshot.data!, widget.openedGroup);
              return ListView.builder(
                itemCount: widget.openedGroup.folders.length,
                padding: const EdgeInsets.all(5),
                itemBuilder: (context, index) {
                  return Card(
                    //color: Colors.yellow[100],
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                        title: Text(
                          widget.openedGroup.folders[index].folderName,
                          style: Theme.of(context).textTheme.bodyText1,
                          //style: const TextStyle(fontSize: 20),
                        ),
                        leading: Icon(
                          Icons.folder,
                          color: Theme.of(context).primaryColor,
                          //color: Colors.black87,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Theme.of(context).primaryColor,
                            //color: Colors.black87,
                          ),
                          onPressed: () {
                            widget.openedGroup.folders[index].parentGroup =
                                widget.openedGroup;
                            getPermissionsOfFolder(
                                    widget.openedGroup.folders[index])
                                .then(((permissionEntity) {
                              if (permissionEntity.allowAll ||
                                  permissionEntity.owners.contains(FirebaseAuth
                                      .instance.currentUser!.email)) {
                                _deleteFolder(
                                    widget.openedGroup.folders[index]);
                              } else {
                                pessimisticToast(
                                    "You don't have rights for this action", 1);
                              }
                            }));
                          },
                        ),
                        onTap: () {
                          widget.openedGroup.folders[index].parentGroup =
                              widget.openedGroup;
                          getPermissionsOfFolder(
                                  widget.openedGroup.folders[index])
                              .then(((permissionEntity) {
                            if (permissionEntity.allowAll ||
                                permissionEntity.owners.contains(
                                    FirebaseAuth.instance.currentUser!.email)) {
                              openFolder(index);
                            } else {
                              pessimisticToast(
                                  "You don't have rights for this action", 1);
                            }
                          }));
                        },
                        onLongPress: () {
                          widget.openedGroup.folders[index].parentGroup =
                              widget.openedGroup;
                          getPermissionsOfFolder(
                                  widget.openedGroup.folders[index])
                              .then((permissionEntity) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PermissionsPage(
                                  permissionEntity: permissionEntity,
                                  permissionableObject:
                                      PermissionableObject.fromFolder(
                                          widget.openedGroup.folders[index]),
                                ),
                              ),
                            );
                          });
                        }),
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
                              folderName: _textController.text, files: []));
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
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
