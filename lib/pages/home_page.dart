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
import 'package:ppscgym/pages/client_detail_page.dart';

//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            StreamProvider<List<Client>>.value( // All children will have access to Client data
              stream: db.streamClient(user),
              child:SearchRoot()
            ),
            
            IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt),
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
          child: Icon(FontAwesomeIcons.userPlus),
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
class SearchRoot extends StatelessWidget {
  const SearchRoot({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var client = Provider.of<List<Client>>(context);
    return IconButton(
      icon: Icon(FontAwesomeIcons.search),
      onPressed: (){
        showSearch(context: context,delegate: SearchClient(client));
      },
    );
  }
}

class SearchClient extends SearchDelegate<Client>{

  final List<Client> data;

  SearchClient(this.data);

  @override
  List<Widget> buildActions(BuildContext context) {

    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          if(query!=''){
            query='';
          }
          else
            close(context, null);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {

    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if(data==null){
      return Center(
        child: Text('No Data',style: TextStyle(color: Colors.white),),
      );
    }

    final result=data.where((n)=>n.name.contains(query.toUpperCase()));

    return Container(
      color: Color.fromRGBO(58, 66, 86, 1.0),
      child: ListView(
        children: result.map<Card>((n)=>
        Card(
          elevation: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6.0),
          child:Container(
            decoration: BoxDecoration(
              color:(n.expiry=='')?
                Color.fromRGBO(64, 75, 96, .9)
                :(DateTime.now().isBefore(DateTime.parse(n.expiry)))
                  ?Color.fromRGBO(64, 75, 96, .9)
                  :Colors.red
            ),
            child: InkWell(
              onTap: (){
                close(context, n);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientDetail(n)),
                );
              },
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                leading: Container(
                  padding: EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.white24))),
                  child: Icon(FontAwesomeIcons.userAlt, color: Colors.white),
                ),
                title:Text(n.name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Icon(Icons.linear_scale, color: Colors.yellowAccent),
                    Text(n.adhar, style: TextStyle(color: Colors.white))
                  ],
                ),
                trailing:Icon(
                  Icons.keyboard_arrow_right, 
                  color: Colors.white, 
                  size: 30.0,
                )
              ),
            ),
          )
        )
        ).toList(),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    if(data==null){
      return Center(
        child: Text('No Data',style: TextStyle(color: Colors.white),),
      );
    }
    
    final result=data.where((n)=>n.name.contains(query.toUpperCase()));

    return Container(
      color: Color.fromRGBO(58, 66, 86, 1.0),
      child: ListView(
        children: result.map<Card>((n)=>
        Card(
          elevation: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6.0),
          child:Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color:(n.expiry=='')?
                Color.fromRGBO(64, 75, 96, .9)
                :(DateTime.now().isBefore(DateTime.parse(n.expiry)))
                  ?Color.fromRGBO(64, 75, 96, .9)
                  :Color.fromRGBO(255,0,0,.75)
            ),
            child: ListTile(
              title: Text(
                n.name,
                style: TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                icon: Icon(Icons.keyboard_arrow_up,color: Colors.white70,),
                onPressed: ()=>query=n.name,
              ),
            ),
          )
        )
        ).toList(),
      ),
    );
  }
  
}