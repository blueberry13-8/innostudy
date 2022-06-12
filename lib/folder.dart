import 'package:innostudy/group.dart';
import 'inno_file.dart';

///Class that represent all information about folder in application
class Folder {
  //All files in folder
  List<InnoFile> files;
  //Group where the folder is located
  Group parentGroup;
  //The name of the folder
  String folderName;

  Folder(
      {required this.folderName,
      required this.parentGroup,
      required this.files});
}
