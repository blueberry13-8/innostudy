import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work/pages/info_page.dart';
import 'package:work/pages/settings_page.dart';
import 'package:work/permission_system/permission_dialog.dart';
import 'package:work/permission_system/permission_master.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/permission_system/permissions_page.dart';
import 'package:work/utils/pessimistic_toast.dart';
import 'package:work/widgets/action_progress.dart';
import 'package:work/widgets/explorer_list_widget.dart';

import '../core/group.dart';
import '../firebase/firebase_functions.dart';
import '../permission_system/permission_object.dart';
import '../widgets/pop_up_add_object.dart';
import '../widgets/vladislav_alert.dart';
import 'folders_page.dart';

///Widget that represent groups page
class GroupsPage extends StatefulWidget {
  final bool? openTutorial;
  static bool wasAlreadyOpen = false;

  const GroupsPage({Key? key, this.openTutorial}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPage();
}

class _GroupsPage extends State<GroupsPage> with TickerProviderStateMixin {
  //List of existing groups
  late List<Group> _groupList;

  late final String _lastGroupName = '';

  ///Controller to get text from user for new group name
  final TextEditingController _textController = TextEditingController();

  ///Removes group from widget
  Future<void> _removeGroup(Group group) async {
    await deleteGroup(group);
    setState(() {
      _groupList.remove(group);
    });
  }

  void openGroup(int index, PermissionEntity inheritedPermissions) {
    if (kDebugMode) {
      print("${_groupList[index].groupName} is opened");
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          animation =
              CurvedAnimation(curve: Curves.decelerate, parent: animation);
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        reverseTransitionDuration: const Duration(milliseconds: 100),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => FoldersPage(
          openedGroup: _groupList[index],
          path: const [],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _textController.text = _lastGroupName;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (widget.openTutorial != null &&
            widget.openTutorial! &&
            !GroupsPage.wasAlreadyOpen) {
          GroupsPage.wasAlreadyOpen = true;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return const InfoPage();
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        title: const Text('Group page'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (EasyDynamicTheme.of(context).themeMode == ThemeMode.light) {
                selectedTheme = 1;
              } else if (EasyDynamicTheme.of(context).themeMode ==
                  ThemeMode.dark) {
                selectedTheme = 2;
              }
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    animation = CurvedAnimation(
                        curve: Curves.decelerate, parent: animation);
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  reverseTransitionDuration: const Duration(milliseconds: 100),
                  transitionDuration: const Duration(milliseconds: 250),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      //Dynamically build widget
      body: SafeArea(
        child: StreamBuilder(
          stream: groupsStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.hasData) {
              _groupList = querySnapshotToGroupList(snapshot.data!);
              List<PermissionEntity> permissionEntities =
                  querySnapshotToListOfPermissionEntities(snapshot.data!);
              List<PermissionableObject> listObjects = [];
              for (int i = 0; i < _groupList.length; i++) {
                _groupList[i].permissions = permissionEntities[i];
                listObjects.add(PermissionableObject.fromGroup(_groupList[i]));
              }
              return ExplorerList(
                listObjects: listObjects,
                objectIcon: Icons.group,
                openSettingsCondition: (index) {
                  RightsEntity rights = checkRightsForGroup(_groupList[index]);
                  return rights.openGroupSettings;
                },
                readactorCondition: (index) {
                  RightsEntity rights = checkRightsForGroup(_groupList[index]);
                  return rights.addFolders;
                },
                onOpen: (index) {
                  RightsEntity rights = checkRightsForGroup(_groupList[index]);
                  if (rights.seeFolders) {
                    openGroup(index, permissionEntities[index]);
                  } else {
                    pessimisticToast(
                        "You don't have rights for this action.", 1);
                  }
                },
                onDelete: (index) {
                  RightsEntity rights = checkRightsForGroup(_groupList[index]);
                  if (rights.openGroupSettings) {
                    showVladanchik(
                      context,
                      _groupList[index].groupName,
                      () {
                        showDialog(
                          barrierDismissible: false,
                          context: this.context,
                          builder: (context) {
                            return ActionProgress(parentContext: this.context);
                          },
                        );
                        _removeGroup(_groupList[index]).then(
                          (value) {
                            Navigator.of(this.context).pop();
                          },
                        );
                      },
                    );
                  } else {
                    pessimisticToast(
                        "You don't have rights for this action.", 1);
                  }
                },
                onOpenSettings: (index) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PermissionsPage(
                        path: const [],
                        permissionEntity: permissionEntities[index],
                        permissionableObject:
                            PermissionableObject.fromGroup(_groupList[index]),
                      ),
                    ),
                  );
                },
                onEyePressed: (index) {
                  RightsEntity rights = checkRightsForGroup(_groupList[index]);
                  if (!rights.addFolders) {
                    if (permissionEntities[index].password.isEmpty) {
                      pessimisticToast(
                          "Only creator can invite you to manage this group.",
                          1);
                    } else {
                      showPermissionDialog(
                          permissionEntities[index],
                          PermissionableObject.fromGroup(_groupList[index]),
                          [],
                          context);
                    }
                  }
                },
              );
            } else {
              return ActionProgress(parentContext: this.context);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'but',
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) => const PopUpObject(
              type: PermissionableType.group,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
