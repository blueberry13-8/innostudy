//This module helps to understand the system which rights current user have

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work/folder.dart';
import 'package:work/group.dart';
import 'package:work/inno_file.dart';
import 'package:work/permission_system/permissions_entity.dart';
import 'package:work/permission_system/permissions_functions.dart';

///Class contains the rights that user have
class RightsEntity {
  bool deleteFiles;
  bool deleteFolders;
  bool addFiles;
  bool addFolders;
  bool seeFolders;
  bool seeFiles;
  bool openGroupSettings;
  bool openFoldersSettings;
  bool openFileSettings;

  RightsEntity({
    required this.deleteFiles,
    required this.deleteFolders,
    required this.addFiles,
    required this.addFolders,
    required this.seeFiles,
    required this.seeFolders,
    required this.openGroupSettings,
    required this.openFoldersSettings,
    required this.openFileSettings,
  });
}

RightsEntity checkRightsForGroup(
    Group group, PermissionEntity permissionEntity) {
  String userEmail = FirebaseAuth.instance.currentUser!.email!;

  if (group.creator == userEmail) {
    return RightsEntity(
        deleteFiles: true,
        deleteFolders: true,
        addFiles: true,
        addFolders: true,
        seeFiles: true,
        seeFolders: true,
        openGroupSettings: true,
        openFoldersSettings: true,
        openFileSettings: true);
  }

  if (permissionEntity.owners.contains(userEmail) ||
      permissionEntity.allowAll) {
    return RightsEntity(
        deleteFiles: false,
        deleteFolders: false,
        addFiles: true,
        addFolders: true,
        seeFiles: true,
        seeFolders: true,
        openGroupSettings: false,
        openFoldersSettings: false,
        openFileSettings: false);
  }

  return RightsEntity(
      deleteFiles: false,
      deleteFolders: false,
      addFiles: false,
      addFolders: false,
      seeFiles: true,
      seeFolders: true,
      openGroupSettings: false,
      openFoldersSettings: false,
      openFileSettings: false);
}

RightsEntity checkRightsForFolder(Folder folder,
    PermissionEntity permissionEntity, PermissionEntity permissionEntityGroup) {
  String userEmail = FirebaseAuth.instance.currentUser!.email!;
  RightsEntity upperRights =
      checkRightsForGroup(folder.parentGroup!, permissionEntityGroup);

  if (folder.creator == userEmail) {
    upperRights.addFiles = true;
    upperRights.openFoldersSettings = true;
    upperRights.deleteFiles = true;
  }

  if (permissionEntity.owners.contains(userEmail) ||
      permissionEntity.allowAll) {
    upperRights.addFiles = true;
  }

  return upperRights;
}

RightsEntity checkRightsForFile(
    InnoFile innoFile,
    PermissionEntity permissionEntityFolder,
    PermissionEntity permissionEntityGroup) {
  String userEmail = FirebaseAuth.instance.currentUser!.email!;

  RightsEntity upperRights = checkRightsForFolder(
      innoFile.parentFolder!, permissionEntityFolder, permissionEntityGroup);

  if (innoFile.creator == userEmail) {
    upperRights.openFileSettings = true;
  }

  return upperRights;
}
