import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'folder.dart';
import 'group.dart';

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

List<Folder> querySnapshotToFoldersList(QuerySnapshot snapshot) {
  List<Folder> folders = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    if (data['folderName'] != null) {
      folders.add(Folder(folderName: data["folderName"], files: data['files']));
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
void addFileToGroup(Group group, String filePath) {
  //final file = File(filePath);
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
