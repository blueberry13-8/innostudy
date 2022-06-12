import 'package:innostudy/folder.dart';

///Class that represent all information about groups in application
class Group {
  //Name of group
  String groupName;

  //All folders in this group
  List<Folder> folders;

  Group({required this.groupName, required this.folders});
}
