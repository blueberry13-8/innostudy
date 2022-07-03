import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work/widgets/switch.dart';
import 'files_page.dart';
import 'folder.dart';
import 'group.dart';
import 'firebase_functions.dart';
import 'firebase/additional_firebase_functions.dart';

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
  //late List<Folder> _folderList;

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
  Future<void> _deleteFolder(Folder folder) async {
    await deleteFolder(widget.openedGroup, folder, widget.path);
    setState(() {
      if (widget.path.isEmpty) {
        widget.openedGroup.folders.remove(folder);
      } else {
        widget.path.last.parentFolder!.folders!.remove(folder);
      }
    });
  }

  void openFolder(Folder folder) {
    if (kDebugMode) {
      print('${folder.folderName} is opened');
    }
    List<Folder> newPath = List.from(widget.path);
    newPath.add(folder);
    if (folder.withFolders) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoldersPage(
            openedGroup: widget.openedGroup,
            path: newPath,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilesPage(
            path: newPath,
            openedGroup: widget.openedGroup,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    //_folderList = super.widget.openedGroup.folders;

    _textController.text = _lastFolderName;
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.openedGroup.groupName;
    if (widget.path.isNotEmpty) {
      title = widget.path.last.folderName;
    }
    var ref = FirebaseFirestore.instance
        .collection('slave_groups')
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
              return ListView.builder(
                itemCount: listOfFolders.length,
                padding: const EdgeInsets.all(5),
                itemBuilder: (context, index) {
                  return Card(
                    //color: Colors.yellow[100],
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        listOfFolders[index].folderName,
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
                          _deleteFolder(listOfFolders[index]);
                        },
                      ),
                      onTap: () {
                        openFolder(listOfFolders[index]);
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
        heroTag: "btn3",
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
                            ));
                          } else {
                            _addFolder(Folder(
                                folderName: _textController.text,
                                folders: [],
                                withFolders: true));
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
