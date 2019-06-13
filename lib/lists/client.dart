//flutter
import 'package:flutter/material.dart';
import 'package:ppscgym/pages/client_detail_page.dart';

//depedencies
import 'package:provider/provider.dart';

//service
import 'package:ppscgym/model.dart';

class ClientList extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

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
            String _lastname=client[index].lastname;
            String name = _firstname.toUpperCase()+' '+_lastname.toUpperCase();

            return Card(
              color: Colors.blue,
              child: FlatButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientDetail(client[index])),
                  );
                },
                child: ListTile(
                    title:Text('$name',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.4,
                        ),
                    ),
                    subtitle: Text(_id,),
                  ),
                ),
            );
          }
        )
        //List Not Available 👇
        :Center(
         child:Column(
           mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.mood_bad,size: 140,color: Colors.black26,),
              Text("Data Not Found",style: TextStyle(color: Colors.black26,fontSize: 20),)
            ],
          )
        );
      }
}
