import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work/folder.dart';
import 'package:work/group.dart';
import 'package:work/inno_file.dart';
import 'package:work/permission_system/permissions_entity.dart';

import 'permission_object.dart';

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

Future<void> addRegisteredUser(String userEmail) async {
  int registeredUsers = (await FirebaseFirestore.instance
      .collection("users_emails")
      .doc("registered_users")
      .get())["number"];
  registeredUsers++;
  await FirebaseFirestore.instance
      .collection("users_emails")
      .doc("users")
      .collection("emails")
      .doc("user$registeredUsers")
      .set({"email": userEmail});
  await FirebaseFirestore.instance
      .collection("users_emails")
      .doc("registered_users")
      .set({"number": registeredUsers});
}

Future<PermissionEntity> getPermissionsOfFile(
    InnoFile innoFile, List<Folder> path) async {
  DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
      .collection("groups")
      .doc(path[0].parentGroup!.groupName)
      .collection("folders")
      .doc(path[0].folderName);
  for (int i = 1; i < path.length; i++) {
    docRef = docRef.collection("folders").doc(path[i].folderName);
  }

  Map<String, dynamic> data =
      (await docRef.collection("files").doc(innoFile.fileName).get()).data()!;
  if (data.containsKey("allow_all")) {
    List<String> owners = [];
    for (int i = 0; i < data["owners"].length; i++) {
      owners.add(data["owners"][i]);
    }
    return PermissionEntity(data["allow_all"], owners, data["password"]);
  } else {
    attachPermissionRulesToFile(getStandartPermissionSet(), innoFile, path);
    return getStandartPermissionSet();
  }
}

Future<PermissionEntity> getPermissionsOfFolder(
    Folder folder, List<Folder> path) async {
  List<Folder> normalPath = List.from(path);

  DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
      .collection("groups")
      .doc(normalPath[0].parentGroup!.groupName)
      .collection("folders")
      .doc(normalPath[0].folderName);
  for (int i = 1; i < normalPath.length; i++) {
    docRef = docRef.collection("folders").doc(normalPath[i].folderName);
  }
  Map<String, dynamic> data = (await docRef.get()).data()!;
  if (data.containsKey("allow_all")) {
    List<String> owners = [];
    for (int i = 0; i < data["owners"].length; i++) {
      owners.add(data["owners"][i]);
    }
    return PermissionEntity(data["allow_all"], owners, data["password"]);
  } else {
    attachPermissionRulesToFolder(getStandartPermissionSet(), folder, path);
    return getStandartPermissionSet();
  }
}

Future<PermissionEntity> getPermissionsOfGroup(Group group) async {
  Map<String, dynamic> data = (await FirebaseFirestore.instance
          .collection("groups")
          .doc(group.groupName)
          .get())
      .data()!;
  if (data.containsKey("allow_all")) {
    List<String> owners = [];
    for (int i = 0; i < data["owners"].length; i++) {
      owners.add(data["owners"][i]);
    }
    return PermissionEntity(data["allow_all"], owners, data["password"]);
  } else {
    attachPermissionRulesToGroup(getStandartPermissionSet(), group);
    return getStandartPermissionSet();
  }
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
  DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
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
  DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore.instance
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
      FirebaseFirestore.instance.collection("groups").doc(group.groupName);

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
