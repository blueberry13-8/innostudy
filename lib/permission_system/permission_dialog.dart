import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';
import 'package:work/pessimistic_toast.dart';

void showPermissionDialog(PermissionEntity permissionEntity,
    PermissionableObject permissionableObject, BuildContext context) {
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
                          permissionEntity, permissionableObject);
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
