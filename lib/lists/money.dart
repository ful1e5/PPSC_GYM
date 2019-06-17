//flutter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//depedencies
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

//service
import 'package:ppscgym/model.dart';
import 'package:ppscgym/db.dart';

//pages
import 'package:ppscgym/pages/moneyForm.dart';

//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MoneyList extends StatelessWidget {


  final String clientId;
  MoneyList(this.clientId);

  //For Operation
  final db =DatabaseService();  
  @override
  Widget build(BuildContext context) {

    var money = Provider.of<List<Money>>(context);
    var user = Provider.of<FirebaseUser>(context);

    //For Total
    int total=0;

    db.addTotal(clientId, user, '..');
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
            DateTime fromDate=DateTime.parse(money[index].from.substring(0,10));
            DateTime expireDate=DateTime.parse(money[index].expiry.substring(0,10));
            String _expiry=money[index].expiry;

            String _from=DateFormat("dd/MM/yyyy").format(fromDate).toString();
            String _expire=DateFormat("dd/MM/yyyy").format(expireDate).toString();

            DateTime checkExpiry=DateTime.parse(_expiry);
            DateTime currentDate=DateTime.now();

            //For Total
            int m=int.parse(_money);
            total=total+m;
            db.addTotal(clientId, user, total.toString());
            
            //For Latest Expiry
            bool normal=checkExpiry.isAfter(currentDate);

            
            db.addExpiry(clientId, user, checkExpiry.toString());
            
            return Card(
              elevation: 8.0,
              margin: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6.0),
              //Expire Date in Red Color esle in blue
              color:(normal)?
               Color.fromRGBO(52, 152, 219,0.9)
               :Colors.redAccent,
              child: Dismissible(
                key: Key(_id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 40.0),
                  color: Colors.red,
                  child: Icon(FontAwesomeIcons.trash, color: Colors.white),
                ),
                onDismissed: (direction){
                  if(direction == DismissDirection.endToStart){
                    db.deleteMoney(clientId, _id, user);
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("Money Entry Deleted")));
                  } 
                },
                child: 
                Column(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(FontAwesomeIcons.rupeeSign,
                          color: Colors.white,
                          size: 40,
                        ),
                        title:Text('$_money',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 70
                          ),
                        ),
                        trailing: (index==money.length-1)?
                        InkWell(
                          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>MoneyFormPage(clientId: clientId,data: money[index]))),
                          child: Icon(FontAwesomeIcons.edit,
                            size: 25,
                            color: Colors.white,
                          )
                        ):Icon(
                          Icons.edit_attributes,
                          size: 25,
                          color: Colors.white,
                          ),
                    ),
                    Divider(color: Colors.white,height: 5,),
                    ListTile(
                      subtitle: Text('From\t:\t$_from',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          wordSpacing: 12,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1
                        ),
                      ),
                      title: Text('ExpireOn : $_expire',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          wordSpacing: 12,
                          letterSpacing: 1
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
            
          }
        )
        
        //List Not Available 👇
        :buildColumn(user);
      }

  Column buildColumn(FirebaseUser user) {
    db.addExpiry(clientId, user,'');
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.sentiment_neutral,size: 34,color: Colors.white24,),
          Text("No payments",style: TextStyle(color: Colors.white24,fontSize: 14),)
        ],
      );
  }
    
}
