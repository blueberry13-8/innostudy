import 'package:innostudy/group.dart';
import 'inno_file.dart';

///Class that represent all information about folder in application
class Folder {
  //All files in folder
  List<InnoFile> files;
  //Group where the folder is located
  Group? parentGroup;
  //The name of the folder
  String folderName;

  Folder(
      {required this.folderName,
      required this.files, Group? parentGroup}){
    this.parentGroup = parentGroup!;
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      folderName: json['folderName'],
      files: json['files'],
    );
  }

  Map<String, dynamic> toJson() { // 2
    return {
      'folderName': folderName,
      'files': files,
    };
  }
}
