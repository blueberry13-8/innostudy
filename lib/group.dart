import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:innostudy/folder.dart';

///Class that represent all information about groups in application
class Group {
  //Name of group
  String groupName;

  //All folders in this group
  List<Folder> folders;

  Group({required this.groupName, required this.folders});

  factory Group.fromJson(Map<String, dynamic> loaded_json) {
    debugPrint("!");
    List<Folder> groupFolders = [];
    List<dynamic> notParsed = loaded_json["folders"];
    debugPrint("!");
    for (int i = 0; i < notParsed.length; i++) {
      groupFolders.add(Folder.fromJson(json.decode(notParsed[i])));
    }

    return Group(
      groupName: loaded_json['groupName'],
      folders: groupFolders,
    );
  }

  Map<String, dynamic> toJson() {
    List<String> notParsed = [];

    for (int i = 0; i < notParsed.length; i++) {
      notParsed.add(json.encode(folders[i].toJson()));
    }

    return {
      'groupName': groupName,
      'folders': notParsed,
    };
  }
}
