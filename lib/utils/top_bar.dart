import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final double height;
  final String header;
  final Color startColor;
  final Color endColor;

  const TopBar({Key key, this.height, this.header, this.startColor, this.endColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [startColor, endColor],
            ),
          ),
          height: height,
        ),
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            header,
            style: TextStyle(fontFamily: 'Relaway', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}