import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/widgets.dart';

final String ext = '.bak';
final String sep = '\n\n';

Future<String?> backup() async {
  final handler = DatabaseHandler();
  return await handler.backup(sep);
}

Future<void> resBackup(String jsonData) async {
  final handler = DatabaseHandler();
  await handler.restoreBackup(jsonData);
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
  final dir = await getBackupDir();
  if (dir != null) {
    final file = File('$dir/ppscgym$ext');
    final String? data = await backup();

    if (data != null) {
      await file.writeAsString(data);
      successPopup(context, 'Data Exported at $dir');
    } else {
      infoPopup(context, 'Nothing to Backup');
    }
  } else {
    errorPopup(context, 'Unable to retrieve backup directory');
  }
}

restoreBackup(BuildContext context) async {
  final backupDir = await getBackupDir();
  try {
    if (backupDir == null) {
      throw Exception('Unable to retrieve backup directory');
    }

    final backupFile = File('$backupDir/ppscgym$ext');
    if (await backupFile.exists()) {
      final jsonData = await backupFile.readAsString(encoding: utf8);

      resBackup(jsonData);
      successPopup(context, 'data imported');
    } else {
      infoPopup(context, 'Unable to find backup file');
    }
  } catch (e) {
    errorPopup(context, e.toString());
  }
}
