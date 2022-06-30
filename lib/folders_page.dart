import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'files_page.dart';
import 'folder.dart';
import 'group.dart';
import 'firebase_functions.dart';

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
            _deleteFolder(widget.openedGroup.folders[index]);
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
                                    'Delete folder',
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
                        openFolder(index);
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
