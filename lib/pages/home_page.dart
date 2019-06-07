//flutter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//depedencies
import 'package:provider/provider.dart';

//services
import 'package:ppscgym/model.dart';
import 'package:ppscgym/auth.dart';
import 'package:ppscgym/db.dart';

//lists
import 'package:ppscgym/lists/client.dart';

//pages
import 'package:ppscgym/pages/form.dart';


class HomePage extends StatelessWidget {

  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
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
        
        //Show List Of Client 👇
        body: Container(
          child: StreamProvider<List<Client>>.value( // All children will have access to Client data
                stream: db.streamClient(user),
                child: ClientList()
              ),
        ),

        //FAB For Add Client 
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: 'Add Client',
          onPressed: (){
            db.createClient(user);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FormPage()),
            );
          }
        ),
      );
  }
}