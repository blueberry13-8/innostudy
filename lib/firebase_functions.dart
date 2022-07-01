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
void addGroup(Group group) {
  final data = group.toJson();
  var database = FirebaseFirestore.instance;
  database
      .collection('groups_normalnie')
      .doc(group.groupName)
      .get()
      .then((value) {
    if (value.exists) {
      debugPrint('Group with name - ${group.groupName} exists.');
    } else {
      database.collection('groups_normalnie').doc(group.groupName).set(data);
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
  database
      .collection('groups_normalnie')
      .doc(group.groupName)
      .get()
      .then((value) {
    if (value.exists) {
      database
          .collection('groups_normalnie')
          .doc(group.groupName)
          .collection('folders')
          .get()
          .then((value) async {
        for (var folder in value.docs) {
          if (folder.exists) {
            Folder f = Folder.fromJson(folder.data());
            deleteFolderFromGroup(group, f);
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));
        database.collection('groups_normalnie').doc(group.groupName).delete();
        debugPrint('Group ${group.groupName} was deleted.');
      });
    } else {
      debugPrint('Group ${group.groupName} are not existing.');
    }
  });
}

/// Stream for watching changes into groups' collection.
/// Use it for dynamic rendering Group List.
final Stream<QuerySnapshot> groupsStream =
    FirebaseFirestore.instance.collection('groups_normalnie').snapshots();

final Stream<User?> consumerStream = FirebaseAuth.instance.authStateChanges();

void addFolderInGroup(Group group, Folder folder) {
  var database = FirebaseFirestore.instance;
  var data = folder.toJson();
  database
      .collection('groups_normalnie')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .get()
      .then((value) {
    if (value.exists) {
      debugPrint('Folder ${folder.folderName} is already exist.');
    } else {
      database
          .collection('groups_normalnie')
          .doc(group.groupName)
          .collection('folders')
          .doc(folder.folderName)
          .set(data);
      database
          .collection('groups_normalnie')
          .doc(group.groupName)
          .set(group.toJson(), SetOptions(merge: true));
      debugPrint('Folder ${folder.folderName} was created.');
    }
  });
}

List<Folder> querySnapshotToFoldersList(QuerySnapshot snapshot, Group group) {
  List<Folder> folders = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data['folderName'] != null) {
      folders.add(Folder(
          folderName: data["folderName"], files: [], creator: data['creator']));
    }
  }
  return folders;
}

void deleteFolderFromGroup(Group group, Folder folder) {
  var database = FirebaseFirestore.instance;
  database
      .collection('groups_normalnie')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .get()
      .then((value) async {
    if (value.exists) {
      database
          .collection('groups_normalnie')
          .doc(group.groupName)
          .collection('folders')
          .doc(folder.folderName)
          .collection('files')
          .get()
          .then((value) async {
        for (var file in value.docs) {
          if (file.exists) {
            InnoFile x = InnoFile.fromJson(file.data());
            deleteFileFromFolder(group, folder, x.fileName);
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));
        database
            .collection('groups_normalnie')
            .doc(group.groupName)
            .collection('folders')
            .doc(folder.folderName)
            .delete();
      });
    } else {
      debugPrint('Folder ${folder.folderName} does not exist.');
    }
  });
}

/// Add file to the selected group (if group exists).
Future<void> addFileToFolder(InnoFile innoFile) async {
  Group group = innoFile.parentFolder!.parentGroup!;
  Folder folder = innoFile.parentFolder!;

  dynamic curDoc = await FirebaseFirestore.instance
      .collection('groups_normalnie')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    return;
  }
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('groups_normalnie')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName)
      .collection('files')
      .doc(innoFile.fileName);
  docRef.get().then((value) {
    if (!value.exists) {
      docRef.set(
          InnoFile(
                  fileName: innoFile.fileName,
                  path:
                      '${group.groupName}/${folder.folderName}/${innoFile.fileName}',
                  creator: innoFile.creator)
              .toJson(),
          SetOptions(merge: true));
    }
  });
  final filePool = (await FirebaseStorage.instance
          .ref()
          .child('${group.groupName}/${folder.folderName}/')
          .listAll())
      .items;
  for (var file in filePool) {
    if (file.name == innoFile.fileName) {
      return;
    }
  }
  docRef.update(InnoFile(
          fileName: innoFile.fileName,
          path: '${group.groupName}/${folder.folderName}/${innoFile.fileName}',
          creator: innoFile.creator)
      .toJson());
  final ref = FirebaseStorage.instance
      .ref()
      .child('${group.groupName}/${folder.folderName}/${innoFile.fileName}');
  await ref.putFile(innoFile.realFile!);
}

Future<void> deleteFileFromFolder(
    Group group, Folder folder, String fileName) async {
  final curDoc = await FirebaseFirestore.instance
      .collection('groups_normalnie')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    throw Exception('deleteFileFromFolder: Group does not exist');
  }
  final docRef = FirebaseFirestore.instance
      .collection('groups_normalnie')
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
      .collection('groups_normalnie')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
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
