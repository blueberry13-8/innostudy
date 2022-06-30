import 'dart:convert';
import 'package:flutter/material.dart';
import 'folder.dart';

///Class that represent all information about groups in application
class Group {
  //Name of group
  String groupName;
  String creator = 'undefined';

  //All folders in this group
  List<Folder> folders;

  Group(
      {required this.groupName, required this.folders, required this.creator}) {
    for (var folder in folders) {
      folder.parentGroup = this;
    }
  }

  factory Group.fromJson(Map<String, dynamic> loadedJson) {
    debugPrint("!");
    List<Folder> groupFolders = [];
    List<dynamic> notParsed = loadedJson["folders"];
    debugPrint("!");
    for (int i = 0; i < notParsed.length; i++) {
      groupFolders.add(Folder.fromJson(json
          .decode(notParsed[i]))); // serious thing think a lot in future on it
    }

    return Group(
        groupName: loadedJson['groupName'],
        folders: groupFolders,
        creator: loadedJson['creator']);
  }

  Map<String, dynamic> toJson() {
    List<String> notParsed = [];

    for (int i = 0; i < notParsed.length; i++) {
      notParsed.add(json.encode(folders[i].toJson()));
    }

    return {
      'groupName': groupName,
      'folders': notParsed,
      'creator': creator,
    };
  }
}
