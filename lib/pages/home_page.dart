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

//Form Pages
import 'package:ppscgym/pages/clientForm.dart';


class HomePage extends StatelessWidget {

  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          title: Text('Home'),
          actions: <Widget>[
             IconButton(
                icon: Icon(Icons.exit_to_app),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClientFormPage()),
            );
          }
        ),
      );
  }
}