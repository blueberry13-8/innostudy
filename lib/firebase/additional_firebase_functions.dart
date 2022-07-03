import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../folder.dart';
import '../group.dart';
import '../inno_file.dart';

Future<void> addFolder(Group group, Folder newFolder, List<Folder> path) async {
  var database = FirebaseFirestore.instance;
  var data = newFolder.toJson();
  var ref = database.collection('groups').doc(group.groupName);
  if (!(await ref.get()).exists) {
    debugPrint('addFolder: Group ${group.groupName} does not exist!');
    return;
  }
  for (var folder in path) {
    ref = ref.collection('folders').doc(folder.folderName);
    if (!(await ref.get()).exists) {
      debugPrint('addFolder: Folder ${folder.folderName} does not exist!');
      return;
    }
  }
  var doc = await ref.collection('folders').doc(newFolder.folderName).get();
  if (doc.exists) {
    debugPrint('Folder ${newFolder.folderName} is already exist.');
  } else {
    await ref.collection('folders').doc(newFolder.folderName).set(data);
    // if (path.isEmpty) {
    //   group.folders.add(newFolder);
    // } else {
    //   path.last.folders!.add(newFolder);
    // }
    //await ref.set(group.toJson());
    debugPrint('Folder ${newFolder.folderName} was created.');
  }
}

Future<void> deleteFolder(
    Group group, Folder folderForDelete, List<Folder> path) async {
  var database = FirebaseFirestore.instance;
  var ref = database.collection('groups').doc(group.groupName);
  if (!(await ref.get()).exists) {
    debugPrint('addFolder: Group ${group.groupName} does not exist!');
    return;
  }
  for (var folder in path) {
    ref = ref.collection('folders').doc(folder.folderName);
    if (!(await ref.get()).exists) {
      debugPrint('addFolder: Folder ${folder.folderName} does not exist!');
      return;
    }
  }
  var doc =
      await ref.collection('folders').doc(folderForDelete.folderName).get();
  if (doc.exists) {
    List<Folder> newPath = List.from(path);
    newPath.add(folderForDelete);
    if (folderForDelete.withFolders) {
      var foldersForDelete = await ref
          .collection('folders')
          .doc(folderForDelete.folderName)
          .collection('folders')
          .get();
      for (var folder in foldersForDelete.docs) {
        if (folder.exists) {
          Folder x = Folder.fromJson(folder.data());
          await deleteFolder(group, x, newPath);
        }
      }
    } else {
      var filesForDelete = await ref
          .collection('folders')
          .doc(folderForDelete.folderName)
          .collection('files')
          .get();
      for (var file in filesForDelete.docs) {
        if (file.exists) {
          InnoFile x = InnoFile.fromJson(file.data());
          await deleteFileFromFolderNEW(group, newPath, x.fileName);
        }
      }
    }
    await ref.collection('folders').doc(folderForDelete.folderName).delete();
  } else {
    debugPrint('Folder ${folderForDelete.folderName} does not exist.');
  }
}

Future<void> addFileToFolderNEW(
    Group group, List<Folder> path, InnoFile innoFile) async {
  for (var folder in path){
    debugPrint(folder.folderName);
  }
  dynamic curDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();
  if (!curDoc.exists) {
    debugPrint('addFileToFolder: Group does not exist');
    return;
  }
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName);
  String storagePath = '${group.groupName}/';
  for (var folder in path) {
    docRef = docRef.collection('folders').doc(folder.folderName);
    storagePath += '${folder.folderName}/';
    if (!(await docRef.get()).exists) {
      debugPrint('addFolder: Folder ${folder.folderName} does not exist!');
      return;
    }
  }
  docRef = docRef.collection('files').doc(innoFile.fileName);
  docRef.get().then((value) {
    if (!value.exists) {
      docRef.set(innoFile.toJson());
    }
  });
  final filePool = (await FirebaseStorage.instance
          .ref()
          .child(storagePath)
          .listAll())
      .items;
  for (var file in filePool) {
    if (file.name == innoFile.fileName) {
      debugPrint('addFileToFolder: File with such name already exists');
      return;
    }
  }
  docRef.update(innoFile.toJson());
  final ref = FirebaseStorage.instance
      .ref()
      .child('$storagePath${innoFile.fileName}');
  final file = innoFile.realFile!;
  await ref.putFile(file);
}

Future<void> deleteFileFromFolderNEW(
    Group group, List<Folder> path, String fileName) async {
  final curDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    debugPrint('deleteFileFromFolder: Group does not exist');
    return;
  }
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName);
  String storagePath = '${group.groupName}/';
  for (var folder in path) {
    docRef = docRef.collection('folders').doc(folder.folderName);
    storagePath += '${folder.folderName}/';
    if (!(await docRef.get()).exists) {
      debugPrint('addFolder: Folder ${folder.folderName} does not exist!');
      return;
    }
  }
  docRef = docRef.collection('files').doc(fileName);
  docRef.delete();
  final ref = FirebaseStorage.instance
      .ref()
      .child('$storagePath$fileName');
  ref.delete();
}

Future<File> getFromStorageNEW(Group group, List<Folder> path, String name) async {
  final curDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    debugPrint('deleteFileFromFolder: Group does not exist');
    //TODO: return error file!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  }
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName);
  String storagePath = '${group.groupName}/';
  for (var folder in path) {
    docRef = docRef.collection('folders').doc(folder.folderName);
    storagePath += '${folder.folderName}/';
    if (!(await docRef.get()).exists) {
      debugPrint('addFolder: Folder ${folder.folderName} does not exist!');
      //TODO: return error file!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    }
  }
  docRef = docRef.collection('files').doc(name);

  final ref = FirebaseStorage.instance
      .ref()
      .child('$storagePath$name');
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$name');
  await ref.writeToFile(file);
  return file;
}
