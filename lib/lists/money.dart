//flutter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ppscgym/pages/moneyForm.dart';

//depedencies
import 'package:provider/provider.dart';

//service
import 'package:ppscgym/model.dart';
import 'package:ppscgym/db.dart';

class MoneyList extends StatelessWidget {


  final String clientId;
  MoneyList(this.clientId);

  //For Operation
  final db =DatabaseService();  
  @override
  Widget build(BuildContext context) {

    var money = Provider.of<List<Money>>(context);
    var user = Provider.of<FirebaseUser>(context);


    return (money==null)?
    //Data is not Available👇
    Center(child: CircularProgressIndicator())
    //Data Available 👇
    :(money.length>0)?
      
        //List Available 👇
    
        ListView.builder(
          shrinkWrap: true,
          itemCount: money.length,
          itemBuilder: (contex,int index) {
            String _id=money[index].id;
            String _money=money[index].money;

            return Card(
              color: Colors.blue,
              child: Dismissible(
                key: Key(_id),
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.0),
                  color: Colors.orange,
                  child: Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: Icon(Icons.delete_forever, color: Colors.white),
                ),
                onDismissed: (direction){
                  if(direction == DismissDirection.endToStart){
                    db.deleteMoney(clientId, _id, user);
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Money Entry Deleted")));
                  } else if(direction == DismissDirection.startToEnd){
                  
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>MoneyFormPage(clientId: clientId,data: money[index])));
                    
                  }
                },
                child: 
                ListTile(
                    title:Text('$_money'),
                    subtitle: Text(_id),
                ),
              ),
              
            );
            
          }
        )
        
        //List Not Available 👇
        :Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.mood_bad,size: 140,color: Colors.black26,),
            Text("Payments not Found",style: TextStyle(color: Colors.black26,fontSize: 20),)
          ],
        );
      }
    
}
