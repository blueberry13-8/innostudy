import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/utils/pessimistic_toast.dart';

import '../core/folder.dart';
import 'permission_object.dart';

void showPermissionDialog(
    PermissionEntity permissionEntity,
    PermissionableObject permissionableObject,
    List<Folder> path,
    BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        TextEditingController passwordController = TextEditingController();

        return AlertDialog(
          title: const Text("Enter the access password."),
          content: SizedBox(
              child: TextField(
            controller: passwordController,
          )),
          actions: [
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                  onPressed: () {
                    if (passwordController.text == permissionEntity.password) {
                      permissionEntity.owners
                          .add(FirebaseAuth.instance.currentUser!.email!);
                      attachPermissionRules(
                          permissionEntity, permissionableObject, path);
                    } else {
                      pessimisticToast("This password is not right.", 1);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Ok")),
            )
          ],
        );
      });
}

void areYouShure(
    BuildContext context, String objectName, VoidCallback callback) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Removing"),
          content: Text("Do you want to delete $objectName?."),
          actions: [
            Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                    flex: 4,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No"))),
                const Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
                Expanded(
                    flex: 4,
                    child: ElevatedButton(
                        onPressed: () {
                          callback();
                          Navigator.pop(context);
                        },
                        child: const Text("Yes"))),
              ]),
            )
          ],
        );
      });
}
