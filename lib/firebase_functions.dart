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
      database
          .collection('groups')
          .doc(group.groupName)
          .collection('folders')
          .get()
          .then((value) {
        for (var folder in value.docs) {
          if (folder.exists) {
            Folder f = Folder.fromJson(folder.data());
            deleteFolderFromGroup(group, f);
          }
        }
        database.collection('groups').doc(group.groupName).delete();
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
    FirebaseFirestore.instance.collection('groups').snapshots();

final Stream<User?> consumerStream = FirebaseAuth.instance
    .authStateChanges();


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
      debugPrint('Folder ${folder.folderName} is already exist.');
    } else {
      database
          .collection('groups')
          .doc(group.groupName)
          .collection('folders')
          .doc(folder.folderName)
          .set(data);
      database.collection('groups').doc(group.groupName).set(group.toJson());
      debugPrint('Folder ${folder.folderName} was created.');
    }
  });
}

dynamicToPath(List<dynamic> paths) {
  List<InnoFile> correctPaths = [];
  for (String path in paths) {
    path = path.split('/')[path.split('/').length - 1];
    correctPaths.add(InnoFile(fileName: path));
  }
  return correctPaths;
}

List<Folder> querySnapshotToFoldersList(QuerySnapshot snapshot, Group group) {
  List<Folder> folders = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data['folderName'] != null) {
      folders.add(Folder(
          folderName: data["folderName"],
          files: dynamicToPath(
            data['files'],
          ),
          parentGroup: group));
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
      .then((value) async {
    if (value.exists) {
      List<dynamic> files = value.data()!['files'];
      for (String x in files){
        debugPrint('$x         *******************************************');
        deleteFileFromFolder(group, folder, x.toString().replaceAll('files/', ''));
      }
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        database
            .collection('groups')
            .doc(group.groupName)
            .collection('folders')
            .doc(folder.folderName)
            .delete();
        debugPrint('Folder ${folder.folderName} was deleted.');
      });
    } else {
      debugPrint('Folder ${folder.folderName} does not exist.');
    }
  });
}

/// Add file to the selected group (if group exists).
Future<void> addFileToFolder(
    Group? group, Folder folder, String filePath, String name) async {
  if (group == null) {
    throw Exception('addFileToGroup: group is null');
  }
  dynamic curDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    throw Exception('addFileToGroup: Group does not exist');
  }
  DocumentReference docRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName);

  final filePool =
      (await FirebaseStorage.instance.ref().child('files/').listAll()).items;
  for (var file in filePool) {
    if (file.name == name) {
      throw Exception('addFileToGroup: File with such name already exists');
    }
  }
  docRef.update({
    'files': FieldValue.arrayUnion(['files/$name'])
  });
  final ref = FirebaseStorage.instance.ref().child('files/$name');
  final file = File(filePath);
  await ref.putFile(file);
}

Future<void> deleteFileFromFolder(
    Group? group, Folder folder, String fileName) async {
  if (group == null) {
    throw Exception('addFileToGroup: group is null');
  }
  final curDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    throw Exception('addFileToGroup: Group does not exist');
  }
  final docRef = FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .collection('folders')
      .doc(folder.folderName); // it's folders, not files
  docRef.update({
    'files': FieldValue.arrayRemove(['files/$fileName'])
  });
  final ref = FirebaseStorage.instance.ref().child('files/$fileName');
  ref.delete();
}

Future<File> getFromStorage(Group? group, Folder folder, String name) async {
  if (group == null) {
    throw Exception('addFileToGroup: group is null');
  }
  dynamic curDoc = await FirebaseFirestore.instance
      .collection('groups')
      .doc(group.groupName)
      .get();

  if (curDoc.exists == false) {
    throw Exception('addFileToGroup: Group does not exist');
  }
  final ref = FirebaseStorage.instance.ref().child('files/$name');
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
