import 'package:work/core/folder.dart';
import 'package:work/core/group.dart';
import 'package:work/core/inno_file.dart';

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

  String getCreator() {
    if (type == PermissionableType.file) {
      return _innoFile!.creator;
    } else if (type == PermissionableType.folder) {
      return _folder!.creator;
    } else if (type == PermissionableType.group) {
      return _group!.creator;
    }
    throw Exception("Impossible situation");
  }

  String getName() {
    if (type == PermissionableType.file) {
      return _innoFile!.fileName;
    } else if (type == PermissionableType.folder) {
      return _folder!.folderName;
    } else if (type == PermissionableType.group) {
      return _group!.groupName;
    }
    throw Exception("Impossible situation");
  }

  String getDescription() {
    if (type == PermissionableType.file) {
      return _innoFile!.description;
    } else if (type == PermissionableType.folder) {
      return _folder!.description;
    } else if (type == PermissionableType.group) {
      return _group!.description;
    }
    throw Exception("Impossible situation");
  }
}
