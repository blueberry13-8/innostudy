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

  //Path in the Storage to the file
  String path;

  InnoFile(
      {this.realFile,
      required this.fileName,
      required this.path,
      this.parentFolder});

  factory InnoFile.fromJson(Map<String, dynamic> json) {
    return InnoFile(
      fileName: json['fileName'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'path': path,
    };
  }
}
