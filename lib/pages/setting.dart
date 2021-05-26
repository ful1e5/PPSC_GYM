import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:ppscgym/services/database/handler.dart';

import 'package:ppscgym/pages/plans.dart';
import 'package:ppscgym/widgets.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<String?> backup() async {
    final handler = DatabaseHandler();
    return await handler.backup();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text('Settings'),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              sectionTag(tag: 'Plan'),
              cardWidget(
                icon: Icons.bar_chart,
                title: Text('Customize Plan'),
                onTap: gotoPlanPage,
              ),
              sectionTag(tag: 'Backup'),
              cardWidget(
                icon: Icons.backup_rounded,
                title: Text('Backup'),
                onTap: takeBackup,
              ),
              cardWidget(
                icon: Icons.settings_backup_restore_rounded,
                title: Text('Restore'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  cardWidget({
    GestureTapCallback? onTap,
    Color? color,
    Color? iconColor,
    IconData? icon,
    Widget? title,
  }) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      semanticContainer: true,
      child: ListTile(
        onTap: onTap,
        leading: avatarWidget(
          color: color ?? Colors.blue,
          child: Icon(
            icon,
            size: 25,
            color: iconColor,
          ),
        ),
        title: title,
      ),
    );
  }

  Widget sectionTag({String? tag}) {
    return Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 5.0),
      child: Text(
        tag ?? "Tag",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  gotoPlanPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlansPage()),
    );
  }

  takeBackup() async {
    String? backupDir = await FilePicker.platform.getDirectoryPath();

    if (backupDir != null) {
      final String? csvData = await backup();
      print(csvData);
      print(backupDir);
    }
  }
}
