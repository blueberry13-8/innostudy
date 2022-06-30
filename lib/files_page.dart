import 'package:cloud_firestore/cloud_firestore.dart';
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
              return ListView.builder(
                itemCount: _filesList.length,
                padding: const EdgeInsets.all(5),
                itemBuilder: (context, index) {
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
                                    'Delete file',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                Navigator.of(context).pop();
                                _showAlertDialog(context, index);
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
                        if (kDebugMode) {
                          print("WHAT");
                        }
                        openFile(index);
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
