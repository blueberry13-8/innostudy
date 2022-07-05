import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work/firebase/firebase_functions.dart';
import 'package:work/core/folder.dart';
import 'package:work/core/group.dart';
import 'package:work/core/inno_file.dart';
import 'package:work/permission_system/permissions_entity.dart';

import 'permission_object.dart';

Future<List<String>> getUsersEmails() async {
  List<String> userEmails = [];

  var documentedEmails = (await appFirebase
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

Future<void> addRegisteredUser(String userEmail) async {
  if (!(await appFirebase
          .collection("users_emails")
          .doc("registered_users")
          .get())
      .exists) {
    await appFirebase
        .collection("users_emails")
        .doc("registered_users")
        .set({"number": 0});
  }

  int registeredUsers = (await appFirebase
      .collection("users_emails")
      .doc("registered_users")
      .get())["number"];
  registeredUsers++;
  await appFirebase
      .collection("users_emails")
      .doc("users")
      .collection("emails")
      .doc("user$registeredUsers")
      .set({"email": userEmail});
  await appFirebase
      .collection("users_emails")
      .doc("registered_users")
      .set({"number": registeredUsers});
}

Future<void> attachPermissionRules(PermissionEntity permissionEntity,
    PermissionableObject permissionableObject, List<Folder> path) async {
  switch (permissionableObject.type) {
    case PermissionableType.file:
      await attachPermissionRulesToFile(
          permissionEntity, permissionableObject.getFile(), path);
      break;
    case PermissionableType.folder:
      await attachPermissionRulesToFolder(
          permissionEntity, permissionableObject.getFolder(), path);
      break;
    case PermissionableType.group:
      await attachPermissionRulesToGroup(
          permissionEntity, permissionableObject.getGroup());
      break;
  }
}

Future<void> attachPermissionRulesToFile(PermissionEntity permissionEntity,
    InnoFile innoFile, List<Folder> path) async {
  DocumentReference<Map<String, dynamic>> docRef = appFirebase
      .collection("groups")
      .doc(path[0].parentGroup!.groupName)
      .collection("folders")
      .doc(path[0].folderName);
  for (int i = 1; i < path.length; i++) {
    docRef = docRef.collection("folders").doc(path[i].folderName);
  }

  DocumentReference fileReference =
      docRef.collection("files").doc(innoFile.fileName);
  await fileReference.set({
    "allow_all": permissionEntity.allowAll,
    "owners": permissionEntity.owners,
    "password": permissionEntity.password
  }, SetOptions(merge: true));
}

Future<void> attachPermissionRulesToFolder(
    PermissionEntity permissionEntity, Folder folder, List<Folder> path) async {
  List<Folder> normalPath = List.from(path);
  normalPath.add(folder);
  DocumentReference<Map<String, dynamic>> docRef = appFirebase
      .collection("groups")
      .doc(normalPath[0].parentGroup!.groupName)
      .collection("folders")
      .doc(normalPath[0].folderName);
  for (int i = 1; i < normalPath.length; i++) {
    docRef = docRef.collection("folders").doc(normalPath[i].folderName);
  }

  await docRef.set({
    "allow_all": permissionEntity.allowAll,
    "owners": permissionEntity.owners,
    "password": permissionEntity.password
  }, SetOptions(merge: true));
}

Future<void> attachPermissionRulesToGroup(
    PermissionEntity permissionEntity, Group group) async {
  DocumentReference groupReference =
      appFirebase.collection("groups").doc(group.groupName);

  await groupReference.set({
    "allow_all": permissionEntity.allowAll,
    "owners": permissionEntity.owners,
    "password": permissionEntity.password
  }, SetOptions(merge: true));
}

List<PermissionEntity> querySnapshotToListOfPermissionEntities(
    QuerySnapshot snapshot) {
  List<PermissionEntity> entities = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data.containsKey("allow_all")) {
      List<String> owners = [];
      for (var docOwner in data["owners"]) {
        owners.add(docOwner);
      }
      entities
          .add(PermissionEntity(data["allow_all"], owners, data["password"]));
    } else {
      entities.add(getStandartPermissionSet());
    }
  }
  return entities;
}
