import 'package:flutter/material.dart';

import 'package:ppscgym/services/backup.dart';

import 'package:ppscgym/pages/plans.dart';
import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/info.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                await backupDialog(context);
              },
            ),
            cardWidget(
              icon: Icons.settings_backup_restore_rounded,
              title: Text('Restore'),
              onTap: () async {
                await restoreDialog(context);
              },
            ),
            sectionTag(tag: 'About'),
            cardWidget(
              icon: Icons.pageview_sharp,
              title: Text('License'),
              onTap: gotoLicensePage,
            ),
            cardWidget(
              icon: Icons.info_rounded,
              title: Text('Info'),
              onTap: gotoAboutPage,
            ),
          ],
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

  gotoLicensePage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => InfoPage(title: 'Licence', text: license)),
    );
  }

  gotoAboutPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => InfoPage(title: 'About', text: aboutApp)),
    );
  }
}

class InfoPage extends StatelessWidget {
  final String title;
  final String text;
  const InfoPage({Key? key, required this.title, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Text(text),
        ),
      ),
    );
  }
}
