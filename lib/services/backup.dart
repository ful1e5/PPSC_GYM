import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:ppscgym/services/database/handler.dart';

import 'package:ppscgym/widgets.dart';

final handler = DatabaseHandler();

Future<File?> getBackupFile() async {
  final String ext = '.bak';
  final backupDir = await getExternalStorageDirectory();
  if (backupDir != null) {
    return File('${backupDir.path}/ppscgym$ext');
  } else {
    return null;
  }
}

takeBackup(BuildContext context) async {
  final file = await getBackupFile();
  if (file != null) {
    final String? data = await handler.backup();

    if (data != null) {
      await file.writeAsString(data);
      successPopup(context, 'Data Exported at $file');
    } else {
      infoPopup(context, 'Nothing to Backup');
    }
  } else {
    errorPopup(context, 'Unable to retrieve backup directory');
  }
}

restoreBackup(BuildContext context, {bool replace = false}) async {
  final file = await getBackupFile();
  try {
    if (file == null) {
      throw Exception('Unable to retrieve backup directory');
    }
    if (await file.exists()) {
      final jsonData = await file.readAsString(encoding: utf8);
      await handler.restoreBackup(jsonData, replace);
      successPopup(context, 'data imported');
    } else {
      infoPopup(context, 'Unable to find backup file');
    }
  } catch (e) {
    errorPopup(context, e.toString());
  }
}
