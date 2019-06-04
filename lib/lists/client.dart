//flutter
import 'package:flutter/material.dart';

//depedencies
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ppscgym/pages/client_detail_page.dart';
import 'package:provider/provider.dart';

//service
import 'package:ppscgym/model.dart';

class ClientList extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    var user = Provider.of<FirebaseUser>(context);
    var client = Provider.of<List<Client>>(context);
    
    return (client==null)?
    //Data is not Available👇
    Center(child: CircularProgressIndicator())
    //Data Available 👇
    :(client.length>0)?
      
      //List Available 👇
      ListView.builder(
          shrinkWrap: true,
          itemCount: client.length,
          itemBuilder: (contex,int index) {
           
            String _id=client[index].id;
            String _firstname=client[index].firstname;

            return Card(
              color: Colors.orange,
              child: ListTile(
                //push context to ClientDetail Page
                onTap: ()=>{},
                title: Text(_firstname),
                subtitle: Text(_id),
              ),
            );
          }
        )
        //List Not Available 👇
        :Center(child: Text('No record found'));
      }
}
