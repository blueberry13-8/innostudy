import 'package:flutter/material.dart';
import 'package:textfield_search/textfield_search.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/pessimistic_toast.dart';
import '../folder.dart';
import 'permission_object.dart';

class PermissionsPage extends StatefulWidget {
  final List<Folder> path;
  final PermissionEntity permissionEntity;
  final PermissionableObject permissionableObject;

  const PermissionsPage(
      {Key? key,
      required this.permissionEntity,
      required this.permissionableObject,
      required this.path})
      : super(key: key);

  @override
  State<PermissionsPage> createState() => _PermissionsPage();
}

class _PermissionsPage extends State<PermissionsPage> {
  List<String> _userList = [];

  @override
  void initState() {
    super.initState();
    getUsersEmails().then((value) {
      _userList = value;
      setState(() {});
    });
  }

  Widget _getSearchBox() {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: TextFieldSearch(
                    label: 'Search users',
                    controller: controller,
                    initialList: _userList,
                    textStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search users',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    child: const Text("ADD"),
                    onPressed: () {
                      if (_userList.contains(controller.text)) {
                        widget.permissionEntity.owners.add(controller.text);
                        attachPermissionRules(widget.permissionEntity,
                            widget.permissionableObject, widget.path);
                        setState(() {});
                      } else {
                        pessimisticToast("This user does not exists", 1);
                      }
                    },
                  ),
                ),
              ],
            )),
        Expanded(
          flex: 5,
          child: ListView.builder(
            itemCount: widget.permissionEntity.owners.length,
            itemBuilder: ((context, index) {
              return ListTile(
                title: Text(
                  widget.permissionEntity.owners[index],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    widget.permissionEntity.owners
                        .remove(widget.permissionEntity.owners[index]);
                    attachPermissionRules(widget.permissionEntity,
                        widget.permissionableObject, widget.path);
                    setState(() {});
                  },
                ),
              );
            }),
          ),
        ),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            child: const Text("Set password"),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController passwordController =
                        TextEditingController();

                    return AlertDialog(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      title: Text(
                        "Locking with password",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      content: SizedBox(
                          child: TextField(
                        controller: passwordController,
                      )),
                      actions: [
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              onPressed: () {
                                if (passwordController.text.isNotEmpty) {
                                  widget.permissionEntity.password =
                                      passwordController.text;
                                  attachPermissionRules(widget.permissionEntity,
                                      widget.permissionableObject, widget.path);
                                  setState(() {});
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Set")),
                        )
                      ],
                    );
                  });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permissions settings"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Checkbox(
                      value: widget.permissionEntity.allowAll,
                      onChanged: (value) {
                        if (value == null) return;

                        widget.permissionEntity.allowAll =
                            !widget.permissionEntity.allowAll;

                        attachPermissionRules(widget.permissionEntity,
                            widget.permissionableObject, widget.path);
                        setState(() {});
                      }),
                  Text(
                    "ACCESS FOR ALL",
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 9,
                child: widget.permissionEntity.allowAll
                    ? Text(
                        "All users have access for this folder",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      )
                    : _getSearchBox())
          ]),
        ),
      ),
    );
  }
}
