import 'dart:convert';
import 'group.dart';
import 'inno_file.dart';

///Class that represent all information about folder in application
class Folder {
  //All files in folder
  List<InnoFile> files;

  //Group where the folder is located
  Group? parentGroup;

  //The name of the folder
  String folderName;

  Folder({required this.folderName, required this.files, this.parentGroup}) {
    for (var file in files) {
      file.parentFolder = this;
    }
  }

  factory Folder.fromJson(Map<String, dynamic> loadedJson) {
    List<InnoFile> innoFiles = [];
    List<dynamic> notParsed = loadedJson["files"];

    for (int i = 0; i < notParsed.length; i++) {
      innoFiles.add(InnoFile.fromJson(json.decode(notParsed[i])));
    }
    return Folder(
      folderName: loadedJson['folderName'],
      files: innoFiles,
    );
  }

  Map<String, dynamic> toJson() {
    List<String> notParsed = [];

    for (int i = 0; i < notParsed.length; i++) {
      notParsed.add(json.encode(files[i].toJson()));
    }
    return {
      'folderName': folderName,
      'files': notParsed,
    };
  }
}
