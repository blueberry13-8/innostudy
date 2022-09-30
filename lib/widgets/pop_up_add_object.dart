import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work/firebase/additional_firebase_functions.dart';
import 'package:work/widgets/switch.dart';

import '../core/folder.dart';
import '../core/group.dart';
import '../firebase/firebase_functions.dart';
import '../permission_system/permission_object.dart';
import '../utils/pessimistic_toast.dart';

class PopUpObject extends StatefulWidget {
  final PermissionableType type;
  final List<Folder>? path;
  final Group? parentGroup;

  const PopUpObject({Key? key, required this.type, this.path, this.parentGroup})
      : super(key: key);

  @override
  State<PopUpObject> createState() => _PopUpObjectState();
}

class _PopUpObjectState extends State<PopUpObject> {
  late String name = '';

  late String description = '';

  bool withFolders = false;

  void replaceLastRoute(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'but',
      child: AlertDialog(
        scrollable: true,
        backgroundColor: Theme.of(context).hoverColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Column(
          children: [
            Text(
              'Enter name',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(
              height: 5,
            ),
            TextField(
              onChanged: (String value) => name = value,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Enter description',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            TextField(
              onChanged: (String value) => description = value,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).focusColor,
              ),
              onPressed: () async {
                if (name != '') {
                  if (widget.type == PermissionableType.group) {
                    addGroup(Group(
                            groupName: name,
                            description: description,
                            folders: [],
                            creator: FirebaseAuth.instance.currentUser!.email!))
                        .then((value) => replaceLastRoute(context));
                  } else if (widget.type == PermissionableType.folder) {
                    addFolder(
                            widget.parentGroup!,
                            Folder(
                                files: [],
                                folders: [],
                                folderName: name,
                                description: description,
                                withFolders: withFolders,
                                creator:
                                    FirebaseAuth.instance.currentUser!.email!),
                            widget.path!)
                        .then((value) => replaceLastRoute(context));
                  }
                } else {
                  pessimisticToast('Name can not be empty', 3);
                }
              },
              child: Text(
                "Add",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Builder(
              builder: (BuildContext context) {
                if (widget.type == PermissionableType.folder) {
                  return FolderTypeSwitch(
                    callback: (value) => withFolders = value,
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
