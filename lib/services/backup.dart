import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ppscgym/services/database/handler.dart';

import 'package:ppscgym/widgets.dart';

final String ext = '.bak';

Future<String?> backup() async {
  final handler = DatabaseHandler();
  return await handler.backup();
}

Future<String?> getBackupDir() async {
  final backupDir = await getExternalStorageDirectory();
  if (backupDir != null) {
    return backupDir.path;
  } else {
    return null;
  }
}

takeBackup(BuildContext context) async {
  final backupDir = await getBackupDir();
  if (backupDir != null) {
    final bacupFilePath = File('$backupDir/ppscgym$ext');
    final String? csvData = await backup();
    if (csvData != null) {
      await bacupFilePath.writeAsString(csvData);
      successPopup(context, 'Data Exported at $backupDir');
    } else {
      successPopup(context, 'Nothing to Backup');
    }
  } else {
    errorPopup(context, 'Unable to retrieve backup directory');
  }
}
