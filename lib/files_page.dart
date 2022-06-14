import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:work/firebase_functions.dart';
import 'package:work/group.dart';
import 'inno_file.dart';
import 'folder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

///Widget that represent folders page
class FilesPage extends StatefulWidget {
  const FilesPage({required this.openedFolder, Key? key}) : super(key: key);

  final Folder openedFolder;

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late List<InnoFile> _filesList;

  ///Adds new folder to widget
  void _addFile(InnoFile innoFile) {

    addFileToFolder(widget.openedFolder.parentGroup, widget.openedFolder, innoFile.realFile!.path, innoFile.fileName);
    setState(() {
      _filesList.add(innoFile);
    });
  }

  ///Removes folder from widget
  void _removeFile(InnoFile innoFile) {
    print(widget.openedFolder.folderName);
    deleteFileFromFolder(widget.openedFolder.parentGroup, widget.openedFolder, innoFile.fileName);
    setState(() {
      _filesList.remove(innoFile);
    });
  }

  Future<void> openFile(int index) async{
    if (kDebugMode) {
      print('${_filesList[index].fileName} is opened');
    }
    OpenFile.open((await getFromStorage(widget.openedFolder.parentGroup, widget.openedFolder, _filesList[index].fileName)).path);
  }

  @override
  void initState() {
    super.initState();
    _filesList = super.widget.openedFolder.files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.openedFolder.folderName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _filesList.length,
          padding: const EdgeInsets.all(5),
          itemBuilder: (context, index) {
            return Card(
              color: Colors.yellow[100],
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(
                  _filesList[index].fileName,
                  style: const TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.file_present,
                  color: Colors.black87,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    _removeFile(_filesList[index]);
                  },
                ),
                onTap: () {
                  print("WHATT");

                  openFile(index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result =
              await FilePicker.platform.pickFiles(allowMultiple: true);
          for (PlatformFile file in result!.files) {
            _addFile(InnoFile(
                realFile: File(file.path!),
                parentFolder: widget.openedFolder,
                fileName: basename(file.path!)));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
