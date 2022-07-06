import 'dart:io';

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
  String description = "undefined";

  InnoFile(
      {this.realFile,
      required this.fileName,
      required this.creator,
      this.parentFolder,
      this.description = 'undefined'});

  factory InnoFile.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('description') == false) {
      json['description'] = 'undefined';
    }
    return InnoFile(
        fileName: json['fileName'],
        creator: json['creator'],
        description: json['description']);
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'creator': creator,
      'description': description
    };
  }
}
