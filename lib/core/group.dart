import 'dart:convert';
import 'package:work/permission_system/permissions_entity.dart';

import 'folder.dart';

///Class that represent all information about groups in application
class Group {
  //Name of group
  String groupName;
  String creator = 'undefined';
  String description = 'undefined';

  //Permissions
  late PermissionEntity permissions;

  //All folders in this group
  List<Folder> folders;

  Group(
      {required this.groupName,
      required this.folders,
      required this.creator,
      this.description = 'undefined'}) {
    for (var folder in folders) {
      folder.parentGroup = this;
    }
  }

  factory Group.fromJson(Map<String, dynamic> loadedJson) {
    List<Folder> groupFolders = [];
    List<dynamic> notParsed = loadedJson["folders"];
    for (int i = 0; i < notParsed.length; i++) {
      groupFolders.add(Folder.fromJson(json
          .decode(notParsed[i]))); // serious thing think a lot in future on it
    }
    if (loadedJson.containsKey('description') == false) {
      loadedJson['description'] = 'undefined';
    }
    return Group(
        groupName: loadedJson['groupName'],
        folders: groupFolders,
        creator: loadedJson['creator'],
        description: loadedJson['description']);
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
      'description': description,
    };
  }
}
