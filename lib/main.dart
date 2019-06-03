import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ppscgym/db.dart';
import 'package:ppscgym/model.dart';

import 'package:ppscgym/auth.dart';

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
          primaryColor: Colors.red,
        ),
        //TODO: Remove Banner 👇
        //debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: HeroScreen(),
        ),
      ), 
    );
  }
}

class HeroScreen extends StatelessWidget {
  
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    
    var user = Provider.of<FirebaseUser>(context);
    
    bool loggedIn = user != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[ 
        //IF User Logged In
        if (loggedIn)...[
          RaisedButton(
            child: Text('AddData'),
            onPressed: () => db.createClient('test1',user),
          ),
          RaisedButton(
            child: Text('UpdateData'),
            onPressed: () => db.updateClient('test1',user),
          ),
          RaisedButton(
            child: Text('SignOut'),
            onPressed: () => authSercice.signOut(),
          )
        ],

        //IF User Not Logged In
        if (!loggedIn)...[
          RaisedButton(
            child: Text('SignIn With Google'),
            onPressed: () => authSercice.googleSignIn(),
          )
        ]
      ],
    );
  }
}
