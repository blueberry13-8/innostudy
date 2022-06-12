import 'package:path/path.dart';
import 'package:innostudy/folder.dart';
import 'dart:io';

///The class that represents file in our application
class InnoFile {
  //The file itself
  File realFile;
  //Folder where the file is located
  Folder parentFolder;
  //The name of the file
  String fileName;

  InnoFile({required this.realFile, required this.parentFolder})
      : fileName = basename(realFile.path);
}
