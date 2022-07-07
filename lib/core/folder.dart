import 'dart:convert';
import 'group.dart';
import 'inno_file.dart';
import '../permission_system/permissions_entity.dart';

///Class that represent all information about folder in application
class Folder {
  //Flag for folder with folders
  bool withFolders = false;

  //List for folders
  List<Folder>? folders;

  //All files in folder
  List<InnoFile>? files;

  //Group where the folder is located
  Group? parentGroup;

  //Folder where the folder is located
  Folder? parentFolder;

//The folder creator
  String creator = "undefined";

  //The name of the folder
  String folderName;

  String description = '';

  //Folder permissions
  late PermissionEntity permissions;

  Folder(
      {required this.folderName,
      this.files,
      this.parentGroup,
      this.folders,
      required this.withFolders,
      this.parentFolder,
      required this.creator,
      this.description = ''}) {
    if (!withFolders) {
      for (var file in files!) {
        file.parentFolder = this;
      }
    } else {
      for (var folder in folders!) {
        folder.parentFolder = this;
      }
    }
  }

  factory Folder.fromJson(Map<String, dynamic> loadedJson) {
    bool nested = loadedJson['withFolders'];
    if (loadedJson.containsKey('description') == false) {
      loadedJson['description'] = '';
    }
    if (!nested) {
      List<InnoFile> innoFiles = [];
      List<dynamic> notParsed = loadedJson["files"];

      for (int i = 0; i < notParsed.length; i++) {
        innoFiles.add(InnoFile.fromJson(json.decode(notParsed[i])));
      }
      return Folder(
          folderName: loadedJson['folderName'],
          files: innoFiles,
          withFolders: loadedJson['withFolders'],
          creator: loadedJson['creator'],
          description: loadedJson['description']);
    } else {
      List<Folder> folders = [];
      List<dynamic> notParsed = loadedJson["folders"];

      for (int i = 0; i < notParsed.length; i++) {
        folders.add(Folder.fromJson(json.decode(notParsed[i])));
      }
      return Folder(
          folderName: loadedJson['folderName'],
          folders: folders,
          withFolders: loadedJson['withFolders'],
          creator: loadedJson['creator'],
          description: loadedJson['description']);
    }
  }

  Map<String, dynamic> toJson() {
    List<String> notParsed = [];

    if (!withFolders) {
      for (int i = 0; i < files!.length; i++) {
        notParsed.add(json.encode(files![i].toJson()));
      }
      return {
        'folderName': folderName,
        'files': notParsed,
        'withFolders': withFolders,
        'creator': creator,
        'description': description,
      };
    } else {
      for (int i = 0; i < folders!.length; i++) {
        notParsed.add(json.encode(folders![i].toJson()));
      }
      return {
        'folderName': folderName,
        'folders': notParsed,
        'withFolders': withFolders,
        'creator': creator,
        'description': description,
      };
    }
  }
}
