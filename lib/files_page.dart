import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:work/group.dart';
import 'package:work/permission_system/permission_master.dart';
import 'firebase_functions.dart';
import 'inno_file.dart';
import 'folder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import 'permission_system/permission_dialog.dart';
import 'permission_system/permissions_entity.dart';
import 'permission_system/permissions_functions.dart';
import 'permission_system/permissions_page.dart';
import 'pessimistic_toast.dart';

///Widget that represent folders page
class FilesPage extends StatefulWidget {
  const FilesPage(
      {required this.openedFolder,
      required this.openedGroup,
      required this.parentPermissionsGroup,
      required this.parentPermissionsFolder,
      Key? key})
      : super(key: key);

  final Folder openedFolder;

  final Group openedGroup;

  final PermissionEntity parentPermissionsFolder;
  final PermissionEntity parentPermissionsGroup;

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late List<InnoFile> _filesList;

  ///Adds new folder to widget
  void _addFile(InnoFile innoFile) {
    innoFile.parentFolder = widget.openedFolder;
    addFileToFolder(innoFile);
    setState(() {
      _filesList.add(innoFile);
    });
    debugPrint(widget.openedFolder.files.toString());
  }

  ///Removes folder from widget
  void _removeFile(InnoFile innoFile) {
    debugPrint(widget.openedFolder.folderName);
    debugPrint('${innoFile.fileName} for deleting.');
    deleteFileFromFolder(
        widget.openedGroup, widget.openedFolder, innoFile.fileName);
    setState(() {
      _filesList.remove(innoFile);
    });
  }

  Future<void> openFile(int index) async {
    if (kDebugMode) {
      print('${_filesList[index].fileName} is opened');
    }
    OpenFile.open((await getFromStorage(widget.openedGroup, widget.openedFolder,
            _filesList[index].fileName))
        .path);
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
            _removeFile(_filesList[index]);
            Navigator.of(context).pop();
            setState(() {});
          },
        );
        var alertDialog = AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Deleting of file ${_filesList[index].fileName}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Text(
            'Are you sure about deleting this file? It will be deleted without ability to restore.',
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
    //_filesList = ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.openedFolder.folderName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('groups_normalnie')
              .doc(widget.openedGroup.groupName)
              .collection('folders')
              .doc(widget.openedFolder.folderName)
              .collection('files')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.hasData) {
              _filesList = querySnapshotToInnoFileList(snapshot.data!);
              widget.openedFolder.files = _filesList;
              List<PermissionEntity> permissionEntitites =
                  querySnapshotToListOfPermissionEntities(snapshot.data!);
              return ListView.builder(
                itemCount: _filesList.length + 1,
                padding: const EdgeInsets.all(5),
                itemBuilder: (context, index) {
                  if (index == _filesList.length) {
                    return const SizedBox(
                      height: 80,
                    );
                  }
                  _filesList[index].parentFolder = widget.openedFolder;
                  RightsEntity rights = checkRightsForFile(
                      _filesList[index],
                      widget.parentPermissionsFolder,
                      widget.parentPermissionsGroup);
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        _filesList[index].fileName,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      leading: Icon(
                        Icons.file_present,
                        color: Theme.of(context).primaryColor,
                      ),
                      trailing: rights.openFileSettings
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
                                          'Delete file',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
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
                                                PermissionableObject
                                                    .fromInnoFile(
                                                        _filesList[index]),
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
                                Icons.remove_red_eye_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                if (permissionEntitites[index]
                                    .password
                                    .isEmpty) {
                                  pessimisticToast(
                                      "Only creator can allow you to delete this file.",
                                      1);
                                  return;
                                }
                                showPermissionDialog(
                                    permissionEntitites[index],
                                    PermissionableObject.fromInnoFile(
                                        _filesList[index]),
                                    context);
                              },
                            ),
                      // IconButton(
                      //   icon: Icon(
                      //     rights.openFileSettings
                      //         ? Icons.remove_circle_outline
                      //         : Icons.lock_outline,
                      //     color: Theme.of(context).primaryColor,
                      //   ),
                      //   onPressed: () {
                      //     if (rights.deleteFiles || rights.openFileSettings) {
                      //       areYouShure(context, _filesList[index].fileName,
                      //           () => _removeFile(_filesList[index]));
                      //     } else {
                      //       if (permissionEntitites[index].password.isEmpty) {
                      //         pessimisticToast(
                      //             "Only creator can allow you to delete this file.",
                      //             1);
                      //         return;
                      //       }
                      //       showPermissionDialog(
                      //           permissionEntitites[index],
                      //           PermissionableObject.fromInnoFile(
                      //               _filesList[index]),
                      //           context);
                      //     }
                      //   },
                      // ),
                      onTap: () {
                        if (rights.seeFiles) {
                          openFile(index);
                        } else {
                          pessimisticToast(
                              "You don't have rights for this action.", 1);
                        }
                      },
                      onLongPress: () {
                        if (!rights.openFileSettings) {
                          pessimisticToast(
                              "You don't have rights for this action.", 1);
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PermissionsPage(
                              permissionEntity: permissionEntitites[index],
                              permissionableObject:
                                  PermissionableObject.fromInnoFile(
                                      _filesList[index]),
                            ),
                          ),
                        );
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
        heroTag: "files page",
        onPressed: () async {
          if (!checkRightsForFolder(widget.openedFolder,
                  widget.parentPermissionsFolder, widget.parentPermissionsGroup)
              .addFiles) {
            pessimisticToast("You don't have rights for this action.", 1);
            return;
          }

          FilePickerResult? result =
              await FilePicker.platform.pickFiles(allowMultiple: true);

          if (result == null) return;

          for (PlatformFile file in result.files) {
            _addFile(InnoFile(
                realFile: File(file.path!),
                fileName: basename(file.path!),
                path: file.path!,
                creator: FirebaseAuth.instance.currentUser!.email!));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
