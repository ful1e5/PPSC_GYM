import 'package:flutter/material.dart';

import 'package:ppscgym/services/backup.dart';

import 'package:ppscgym/pages/plans.dart';
import 'package:ppscgym/styles.dart';
import 'package:ppscgym/widgets.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
                onTap: () async {
                  await takeBackup(context);
                },
              ),

              //TODO: Add replace or merge dialog

              cardWidget(
                icon: Icons.settings_backup_restore_rounded,
                title: Text('Restore'),
                onTap: () async {
                  restoreDialog();
                  // await restoreBackup(context);
                },
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

  restoreDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40.0)),
          ),
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(25.0),
              child: restoreDialogView(),
            ),
          ),
        );
      },
    );
  }

  Widget restoreDialogView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
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
          onPressed: () async {},
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
          onPressed: () async {},
        ),
      ],
    );
  }
}
