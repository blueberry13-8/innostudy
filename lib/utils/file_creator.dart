import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:path/path.dart';
import 'package:work/core/group.dart';
import 'package:work/core/inno_file.dart';
import 'dart:io' show File, Platform;

import '../core/folder.dart';
import '../firebase/additional_firebase_functions.dart';

Future<void> createInnoFile(Group group, List<Folder> path) async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result == null) return;
  if (kIsWeb) {
    debugPrint("Uploading file on browser...");
    for (PlatformFile file in result.files) {
      InnoFile innoFile = InnoFile(
          fileName: basename(file.name),
          creator: FirebaseAuth.instance.currentUser!.email!);
      await addFileToFolderNEWByBytes(group, path, innoFile, file.bytes!);
    }
  } else if (Platform.isAndroid) {
    debugPrint("Uploading file on Android...");
    for (PlatformFile file in result.files) {
      InnoFile innoFile = InnoFile(
          realFile: File(file.path!),
          fileName: basename(file.path!),
          creator: FirebaseAuth.instance.currentUser!.email!);
      await addFileToFolderNEW(group, path, innoFile);
      innoFile.parentFolder = path.last;
    }
  }
}
