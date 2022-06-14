import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work/inno_file.dart';
import 'folder.dart';
import 'group.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Add group to the DB if it doesn't exist.
void addGroup(Group group) {
  final data = group.toJson();
  var database = FirebaseFirestore.instance;
  database.collection('groups').doc(group.groupName).get().then((value) {
    if (value.exists) {
      debugPrint('Group with name - ${group.groupName} exists.');
    } else {
      database.collection('groups').doc(group.groupName).set(data);
      for (var folder in group.folders) {
        addFolderInGroup(group, folder);
      }
      debugPrint(
          'Group with name - ${group.groupName} was successfully created!');
    }
  });
}

/// Delete group form DB if it exists.
void deleteGroup(Group group) {
  var database = FirebaseFirestore.instance;
  database.collection('groups').doc(group.groupName).get().then((value) {
    if (value.exists) {
      database.collection('groups').doc(group.groupName).delete();
      debugPrint('Group ${group.groupName} was deleted.');
    } else {
      debugPrint('Group ${group.groupName} are not existing.');
    }
  });
}

/// Stream for watching changes into groups' collection.
/// Use it for dynamic rendering Group List.
final Stream<QuerySnapshot> groupsStream =
    FirebaseFirestore.instance.collection('groups').snapshots();

void addFolderInGroup(Group group, Folder folder) {
  var database = FirebaseFirestore.instance;
  var data = folder.toJson();
  database
      .collection('groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .get()
      .then((value) {
    if (value.exists) {
      debugPrint('');
    } else {
      database
          .collection('groups')
          .doc(group.groupName)
          .collection('folders')
          .doc(folder.folderName)
          .set(data);
      database.collection('groups').doc(group.groupName).set(group.toJson());
      debugPrint('');
    }
  });
}

dynamicToPath(List <dynamic> paths){
  List<InnoFile> correctPaths = [];
  for (final path in paths){
    correctPaths.add(InnoFile(fileName: path));
  }
  return correctPaths;
}

List<Folder> querySnapshotToFoldersList(QuerySnapshot snapshot, Group group) {
  List<Folder> folders = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data['folderName'] != null) {
      folders.add(Folder(folderName: data["folderName"], files: dynamicToPath(data['files'],), parentGroup: group));
    }
  }
  return folders;
}

void deleteFolderFromGroup(Group group, Folder folder) {
  var database = FirebaseFirestore.instance;
  database
      .collection('groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .get()
      .then((value) {
    if (value.exists) {
      database
          .collection('groups')
          .doc(group.groupName)
          .collection('folders')
          .doc(folder.folderName)
          .delete();
      debugPrint('');
    } else {
      debugPrint('');
    }
  });
}

/// Add file to the selected group (if group exists).
Future<void> addFileToFolder(Group? group, Folder folder, String filePath, String name) async {
  if (group == null){
    throw Exception('addFileToGroup: group is null');
  }
  dynamic cur_doc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();

  if (cur_doc.exists == false){
    throw Exception('addFileToGroup: Group does not exist');
  }
  final filePool =  (await FirebaseStorage.instance.ref().child('files/').listAll()).items;
  for (var file in filePool){
    if (file.name == name){
      throw Exception('addFileToGroup: File with such name already exists');
    }
  }
  await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName).collection(folder.folderName).doc(name).set({'files/$name':'files/$name'});
  final ref = await FirebaseStorage.instance.ref().child('files/$name');
  final file = await File(filePath);
  await ref.putFile(file);
}

Future<void> deleteFileFromFolder(Group? group, Folder folder, String fileName) async {
  if (group == null){
    throw Exception('addFileToGroup: group is null');
  }
  final cur_doc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();

  if (cur_doc.exists == false){
    throw Exception('addFileToGroup: Group does not exist');
  }
  final eraseDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName).collection(folder.folderName).doc(fileName); // it's folders, not files
  if ((await eraseDoc.get()).exists == false){
    throw Exception('deleteFileFromGroup: File/Folder to delete does not exist');
  }
  eraseDoc.delete();
  final ref = await FirebaseStorage.instance.ref().child('files/$fileName');
  ref.delete();
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
