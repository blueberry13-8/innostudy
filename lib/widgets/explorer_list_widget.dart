import 'package:flutter/material.dart';
import 'package:work/permission_system/permission_object.dart';

///Widget to show files, folders and other stuff.
class ExplorerList extends StatelessWidget {
  final List<PermissionableObject> listObjects;
  final IconData objectIcon;
  final bool Function(int) openSettingsCondition;
  final bool Function(int) readactorCondition;

  final Function(int) onDelete;
  final Function(int) onOpenSettings;
  final Function(int) onEyePressed;
  final Function(int) onOpen;

  const ExplorerList(
      {Key? key,
      required this.listObjects,
      required this.objectIcon,
      required this.openSettingsCondition,
      required this.readactorCondition,
      required this.onDelete,
      required this.onOpenSettings,
      required this.onEyePressed,
      required this.onOpen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listObjects.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              onTap: () {
                onOpen(index);
              },
              title: Text(
                listObjects[index].getName(),
                style: Theme.of(context).textTheme.bodyText1,
              ),
              subtitle: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFBCAAA4),
                  borderRadius: BorderRadius.all(
                    Radius.circular(7), //<--- border radius here
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  child: Text(
                    listObjects[index].getCreator(),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              leading: Icon(
                objectIcon,
                color: Theme.of(context).primaryColor,
              ),
              trailing: openSettingsCondition(index)
                  ? PopupMenuButton<int>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).primaryColor,
                      ),
                      offset: const Offset(0, 50),
                      color: Theme.of(context).backgroundColor,
                      elevation: 3,
                      onSelected: ((value) {
                        //Navigator.of(context).pop();
                        if (value == 1) {
                          onDelete(index);
                        } else if (value == 2) {
                          onOpenSettings(index);
                        }
                      }),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 1,
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
                                      'Delete',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                )),
                            PopupMenuItem(
                                value: 2,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Privacy settings',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ))
                          ])
                  : IconButton(
                      onPressed: () {
                        onEyePressed(index);
                      },
                      icon: Icon(readactorCondition(index)
                          ? Icons.edit
                          : Icons.remove_red_eye_outlined),
                      color: Theme.of(context).primaryColor,
                    ),
            ),
          );
        });
  }
}
