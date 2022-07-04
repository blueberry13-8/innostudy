import 'dart:io';

import 'package:work/permission_system/permissions_entity.dart';

import 'folder.dart';

///The class that represents file in our application
class InnoFile {
  //The file itself
  File? realFile;

  //Folder where the file is located
  Folder? parentFolder;

  //The name of the file
  String fileName;

  //The creator of file
  String creator = "undefined";

  //Path in the Storage to the file
  String path;

  InnoFile(
      {this.realFile,
      required this.fileName,
      required this.path,
      required this.creator,
      this.parentFolder});

  factory InnoFile.fromJson(Map<String, dynamic> json) {
    return InnoFile(
        fileName: json['fileName'],
        path: json['path'],
        creator: json['creator']);
  }

  Map<String, dynamic> toJson() {
    return {'fileName': fileName, 'path': path, 'creator': creator};
  }
}
