import 'package:flutter/material.dart';
import 'package:ppscgym/services/authentication.dart';
import 'package:ppscgym/Pages/root_page.dart';
import 'package:ppscgym/services/connection_status_singleton.dart';

void main() {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(MyApp());
  }

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPSC GYM',
      theme :ThemeData(
        primarySwatch: Colors.red,
        hintColor: Colors.white,
        primaryColor: Colors.red,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.white
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
      home: RootPage(auth: Auth())
    );
  }
}
