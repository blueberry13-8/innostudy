import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'group.dart';

/// Add group to the DB if it doesn't exist.
void addGroup(Group group) {
  final data = {"groupName": group.groupName};
  var database = FirebaseFirestore.instance;
  database.collection('groups').doc(group.groupName).get().then((value) {
    if (value.exists) {
      debugPrint('Group with name - ${group.groupName} exists.');
    } else {
      database.collection('groups').doc(group.groupName).set(data);
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

/// Add file to the selected group (if group exists).
void addFileToGroup(Group group, String filePath) {
  //final file = File(filePath);
}

List<Group> querySnapshotToGroupList(QuerySnapshot snapshot) {
  List<Group> groups = [];
  for (var document in snapshot.docs) {
    var data = document.data()! as Map<String, dynamic>;
    groups.add(Group(groupName: data["groupName"]));
  }
  return groups;
}
