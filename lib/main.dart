import 'package:flutter/material.dart';

void main() => ({MyApp()});

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPSC GYM',
      theme :ThemeData(
        primarySwatch: Colors.red,
        hintColor: Colors.white,
        primaryColor: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
