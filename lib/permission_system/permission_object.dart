import 'package:work/folder.dart';
import 'package:work/group.dart';
import 'package:work/inno_file.dart';

enum PermissionableType { group, folder, file }

class PermissionableObject {
  Group? _group;
  Folder? _folder;
  InnoFile? _innoFile;

  PermissionableType type;

  PermissionableObject.fromGroup(this._group) : type = PermissionableType.group;

  PermissionableObject.fromFolder(this._folder)
      : type = PermissionableType.folder;

  PermissionableObject.fromInnoFile(this._innoFile)
      : type = PermissionableType.file;

  Group getGroup() {
    if (_group != null) {
      return _group!;
    }
    throw Exception("This permissionable object is NOT for group!");
  }

  Folder getFolder() {
    if (_folder != null) {
      return _folder!;
    }
    throw Exception("This permissionable object is NOT for folder!");
  }

  InnoFile getFile() {
    if (_innoFile != null) {
      return _innoFile!;
    }
    throw Exception("This permissionable object is NOT for file!");
  }
}
