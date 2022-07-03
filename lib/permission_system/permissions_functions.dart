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

Future<PermissionEntity> getPermissionsOfFile(InnoFile innoFile) async {
  Map<String, dynamic> data = (await FirebaseFirestore.instance
          .collection("groups_normalnie")
          .doc(innoFile.parentFolder!.parentGroup!.groupName)
          .collection("folders")
          .doc(innoFile.parentFolder!.folderName)
          .collection("files")
          .doc(innoFile.fileName)
          .get())
      .data()!;
  if (data.containsKey("allow_all")) {
    List<String> owners = [];
    for (int i = 0; i < data["owners"].length; i++) {
      owners.add(data["owners"][i]);
    }
    return PermissionEntity(data["allow_all"], owners, data["password"]);
  } else {
    attachPermissionRulesToFile(getStandartPermissionSet(), innoFile);
    return getStandartPermissionSet();
  }
}

Future<PermissionEntity> getPermissionsOfFolder(Folder folder) async {
  Map<String, dynamic> data = (await FirebaseFirestore.instance
          .collection("groups_normalnie")
          .doc(folder.parentGroup!.groupName)
          .collection("folders")
          .doc(folder.folderName)
          .get())
      .data()!;
  if (data.containsKey("allow_all")) {
    List<String> owners = [];
    for (int i = 0; i < data["owners"].length; i++) {
      owners.add(data["owners"][i]);
    }
    return PermissionEntity(data["allow_all"], owners, data["password"]);
  } else {
    attachPermissionRulesToFolder(getStandartPermissionSet(), folder);
    return getStandartPermissionSet();
  }
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
    return PermissionEntity(data["allow_all"], owners, data["password"]);
  } else {
    attachPermissionRulesToGroup(getStandartPermissionSet(), group);
    return getStandartPermissionSet();
  }
}

Future<void> attachPermissionRules(PermissionEntity permissionEntity,
    PermissionableObject permissionableObject) async {
  switch (permissionableObject.type) {
    case PermissionableType.file:
      await attachPermissionRulesToFile(
          permissionEntity, permissionableObject.getFile());
      break;
    case PermissionableType.folder:
      await attachPermissionRulesToFolder(
          permissionEntity, permissionableObject.getFolder());
      break;
    case PermissionableType.group:
      await attachPermissionRulesToGroup(
          permissionEntity, permissionableObject.getGroup());
      break;
  }
}

Future<void> attachPermissionRulesToFile(
    PermissionEntity permissionEntity, InnoFile innoFile) async {
  DocumentReference fileReference = FirebaseFirestore.instance
      .collection("groups_normalnie")
      .doc(innoFile.parentFolder!.parentGroup!.groupName)
      .collection("folders")
      .doc(innoFile.parentFolder!.folderName)
      .collection("files")
      .doc(innoFile.fileName);
  await fileReference.set({
    "allow_all": permissionEntity.allowAll,
    "owners": permissionEntity.owners,
    "password": permissionEntity.password
  }, SetOptions(merge: true));
}

Future<void> attachPermissionRulesToFolder(
    PermissionEntity permissionEntity, Folder folder) async {
  DocumentReference folderReference = FirebaseFirestore.instance
      .collection("groups_normalnie")
      .doc(folder.parentGroup!.groupName)
      .collection("folders")
      .doc(folder.folderName);
  await folderReference.set({
    "allow_all": permissionEntity.allowAll,
    "owners": permissionEntity.owners,
    "password": permissionEntity.password
  }, SetOptions(merge: true));
}

Future<void> attachPermissionRulesToGroup(
    PermissionEntity permissionEntity, Group group) async {
  DocumentReference groupReference = FirebaseFirestore.instance
      .collection("groups_normalnie")
      .doc(group.groupName);

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
