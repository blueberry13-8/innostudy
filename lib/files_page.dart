import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:work/group.dart';
import 'firebase/additional_firebase_functions.dart';
import 'firebase_functions.dart';
import 'inno_file.dart';
import 'folder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

///Widget that represent folders page
class FilesPage extends StatefulWidget {
  const FilesPage({required this.openedGroup, required this.path, Key? key})
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
    await addFileToFolderNEW(widget.openedGroup, widget.path,
        innoFile.realFile!.path, innoFile.fileName);
    setState(() {
      _filesList.add(innoFile);
    });
    //debugPrint(widget.openedFolder.files.toString());
  }

  ///Removes folder from widget
  Future<void> _removeFile(InnoFile innoFile) async {
    //debugPrint(widget.openedFolder.folderName);
    debugPrint('${innoFile.fileName} for deleting.');
    await deleteFileFromFolderNEW(
        widget.openedGroup, widget.path, innoFile.fileName);
    setState(() {
      _filesList.remove(innoFile);
    });
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
    var ref = FirebaseFirestore.instance
        .collection('slave_groups')
        .doc(widget.openedGroup.groupName);
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
                          _removeFile(_filesList[index]);
                        },
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
        heroTag: "btn4",
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
