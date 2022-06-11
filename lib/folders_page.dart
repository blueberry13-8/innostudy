
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'folder.dart';

///Widget that represent folders page
class FoldersPage extends StatefulWidget {
  const FoldersPage({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  late List<Folder> _folderList;

  final TextEditingController _textController = TextEditingController();

  String _lastFolderName = '';

  ///Adds new folder to widget
  void _addFolder(Folder folder) {
    setState(() {
      _folderList.add(folder);
      //addFolder(folder);
    });
  }

  ///Removes folder from widget
  void _removerFolder(Folder folder) {
    setState(() {
      _folderList.remove(folder);
      //deleteFolder(folder);
    });
  }

  void openFolder(int index) {
    if (kDebugMode) {
      print('${_folderList[index].folderName} is opened');
    }
  }

  @override
  void initState() {
    super.initState();

    _folderList = [
      Folder(folderName: "Assignment 1"),
      Folder(folderName: "Assignment 2"),
      Folder(folderName: "Assignment 3"),
    ];

    _textController.text = _lastFolderName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                    _removerFolder(_folderList[index]);
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
                      bottom: MediaQuery
                          .of(context)
                          .viewInsets
                          .bottom + 15),
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
                                Folder(folderName: _textController.text));
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
