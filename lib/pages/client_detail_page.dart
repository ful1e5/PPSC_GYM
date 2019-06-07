//flutter
import 'package:flutter/material.dart';

//firebase auth
import 'package:firebase_auth/firebase_auth.dart';

//provider
import 'package:provider/provider.dart';

//services
import 'package:ppscgym/db.dart';
import 'package:ppscgym/model.dart';

//list
import 'package:ppscgym/lists/money.dart';

class ClientDetail extends StatelessWidget {

  //For pass the model
  final Client data;

  
  //for streaming money
  final db = DatabaseService();

  ClientDetail(this.data);

  @override
  Widget build(BuildContext context) {

    var user = Provider.of<FirebaseUser>(context);
    
    String clientId=data.id;
    String clientName =data.firstname.toUpperCase()+'  '+data.lastname.toUpperCase();
    String adhar = data.adhar;
    String mobile =data.mobile;
    String joinDate =data.joindate;
    String sessoin = data.session;
    
    return Hero(
      tag: clientId,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Container(
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 130.0,
                    pinned: true,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: ()=>db.addMoney(clientId, user),
                      )
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text("$clientName \n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23.0,
                        )),
                    ),
                    bottom: TabBar(
                      tabs: <Widget>[
                        Icon(Icons.info,size: 26,),
                        Icon(Icons.receipt,size: 26,)
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(top:5,left: 20,right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                        
                            buildListTile("Adhar ID",adhar,Icons.assignment_ind),
                            buildListTile("Join Date", joinDate, Icons.transit_enterexit),
                            buildListTile("Session", sessoin, Icons.av_timer),
                            buildListTile("Contact", mobile,Icons.phone_android),
                            Divider(height: 50,),
                            //TODO:last payment
                            Column(
                              children: <Widget>[
                                Card(
                                  color: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5)
                                      )
                                  ),
                                  child:Padding(
                                    padding: EdgeInsets.all(18),
                                    child: Text("Payment Info",
                                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.white),
                                      textAlign: TextAlign.center,
                                    )
                                  )
                                ),
                          
                                StreamProvider<PaymentStatus>.value(  // All children will have access to SuperHero data
                                  stream: db.streamPaymentStatus(clientId,user),
                                  child: Payment(),
                                ),
                                Divider(height: 30,),
                                Card(
                                  color: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35)
                                  ),
                                  child:Padding(
                                    padding: EdgeInsets.all(6),
                                    child: IconButton(
                                      icon: Icon(Icons.delete,color: Colors.white),
                                      iconSize: 30,
                                      onPressed: (){
                                        db.deleteClient(clientId, user);
                                        Navigator.pop(context);
                                      },
                                    )
                                  )
                                )
                              ],
                            )
                        ],
                      ),
                    ),
                  ),
                  
                  StreamProvider<List<Money>>.value( // All children will have access to Money data
                    stream: db.streamMoney(clientId,user),
                    child: MoneyList(clientId,)
                  ),
                  
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

    Card buildListTile(String heading,String value,IconData icon) {
      return Card(
        child: ListTile(
          leading: Icon(icon,size: 34,),
          title: Text('$heading',style: TextStyle(fontWeight: FontWeight.w500),),
          subtitle: Text('$value'),
        ),
      );
  }
}

class Payment extends StatelessWidget {
  const Payment({Key key}) : super(key: key);

  Card buildListTile(String heading,String value,IconData icon) {
      return Card(
        child: ListTile(
          leading: Icon(icon,size: 34,),
          title: Text('$heading',style: TextStyle(fontWeight: FontWeight.w500),),
          subtitle: Text('$value'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    
    var payment = Provider.of<PaymentStatus>(context); 

    return (payment==null)?
    //Data is not Available👇
    Column(
      children: <Widget>[
        buildListTile("Last Transaction", '...', Icons.loop),
        buildListTile("Operation", '...',Icons.category),
      ],
    )
    //Data Available 👇
    : 
    Column(
      children: <Widget>[
        buildListTile("Last Transaction", payment.lastPayment, Icons.loop),
        buildListTile("Operation", payment.operation,Icons.category),
      ],
    );
  }
}