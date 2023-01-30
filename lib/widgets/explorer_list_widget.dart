import 'package:flutter/material.dart';
import 'package:work/permission_system/permission_object.dart';
import 'pop_up_window.dart';

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
      itemCount: listObjects.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == listObjects.length) {
          return const SizedBox(
            height: 70,
          );
        }
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => PopUpWindow(
                creator: listObjects[index].getCreator(),
                description: listObjects[index].getDescription(),
              ),
            );
          },
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 4,
            ),
            child: ListTile(
              onTap: () {
                onOpen(index);
              },
              title: Text(
                listObjects[index].getName(),
                style: Theme.of(context).textTheme.titleLarge,
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
                      color: Theme.of(context).colorScheme.background,
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
                              Expanded(
                                flex: 2,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Text(
                                  'Delete',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.settings,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Text(
                                  'Privacy settings',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
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
          ),
        );
      },
    );
  }
}
