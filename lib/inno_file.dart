import 'package:innostudy/folder.dart';
import 'dart:io';

///The class that represents file in our application
class InnoFile {
  //The file itself
  File? realFile;
  //Folder where the file is located
  Folder? parentFolder;
  //The name of the file
  String fileName;

  InnoFile({this.realFile, this.parentFolder, required this.fileName});

  factory InnoFile.fromJson(Map<String, dynamic> json) {
    return InnoFile(
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    // 2
    return {
      'fileName': fileName,
    };
  }
}
