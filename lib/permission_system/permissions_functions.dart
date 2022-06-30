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

Future<PermissionEntity> getPermissionsOfGroup(Group group) async {
  Map<String, dynamic> data = (await FirebaseFirestore.instance
          .collection("groups_normalnie")
          .doc(group.groupName)
          .get())
      .data()!;
  if (data.containsKey("allow_all")) {
    List<String> owners = [];
    for (int i = 0; i < data["owners"].length; i++) {
      owners.add(data["owners"][i]);
    }
    return PermissionEntity(data["allow_all"], owners);
  } else {
    attachPermissionRulesToGroup(getStandartPermissionSet(), group);
    return getStandartPermissionSet();
  }
}

void attachPermissionRules(PermissionEntity permissionEntity,
    PermissionableObject permissionableObject) {
  switch (permissionableObject.type) {
    case PermissionableType.file:
      attachPermissionRulesToFile(
          permissionEntity, permissionableObject.getFile());
      break;
    case PermissionableType.folder:
      attachPermissionRulesToFolder(
          permissionEntity, permissionableObject.getFolder());
      break;
    case PermissionableType.group:
      attachPermissionRulesToGroup(
          permissionEntity, permissionableObject.getGroup());
      break;
  }
}

void attachPermissionRulesToFile(
    PermissionEntity permissionEntity, InnoFile innoFile) {}

void attachPermissionRulesToFolder(
    PermissionEntity permissionEntity, Folder folder) {}

Future<void> attachPermissionRulesToGroup(
    PermissionEntity permissionEntity, Group group) async {
  DocumentReference groupReference = FirebaseFirestore.instance
      .collection("groups_normalnie")
      .doc(group.groupName);

  await groupReference.set({
    "allow_all": permissionEntity.allowAll,
    "owners": permissionEntity.owners
  }, SetOptions(merge: true));
}
