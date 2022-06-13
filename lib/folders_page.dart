import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:innostudy/files_page.dart';
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
  late List<Folder> _folderList;

  final TextEditingController _textController = TextEditingController();

  String _lastFolderName = '';

  ///Adds new folder to widget
  void _addFolder(Group group, Folder folder) {
    setState(() {
      _folderList.add(folder);
      addFolderInGroup(group, folder);
    });
  }

  ///Removes folder from widget
  void _deleteFolder(Group group, Folder folder) {
    setState(() {
      _folderList.remove(folder);
      deleteFolderFromGroup(group, folder);
    });
  }

  void openFolder(int index) {
    if (kDebugMode) {
      print('${_folderList[index].folderName} is opened');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilesPage(
          openedFolder: _folderList[index],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _folderList = super.widget.openedGroup.folders;

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
        child: ListView.builder(
          itemCount: _folderList.length,
          padding: const EdgeInsets.all(5),
          itemBuilder: (context, index) {
            return Card(
              color: Colors.yellow[100],
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(
                  _folderList[index].folderName,
                  style: const TextStyle(fontSize: 20),
                ),
                leading: const Icon(
                  Icons.folder,
                  color: Colors.black87,
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    _deleteFolder(widget.openedGroup, _folderList[index]);
                  },
                ),
                onTap: () {
                  openFolder(index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                          _addFolder(
                              widget.openedGroup,
                              Folder(
                                  folderName: _textController.text,
                                  parentGroup: widget.openedGroup,
                                  files: []));
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
