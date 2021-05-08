import 'package:flutter/material.dart';
import 'package:ppscgym/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PPSC GYM',
        theme: ThemeData(primaryColor: Colors.amber),
        darkTheme: ThemeData.dark(),
        home: HomePage(),
        debugShowCheckedModeBanner: false);
  }
}
