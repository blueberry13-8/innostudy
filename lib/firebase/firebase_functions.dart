import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'additional_firebase_functions.dart';
import '../core/inno_file.dart';
import '../core/folder.dart';
import '../core/group.dart';
import 'package:firebase_auth/firebase_auth.dart';

late FirebaseFirestore appFirebase;

void loadAppFirebase() {
  appFirebase = FirebaseFirestore.instance;
}

/// Add group to the DB if it doesn't exist.
Future<void> addGroup(Group group) async {
  final data = group.toJson();
  var database = FirebaseFirestore.instance;
  var doc =
      await database.collection('groups').doc(group.groupName).get();
  if (doc.exists) {
    debugPrint('Group with name - ${group.groupName} exists.');
  } else {
    await database
        .collection('groups')
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
      await database.collection('groups').doc(group.groupName).get();
  if (doc.exists) {
    var foldersForDelete = await database
        .collection('groups')
        .doc(group.groupName)
        .collection('folders')
        .get();
    for (var folder in foldersForDelete.docs) {
      if (folder.exists) {
        Folder f = Folder.fromJson(folder.data());
        await deleteFolder(group, f, []);
      }
    }
    await database.collection('groups').doc(group.groupName).delete();
    debugPrint('Group ${group.groupName} was deleted.');
  } else {
    debugPrint('Group ${group.groupName} are not existing.');
  }
}

/// Stream for watching changes into groups' collection.
/// Use it for dynamic rendering Group List.
final Stream<QuerySnapshot> groupsStream =
    FirebaseFirestore.instance.collection('groups').snapshots();

final Stream<User?> consumerStream = FirebaseAuth.instance.authStateChanges();

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
