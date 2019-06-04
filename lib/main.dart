//flutter
import 'package:flutter/material.dart';

//depedencies
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Pages
import 'package:ppscgym/pages/home_page.dart';
import 'package:ppscgym/pages/login_page.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      
      providers: [

        StreamProvider<FirebaseUser>.value(
          stream: FirebaseAuth.instance.onAuthStateChanged
        ),

        //StreamProvider<Client>.value(stream: firestoreStream),
      ],
      
      child: MaterialApp(
        title: 'PPSC GYM',
        theme :ThemeData(
          brightness: Brightness.dark,
        ),
        //TODO: Remove Banner 👇
        //debugShowCheckedModeBanner: false,
        home: RootScreen()
      ), 
    );
  }
}

class RootScreen extends StatelessWidget {
  
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    
    var user = Provider.of<FirebaseUser>(context);
    
    bool loggedIn = user != null;

    //User Is Logged In
    if(loggedIn){
      return HomePage();
    }
    //User Not LoggedIn
    if(!loggedIn){
      //Loging Page 
      return LoginPage();
    }
    
    // RaisedButton(
    //   child: Text('AddData'),
    //   onPressed: () => db.createClient(user),
    // ),
    // // RaisedButton(
    // //   child: Text('UpdateData'),
    // //   onPressed: () => db.updateClient(user),
  }
}
