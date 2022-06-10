import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'group.dart';
import 'firebase_functions.dart';

///Widget that represent groups page
class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPage();
}

class _GroupsPage extends State<GroupsPage> {
  //List of existing groups
  late List<Group> _groupList;

  ///Adds new group to widget
  void _addGroup(Group group) {

    setState(() {
      _groupList.add(group);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group page"),
      ),
      //Dynamicly build widget
      body: SafeArea(
        child: ListView.builder(
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
                    _groupList.remove(_groupList[index]);
                    setState(() {});
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Bottom menu for adding new groups
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                //Controller to get text from user for new group name
                TextEditingController textController = TextEditingController();

                return Container(
                  margin: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: TextField(
                          controller: textController,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
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
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}