import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ppscgym/services/database/handler.dart';

import 'package:ppscgym/widgets.dart';

final String ext = '.ppbak';

Future<String?> backup() async {
  final handler = DatabaseHandler();
  return await handler.backup();
}

takeBackup(BuildContext context) async {
  String? backupDir = await FilePicker.platform.getDirectoryPath();

  if (backupDir != null) {
    final file = File('$backupDir/ppscgym$ext');
    final String? csvData = await backup();
    if (csvData != null) {
      file.writeAsString(csvData);
    } else {
      errorPopup(context, 'Backup Error');
    }
  }
}
