import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'inno_file.dart';
import 'folder.dart';
import 'group.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

/// Add group to the DB if it doesn't exist.
Future<void> addGroup(Group group) async {
  final data = group.toJson();
  var database = FirebaseFirestore.instance;
  var doc =
      await database.collection('slave_groups').doc(group.groupName).get();
  if (doc.exists) {
    debugPrint('Group with name - ${group.groupName} exists.');
  } else {
    await database
        .collection('slave_groups')
        .doc(group.groupName)
        .set(data);
    // for (var folder in group.folders) {
    //   addFolderInGroup(group, folder);
    // }
    debugPrint(
        'Group with name - ${group.groupName} was successfully created!');
  }
}

/// Delete group form DB if it exists.
Future<void> deleteGroup(Group group) async {
  var database = FirebaseFirestore.instance;
  var doc =
      await database.collection('slave_groups').doc(group.groupName).get();
  if (doc.exists) {
    var foldersForDelete = await database
        .collection('slave_groups')
        .doc(group.groupName)
        .collection('folders')
        .get();
    for (var folder in foldersForDelete.docs) {
      if (folder.exists) {
        Folder f = Folder.fromJson(folder.data());
        await deleteFolderFromGroup(group, f);
      }
    }
    await database.collection('slave_groups').doc(group.groupName).delete();
    debugPrint('Group ${group.groupName} was deleted.');
  } else {
    debugPrint('Group ${group.groupName} are not existing.');
  }
}

/// Stream for watching changes into groups' collection.
/// Use it for dynamic rendering Group List.
final Stream<QuerySnapshot> groupsStream =
    FirebaseFirestore.instance.collection('slave_groups').snapshots();

final Stream<User?> consumerStream = FirebaseAuth.instance.authStateChanges();

Future<void> addFolderInGroup(Group group, Folder folder) async {
  var database = FirebaseFirestore.instance;
  var data = folder.toJson();
  var doc = await database
      .collection('slave_groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .get();
  if (doc.exists) {
    debugPrint('Folder ${folder.folderName} is already exist.');
  } else {
    await database
        .collection('slave_groups')
        .doc(group.groupName)
        .collection('folders')
        .doc(folder.folderName)
        .set(data);
    group.folders.add(folder);
    await database
        .collection('slave_groups')
        .doc(group.groupName)
        .set(group.toJson());
    debugPrint('Folder ${folder.folderName} was created.');
  }
}

Future<void> deleteFolderFromGroup(Group group, Folder folder) async {
  var database = FirebaseFirestore.instance;
  var doc = await database
      .collection('slave_groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .get();
  if (doc.exists) {
    var filesForDelete = await database
        .collection('slave_groups')
        .doc(group.groupName)
        .collection('folders')
        .doc(folder.folderName)
        .collection('files')
        .get();
    for (var file in filesForDelete.docs) {
      if (file.exists) {
        InnoFile x = InnoFile.fromJson(file.data());
        await deleteFileFromFolder(group, folder, x.fileName);
      }
    }
    await database
        .collection('slave_groups')
        .doc(group.groupName)
        .collection('folders')
        .doc(folder.folderName)
        .delete();
  } else {
    debugPrint('Folder ${folder.folderName} does not exist.');
  }
}

List<Folder> querySnapshotToFoldersList(QuerySnapshot snapshot, Group group) {
  List<Folder> folders = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data['folderName'] != null) {
      folders.add(Folder.fromJson(data));
    }
  }
  return folders;
}

/// Add file to the selected group (if group exists).
Future<void> addFileToFolder(
    Group group, Folder folder, String filePath, String name) async {
  dynamic curDoc = await FirebaseFirestore.instance
      .collection('slave_groups')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    throw Exception('addFileToFolder: Group does not exist');
  }
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('slave_groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .collection('files')
      .doc(name);
  docRef.get().then((value) {
    if (!value.exists) {
      docRef.set(InnoFile(
              fileName: name,
              path: '${group.groupName}/${folder.folderName}/$name')
          .toJson());
    }
  });
  final filePool = (await FirebaseStorage.instance
          .ref()
          .child('${group.groupName}/${folder.folderName}/')
          .listAll())
      .items;
  for (var file in filePool) {
    if (file.name == name) {
      throw Exception('addFileToFolder: File with such name already exists');
    }
  }
  docRef.update(InnoFile(
          fileName: name, path: '${group.groupName}/${folder.folderName}/$name')
      .toJson());
  final ref = FirebaseStorage.instance
      .ref()
      .child('${group.groupName}/${folder.folderName}/$name');
  final file = File(filePath);
  await ref.putFile(file);
}

Future<void> deleteFileFromFolder(
    Group group, Folder folder, String fileName) async {
  final curDoc = await FirebaseFirestore.instance
      .collection('slave_groups')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    throw Exception('deleteFileFromFolder: Group does not exist');
  }
  final docRef = FirebaseFirestore.instance
      .collection('slave_groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .collection('files')
      .doc(fileName); // it's folders, not files
  docRef.delete();
  final ref = FirebaseStorage.instance
      .ref()
      .child('${group.groupName}/${folder.folderName}/$fileName');
  debugPrint('${group.groupName}/${folder.folderName}/$fileName');
  ref.delete();
}

Future<File> getFromStorage(Group group, Folder folder, String name) async {
  dynamic curDoc = await FirebaseFirestore.instance
      .collection('slave_groups')
      .doc(group.groupName)
      .get();

  if (!curDoc.exists) {
    throw Exception('deleteFileFromFolder: Group does not exist');
  }
  final ref = FirebaseStorage.instance
      .ref()
      .child('${group.groupName}/${folder.folderName}/$name');
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$name');
  await ref.writeToFile(file);
  return file;
}

List<Group> querySnapshotToGroupList(QuerySnapshot snapshot) {
  List<Group> groups = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data['groupName'] != null) {
      debugPrint("!");
      groups.add(Group.fromJson(data));
    }
  }
  return groups;
}

List<InnoFile> querySnapshotToInnoFileList(QuerySnapshot snapshot) {
  List<InnoFile> files = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data['fileName'] != null) {
      //debugPrint("!");
      files.add(InnoFile.fromJson(data));
    }
  }
  return files;
}
