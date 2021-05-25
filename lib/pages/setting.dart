import 'package:flutter/material.dart';
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
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              cardWidget(
                color: Colors.blue,
                icon: Icons.bar_chart,
                title: Text('Customize Plan'),
              )
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
      margin: EdgeInsets.all(20),
      semanticContainer: true,
      child: ListTile(
        onTap: onTap,
        leading: avatarWidget(
          color: color,
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
}
