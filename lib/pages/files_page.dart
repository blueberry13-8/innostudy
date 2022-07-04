import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:work/core/group.dart';
import 'package:work/widgets/action_progress.dart';
import '../firebase/additional_firebase_functions.dart';
import 'package:work/permission_system/permission_master.dart';
import '../firebase/firebase_functions.dart';
import '../core/inno_file.dart';
import '../core/folder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import '../permission_system/permission_dialog.dart';
import '../permission_system/permissions_entity.dart';
import '../permission_system/permissions_functions.dart';
import '../permission_system/permissions_page.dart';
import '../utils/pessimistic_toast.dart';
import '../permission_system/permission_object.dart';
import '../widgets/explorer_list_widget.dart';
import '../widgets/vladislav_alert.dart';

///Widget that represent folders page
class FilesPage extends StatefulWidget {
  const FilesPage({required this.openedGroup, Key? key, required this.path})
      : super(key: key);

  final Group openedGroup;
  final List<Folder> path;

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late List<InnoFile> _filesList;

  ///Adds new folder to widget
  Future<void> _addFile(InnoFile innoFile) async {
    await addFileToFolderNEW(widget.openedGroup, widget.path, innoFile);
    innoFile.parentFolder = widget.path.last;
    // setState(() {
    //   _filesList.add(innoFile);
    // });
    //debugPrint(widget.openedFolder.files.toString());
  }

  ///Removes folder from widget
  Future<void> _removeFile(InnoFile innoFile) async {
    //debugPrint(widget.openedFolder.folderName);
    debugPrint('${innoFile.fileName} for deleting.');
    await deleteFileFromFolderNEW(
        widget.openedGroup, widget.path, innoFile.fileName);
    // setState(() {
    //   _filesList.remove(innoFile);
    // });
  }

  Future<void> openFile(int index) async {
    if (kDebugMode) {
      print('${_filesList[index].fileName} is opened');
    }
    OpenFile.open((await getFromStorageNEW(
            widget.openedGroup, widget.path, _filesList[index].fileName))
        .path);
  }

  @override
  void initState() {
    super.initState();
    //_filesList = ;
  }

  @override
  Widget build(BuildContext context) {
    var ref =
        appFirebase.collection('groups').doc(widget.openedGroup.groupName);
    for (var folder in widget.path) {
      ref = ref.collection('folders').doc(folder.folderName);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.last.folderName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: ref.collection('files').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.hasData) {
              _filesList = querySnapshotToInnoFileList(snapshot.data!);
              widget.path.last.files = _filesList;
              List<PermissionEntity> permissionEntitites =
                  querySnapshotToListOfPermissionEntities(snapshot.data!);
              List<PermissionableObject> listObjects = [];
              for (int i = 0; i < _filesList.length; i++) {
                _filesList[i].parentFolder = widget.path.last;
                listObjects
                    .add(PermissionableObject.fromInnoFile(_filesList[i]));
              }
              return ExplorerList(
                  listObjects: listObjects,
                  objectIcon: Icons.group,
                  openSettingsCondition: (index) {
                    RightsEntity rights = checkRightsForFile(_filesList[index]);
                    return rights.openFileSettings;
                  },
                  readactorCondition: (index) {
                    RightsEntity rights = checkRightsForFile(_filesList[index]);
                    return rights.openFileSettings;
                  },
                  onOpen: (index) {
                    openFile(index);
                  },
                  onDelete: (index) {
                    RightsEntity rights = checkRightsForFile(_filesList[index]);
                    if (rights.openFileSettings) {
                      showVladanchik(context, _filesList[index].fileName, () {
                        showDialog(
                          barrierDismissible: false,
                          context: this.context,
                          builder: (context) {
                            return ActionProgress(parentContext: this.context);
                          },
                        );
                        _removeFile(_filesList[index]).then((value) {
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
                              PermissionableObject.fromInnoFile(
                                  _filesList[index]),
                        ),
                      ),
                    );
                  },
                  onEyePressed: (index) {
                    RightsEntity rights = checkRightsForFile(_filesList[index]);
                    if (!rights.openFileSettings) {
                      if (permissionEntitites[index].password.isEmpty) {
                        pessimisticToast(
                            "Only creator can invite you to manage this file.",
                            1);
                      } else {
                        showPermissionDialog(
                            permissionEntitites[index],
                            PermissionableObject.fromInnoFile(
                                _filesList[index]),
                            [],
                            context);
                      }
                    }
                  });
            } else {
              return ActionProgress(parentContext: this.context);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "files page",
        onPressed: () async {
          if (!checkRightsForFolder(widget.path.last).addFiles) {
            pessimisticToast("You don't have rights for this action.", 1);
            return;
          }

          FilePickerResult? result =
              await FilePicker.platform.pickFiles(allowMultiple: true);

          if (result == null) return;

          for (PlatformFile file in result.files) {
            showDialog(
              barrierDismissible: false,
              context: this.context,
              builder: (context) {
                return ActionProgress(parentContext: this.context);
              },
            );
            _addFile(InnoFile(
                    realFile: File(file.path!),
                    fileName: basename(file.path!),
                    path: file.path!,
                    creator: FirebaseAuth.instance.currentUser!.email!))
                .then((value) {
              Navigator.of(this.context).pop();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
