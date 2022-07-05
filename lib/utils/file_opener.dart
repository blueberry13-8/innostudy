import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:open_file/open_file.dart';
import 'package:work/core/group.dart';
import 'dart:io' show Platform;
// ignore: avoid_web_libraries_in_flutter
import 'package:universal_html/html.dart' as html;

import 'package:work/core/inno_file.dart';

import '../core/folder.dart';
import '../firebase/additional_firebase_functions.dart';

void openInnoFile(InnoFile innoFile, List<Folder> path, Group group) async {
  if (kIsWeb) {
    debugPrint("Openning file on browser...");
    String url =
        await getFromStorageNEWByDownloadLink(group, path, innoFile.fileName);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = innoFile.fileName;
    html.document.body?.children.add(anchor);

    // download
    anchor.click();

    // cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  } else if (Platform.isAndroid) {
    debugPrint("Openning file on Android...");
    OpenFile.open(
        (await getFromStorageNEW(group, path, innoFile.fileName)).path);
  }
}
