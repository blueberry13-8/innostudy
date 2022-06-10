import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'group.dart';
import 'firebase_functions.dart';
import 'package:firebase_core/firebase_core.dart';

///Widget that represent groups page
class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPage();
}

class _GroupsPage extends State<GroupsPage> {
  //List of existing groups
  late List<Group> _groupList;

  String _lastGroupName = '';

  //Controller to get text from user for new group name
  TextEditingController _textController = TextEditingController();

  ///Adds new group to widget
  void _addGroup(Group group) {
    setState(() {
      _groupList.add(group);
      addGroup(group);
    });
  }

  ///Removes group from widget
  void _removeGroup(Group group) {
    setState(() {
      _groupList.remove(group);
      deleteGroup(group);
    });
  }

  void openGroup(int index) {
    if (kDebugMode) {
      print("${_groupList[index].groupName} is opened");
    }
  }

  @override
  void initState() {
    super.initState();

    //Example of groups
    _groupList = [
      Group(groupName: "Math analysis"),
      Group(groupName: "AGLA"),
      Group(groupName: "Computer architecture")
    ];

    _textController.text = _lastGroupName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group page"),
      ),
      //Dynamicly build widget
      body: SafeArea(
          child: StreamBuilder(
        stream: groupsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Idiot");
          } else if (snapshot.hasData) {
            _groupList = querySnapshotToGroupList(snapshot.data!);
            return ListView.builder(
              itemCount: _groupList.length,
              padding: const EdgeInsets.all(5),
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.yellow[100],
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(
                      _groupList[index].groupName,
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
                        _removeGroup(_groupList[index]);
                      },
                    ),
                    onTap: () {
                      openGroup(index);
                    },
                  ),
                );
              },
              // separatorBuilder: (BuildContext context, int index) =>
              //     const Divider(),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Bottom menu for adding new groups
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
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
                          _lastGroupName = value;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text != "") {
                            _addGroup(Group(groupName: _textController.text));
                            Navigator.pop(context);
                            _textController.text = '';
                            _lastGroupName = '';
                          }
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
/*
Container(
                  margin: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        margin: const EdgeInsets.all(10),
                        child: TextField(
                          autofocus: true,
                          controller: textController,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        //margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                            onPressed: () {
                              if (textController.text != "") {
                                _addGroup(
                                    Group(groupName: textController.text));
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Add")),
                      )
                    ],
                  ),
                );
 */
