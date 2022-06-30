import 'package:flutter/material.dart';
import 'package:textfield_search/textfield_search.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/pessimistic_toast.dart';

class PermissionsPage extends StatefulWidget {
  final PermissionEntity permissionEntity;
  final PermissionableObject permissionableObject;

  const PermissionsPage(
      {Key? key,
      required this.permissionEntity,
      required this.permissionableObject})
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
                      label: "Search users",
                      controller: controller,
                      initialList: _userList,
                    )),
                Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      child: const Text("ADD"),
                      onPressed: () {
                        if (_userList.contains(controller.text)) {
                          widget.permissionEntity.owners.add(controller.text);
                          attachPermissionRules(widget.permissionEntity,
                              widget.permissionableObject);
                          setState(() {});
                        } else {
                          pessimisticToast("This user does not exists", 1);
                        }
                      },
                    ))
              ],
            )),
        Expanded(
            flex: 5,
            child: ListView.builder(
                itemCount: widget.permissionEntity.owners.length,
                itemBuilder: ((context, index) {
                  return ListTile(
                    title: Text(widget.permissionEntity.owners[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        widget.permissionEntity.owners
                            .remove(widget.permissionEntity.owners[index]);
                        attachPermissionRules(widget.permissionEntity,
                            widget.permissionableObject);
                        setState(() {});
                      },
                    ),
                  );
                }))),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            child: const Text("Set password"),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Locking with password"),
                      content: SizedBox(child: TextField()),
                      actions: [
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              onPressed: () {}, child: const Text("Set")),
                        )
                      ],
                    );
                  });
            },
          ),
        )
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
                  Checkbox(
                      value: widget.permissionEntity.allowAll,
                      onChanged: (value) {
                        if (value == null) return;

                        widget.permissionEntity.allowAll =
                            !widget.permissionEntity.allowAll;

                        attachPermissionRules(widget.permissionEntity,
                            widget.permissionableObject);
                        setState(() {});
                      }),
                  const Text(
                    "ACCESS FOR ALL",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
            Expanded(
                flex: 9,
                child: widget.permissionEntity.allowAll
                    ? const Text("All users have access for this folder")
                    : _getSearchBox())
          ]),
        )));
  }
}
