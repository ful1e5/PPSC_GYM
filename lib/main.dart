import 'package:flutter/material.dart';
import 'package:ppscgym/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPSC GYM',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
