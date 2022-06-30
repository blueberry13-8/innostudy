import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work/folder.dart';
import 'package:work/group.dart';
import 'package:work/inno_file.dart';
import 'package:work/permission_system/permissions_entity.dart';

Future<List<String>> getUsersEmails() async {
  List<String> userEmails = [];

  var documentedEmails = (await FirebaseFirestore.instance
          .collection("users_emails")
          .doc("users")
          .collection("emails")
          .get())
      .docs;

  for (var documentEmail in documentedEmails) {
    userEmails.add(documentEmail.get("email"));
  }

  return userEmails;
}

List<String> getOwnersOfFile(InnoFile innoFile) {
  return [];
}

List<String> getOwnersOfFolder(Folder folder) {
  return [];
}

List<String> getOwnersOfGroup(Group group) {
  return [];
}

void attachPermissionRulesToFolder(
    PermissionEntity permissionEntity, Folder folder) {}

void attachPermissionRulesToGroup(
    PermissionEntity permissionEntity, Group group) {}

void attachPermissionRulesToPage(PermissionEntity permissionEntity) {}
