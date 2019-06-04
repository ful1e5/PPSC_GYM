import 'package:flutter/cupertino.dart';
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
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    
    var user = Provider.of<FirebaseUser>(context);
    
    bool loggedIn = user != null;

    if(loggedIn){
      return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: <Widget>[
             FlatButton(
                child:  Text('Logout',
                    style:  TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: ()=>{authSercice.signOut()}
             )
          ],
        ),
        body: Container(
          child: StreamProvider<List<Client>>.value( // All children will have access to Client data
                stream: db.streamClient(user),
                child: ClientList()
              ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          tooltip: 'Add Client',
          onPressed: ()=>db.createClient(user)
          ,
        ),
      );
    }
    if(!loggedIn){
      return Scaffold(
        body: Center(
          child: RaisedButton(
            child: Text('SignIn With Google'),
            onPressed: () => authSercice.googleSignIn(),
          ),
        )
      );
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

class ClientList extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {

    var user = Provider.of<FirebaseUser>(context);
    var client = Provider.of<List<Client>>(context);
    
    return (client==null)?
    Center(child: CircularProgressIndicator())
    :ListView.builder(
        shrinkWrap: true,
        itemCount: client.length,
        itemBuilder: (contex,int index) {
          String _id=client[index].id;
          String _firstname=client[index].firstname;

          return Card(
            color: Colors.orange,
            child: ListTile(
              title: Text(_firstname),
            ),
          );
        }
      );
    }
  }
