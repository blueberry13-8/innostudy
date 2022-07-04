//This module helps to understand the system which rights current user have

import 'package:firebase_auth/firebase_auth.dart';
import 'package:work/core/folder.dart';
import 'package:work/core/group.dart';
import 'package:work/core/inno_file.dart';
import 'package:work/permission_system/permission_object.dart';

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

RightsEntity getDefaultRights() {
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

RightsEntity checkRightsForGroup(Group group) {
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

  if (group.permissions.owners.contains(userEmail) ||
      group.permissions.allowAll) {
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

RightsEntity checkRightsForFolder(Folder folder) {
  String userEmail = FirebaseAuth.instance.currentUser!.email!;

  RightsEntity upperRights = getDefaultRights();

  if (folder.parentFolder != null) {
    upperRights = checkRightsForFolder(folder.parentFolder!);
    print(folder.folderName);
  } else if (folder.parentGroup != null) {
    upperRights = checkRightsForGroup(folder.parentGroup!);
  } else {
    throw Exception("Impossible situation");
  }

  if (folder.creator == userEmail) {
    upperRights.addFiles = true;
    upperRights.openFoldersSettings = true;
    upperRights.deleteFiles = true;
  }

  if (folder.permissions.owners.contains(userEmail) ||
      folder.permissions.allowAll) {
    upperRights.addFiles = true;
    if (folder.withFolders) {
      upperRights.addFolders = true;
    }
  }

  return upperRights;
}

RightsEntity checkRightsForFile(InnoFile innoFile) {
  String userEmail = FirebaseAuth.instance.currentUser!.email!;

  RightsEntity upperRights = checkRightsForFolder(innoFile.parentFolder!);

  if (innoFile.creator == userEmail) {
    upperRights.openFileSettings = true;
  }

  return upperRights;
}
