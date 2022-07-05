import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work/widgets/action_progress.dart';
import 'package:work/widgets/explorer_list_widget.dart';
import 'package:work/widgets/switch.dart';
import 'package:work/permission_system/permission_master.dart';
import '../widgets/vladislav_alert.dart';
import 'files_page.dart';
import '../core/folder.dart';
import '../core/group.dart';
import '../firebase/firebase_functions.dart';
import '../firebase/additional_firebase_functions.dart';
import '../permission_system/permission_dialog.dart';
import '../permission_system/permissions_entity.dart';
import '../permission_system/permissions_functions.dart';
import '../permission_system/permissions_page.dart';
import '../utils/pessimistic_toast.dart';
import '../permission_system/permission_object.dart';

///Widget that represent folders page
class FoldersPage extends StatefulWidget {
  const FoldersPage({required this.openedGroup, Key? key, required this.path})
      : super(key: key);

  final Group openedGroup;
  final List<Folder> path;

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  late List<Folder> _folderList;

  final TextEditingController _textController = TextEditingController();

  String _lastFolderName = '';

  bool withFolder = false;

  ///Adds new folder to widget
  Future<void> _addFolder(Folder folder) async {
    await addFolder(widget.openedGroup, folder, widget.path);
    // setState(() {
    //   //_folderList.add(folder);
    //   if (widget.path.isEmpty) {
    //     widget.openedGroup.folders.add(folder);
    //   } else {
    //     widget.path.last.parentFolder!.folders!.add(folder);
    //   }
    // });
  }

  ///Removes folder from widget
  Future<void> _removeFolder(Folder folder) async {
    await deleteFolder(widget.openedGroup, folder, widget.path);
    // setState(() {
    // if (widget.path.isEmpty) {
    //   widget.openedGroup.folders.remove(folder);
    // } else {
    //   widget.path.last.parentFolder!.folders!.remove(folder);
    // }
    // });
  }

