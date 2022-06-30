import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:work/group.dart';
import 'firebase_functions.dart';
import 'inno_file.dart';
import 'folder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import 'permission_system/permissions_entity.dart';
import 'permission_system/permissions_functions.dart';
import 'permission_system/permissions_page.dart';
import 'pessimistic_toast.dart';

///Widget that represent folders page
class FilesPage extends StatefulWidget {
  const FilesPage(
      {required this.openedFolder, required this.openedGroup, Key? key})
      : super(key: key);

  final Folder openedFolder;

  final Group openedGroup;

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late List<InnoFile> _filesList;

  ///Adds new folder to widget
  void _addFile(InnoFile innoFile) {
    addFileToFolder(widget.openedGroup, widget.openedFolder,
        innoFile.realFile!.path, innoFile.fileName);
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
              return ListView.builder(
                itemCount: _filesList.length,
                padding: const EdgeInsets.all(5),
                itemBuilder: (context, index) {
                  return Card(
                    //color: Colors.yellow[100],
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        _filesList[index].fileName,
                        style: Theme.of(context).textTheme.bodyText1,
                        //style: const TextStyle(fontSize: 17),
                      ),
                      leading: Icon(
                        Icons.file_present,
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
                          _filesList[index].parentFolder = widget.openedFolder;
                          getPermissionsOfFile(_filesList[index])
                              .then(((permissionEntity) {
                            if (permissionEntity.allowAll ||
                                permissionEntity.owners.contains(
                                    FirebaseAuth.instance.currentUser!.email)) {
                              _removeFile(_filesList[index]);
                            } else {
                              pessimisticToast(
                                  "You don't have rights for this action", 1);
                            }
                          }));
                        },
                      ),
                      onTap: () {
                        if (kDebugMode) {
                          print("WHAT");
                        }
                        _filesList[index].parentFolder = widget.openedFolder;
                        getPermissionsOfFile(_filesList[index])
                            .then(((permissionEntity) {
                          if (permissionEntity.allowAll ||
                              permissionEntity.owners.contains(
                                  FirebaseAuth.instance.currentUser!.email)) {
                            openFile(index);
                          } else {
                            pessimisticToast(
                                "You don't have rights for this action", 1);
                          }
                        }));
                      },
                      onLongPress: () {
                        _filesList[index].parentFolder = widget.openedFolder;
                        getPermissionsOfFile(_filesList[index])
                            .then((permissionEntity) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PermissionsPage(
                                permissionEntity: permissionEntity,
                                permissionableObject:
                                    PermissionableObject.fromInnoFile(
                                        _filesList[index]),
                              ),
                            ),
                          );
                        });
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
          FilePickerResult? result =
              await FilePicker.platform.pickFiles(allowMultiple: true);
          for (PlatformFile file in result!.files) {
            _addFile(InnoFile(
                realFile: File(file.path!),
                fileName: basename(file.path!),
                path: file.path!));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
