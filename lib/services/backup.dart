import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:ppscgym/services/database/handler.dart';

import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/styles.dart';

final handler = DatabaseHandler();
final String ext = '.bak';

Future<String?> getBackupFileLocation() async {
  final backupDir = await getExternalStorageDirectory();
  if (backupDir != null) {
    return '${backupDir.path}/ppscgym$ext';
  } else {
    return null;
  }
}

Future<File?> getBackupFile() async {
  final name = await getBackupFileLocation();
  if (name != null) {
    return File(name);
  } else {
    return null;
  }
}

dialog(BuildContext context, Widget child) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: child,
          ),
        ),
      );
    },
  );
}

Future<void> backupDialog(BuildContext context) async {
  final fname = await getBackupFileLocation();
  final children = [
    Icon(
      Icons.backup_rounded,
      size: 80.0,
    ),
    Text(
      'Backup File Location',
      style: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    gapWidget(15.0),
    Container(
      color: (fname == null) ? Colors.red : Colors.green,
      padding: EdgeInsets.all(10.0),
      child: Text(
        (fname == null) ? 'Unable to retrieve backup location.' : fname,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 11.3),
      ),
    ),
    gapWidget(50.0),
    (fname == null)
        ? Container()
        : OutlinedButton(
            child: const Text(
              'Process',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: materialButtonStyle(
              foregroundColor: Colors.blueGrey,
              padding: EdgeInsets.symmetric(horizontal: 65.0, vertical: 12.0),
            ),
            onPressed: () async {
              await takeBackup(context);
              Navigator.pop(context);
            },
          ),
  ];

  return dialog(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    ),
  );
}

Future<void> restoreDialog(BuildContext context) async {
  final fname = await getBackupFileLocation();
  final errorChildren = [
    Icon(
      Icons.backup_rounded,
      size: 80.0,
    ),
    Text(
      'Backup File Not Found',
      style: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    gapWidget(20.0),
    Text(
      'File Searching Location',
      style: TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    gapWidget(10.0),
    Container(
      color: Colors.black54,
      padding: EdgeInsets.all(10.0),
      child: Text(
        (fname == null) ? 'Unable to retrieve backup location.' : fname,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 11.3),
      ),
    ),
    gapWidget(15.0),
  ];

  final operationChildren = [
    Icon(
      Icons.restore,
      size: 80.0,
    ),
    gapWidget(15.0),
    Text(
      'Choose Restore behaviour. This operation affect existing data. '
      "Both restoration operations are behaves same, If no data exists.",
      overflow: TextOverflow.visible,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11.3),
    ),
    gapWidget(50.0),
    OutlinedButton(
      child: const Text(
        'Merge',
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: materialButtonStyle(
        foregroundColor: Colors.blueGrey,
        padding: EdgeInsets.symmetric(horizontal: 65.0, vertical: 12.0),
      ),
      onPressed: () async {
        await restoreBackup(context);
        Navigator.pop(context);
      },
    ),
    gapWidget(10.0),
    OutlinedButton(
      child: const Text(
        'Replace',
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: materialButtonStyle(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black54,
        padding: EdgeInsets.symmetric(horizontal: 65.0, vertical: 12.0),
      ),
      onPressed: () async {
        await restoreBackup(context, replace: true);
        Navigator.pop(context);
      },
    )
  ];

  final file = await getBackupFile();

  return dialog(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: (file == null || !file.existsSync())
          ? errorChildren
          : operationChildren,
    ),
  );
}

wipeDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmDialog(
        buttonText: 'Wipe All Data',
        child: Text(
          "All informations are wiped out permanently "
          'from memory. Type "confirm" to proceed.',
        ),
        onConfirm: () async {
          await handler.wipeDatabase();
          successPopup(context, 'All data wiped out');
          Navigator.pop(context);
        },
      );
    },
  );
}

takeBackup(BuildContext context) async {
  final file = await getBackupFile();
  if (file != null) {
    final String? data = await handler.backup();

    if (data != null) {
      await file.writeAsString(data);
      successPopup(context, 'Backup successfully');
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
      successPopup(context, 'Data restored successfully');
    } else {
      infoPopup(context, 'Unable to find backup file');
    }
  } catch (e) {
    errorPopup(context, e.toString());
  }
}