  void openFolder(Folder folder, PermissionEntity permissionEntity) {
    if (kDebugMode) {
      print('${folder.folderName} is opened');
    }
    List<Folder> newPath = List.from(widget.path);
    newPath.add(folder);
    if (folder.withFolders) {
      Navigator.push(
        context,
          PageRouteBuilder(
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              animation =
                  CurvedAnimation(curve: Curves.decelerate, parent: animation);
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            reverseTransitionDuration:  const Duration(milliseconds: 100),
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (context, animation, secondaryAnimation) => FoldersPage(
              openedGroup: widget.openedGroup,
              path:newPath,
            ),
          )
        ,
      );
    } else {
      Navigator.push(
        context,
          PageRouteBuilder(
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              animation =
                  CurvedAnimation(curve: Curves.decelerate, parent: animation);
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            reverseTransitionDuration:  const Duration(milliseconds: 100),
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (context, animation, secondaryAnimation) => FilesPage(
              openedGroup: widget.openedGroup,
              path:newPath,
            ),
          )
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _folderList = super.widget.openedGroup.folders;

    _textController.text = _lastFolderName;
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.openedGroup.groupName;
    if (widget.path.isNotEmpty) {
      title = widget.path.last.folderName;
    }
    var ref = appFirebase
        .collection('groups')
        .doc(widget.openedGroup.groupName)
        .collection('folders');
    var listOfFolders = widget.openedGroup.folders;
    for (var folder in widget.path) {
      ref = ref.doc(folder.folderName).collection('folders');
      listOfFolders = folder.folders!;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: ref.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.hasData) {
              listOfFolders = querySnapshotToFoldersList(
                  snapshot.data!, widget.openedGroup);
              _folderList = List.from(listOfFolders);
              widget.openedGroup.folders = _folderList;
              List<PermissionEntity> permissionEntitites =
                  querySnapshotToListOfPermissionEntities(snapshot.data!);
              List<PermissionableObject> listObjects = [];
              for (int i = 0; i < _folderList.length; i++) {
                _folderList[i].parentGroup = widget.openedGroup;
                if (widget.path.isNotEmpty) {
                  _folderList[i].parentFolder = widget.path.last;
                }
                _folderList[i].permissions = permissionEntitites[i];
                listObjects.add(
                  PermissionableObject.fromFolder(_folderList[i]),
                );
              }
              return ExplorerList(
                listObjects: listObjects,
                objectIcon: Icons.folder,
                openSettingsCondition: (index) {
                  RightsEntity rights =
                      checkRightsForFolder(_folderList[index]);
                  return rights.openFoldersSettings;
                },
                readactorCondition: (index) {
                  RightsEntity rights =
                      checkRightsForFolder(_folderList[index]);
                  return _folderList[index].withFolders
                      ? rights.addFolders
                      : rights.addFiles;
                },
                onOpen: (index) {
                  RightsEntity rights =
                      checkRightsForFolder(_folderList[index]);
                  bool canSee = _folderList[index].withFolders
                      ? rights.seeFolders
                      : rights.seeFiles;
                  if (canSee) {
                    openFolder(_folderList[index], permissionEntitites[index]);
                  } else {
                    pessimisticToast(
                        "You don't have rights for this action.", 1);
                  }
                },
                onDelete: (index) {
                  RightsEntity rights =
                      checkRightsForFolder(_folderList[index]);
                  if (rights.openGroupSettings) {
                    showVladanchik(
                      context,
                      _folderList[index].folderName,
                      () {
                        showDialog(
                          barrierDismissible: false,
                          context: this.context,
                          builder: (context) {
                            return ActionProgress(parentContext: this.context);
                          },
                        );
                        _removeFolder(_folderList[index]).then(
                          (value) {
                            Navigator.of(this.context).pop();
                          },
                        );
                      },
                    );
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
                            PermissionableObject.fromFolder(_folderList[index]),
                      ),
                    ),
                  );
                },
                onEyePressed: (index) {
                  RightsEntity rights =
                      checkRightsForFolder(_folderList[index]);
                  bool flag = _folderList[index].withFolders
                      ? rights.addFolders
                      : rights.addFiles;

                  if (!flag) {
                    if (permissionEntitites[index].password.isEmpty) {
                      pessimisticToast(
                          "Only creator can invite you to manage this folder.",
                          1);
                    } else {
                      showPermissionDialog(
                          permissionEntitites[index],
                          PermissionableObject.fromFolder(_folderList[index]),
                          [],
                          context);
                    }
                  }
                },
              );
            } else {
              return ActionProgress(parentContext: this.context);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "folders page",
        onPressed: () {
          if (widget.path.isEmpty &&
              !checkRightsForGroup(widget.openedGroup).addFolders) {
            pessimisticToast("You don't have rights for this action.", 1);
            return;
          }
          if (widget.path.isNotEmpty &&
              widget.path.last.withFolders &&
              !checkRightsForFolder(widget.path.last).addFolders) {
            pessimisticToast("You don't have rights for this action.", 1);
            return;
          }
          if (widget.path.isNotEmpty &&
              !widget.path.last.withFolders &&
              !checkRightsForFolder(widget.path.last).addFiles) {
            pessimisticToast("You don't have rights for this action.", 1);
            return;
          }
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
                    FolderTypeSwitch(
                      callback: (value) {
                        withFolder = value;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_textController.text != '') {
                          if (!withFolder) {
                            _addFolder(Folder(
                                folderName: _textController.text,
                                files: [],
                                withFolders: false,
                                creator:
                                    FirebaseAuth.instance.currentUser!.email!));
                          } else {
                            _addFolder(Folder(
                                folderName: _textController.text,
                                folders: [],
                                withFolders: true,
                                creator:
                                    FirebaseAuth.instance.currentUser!.email!));
                          }
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
