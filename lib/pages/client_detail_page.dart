//flutter
import 'package:flutter/material.dart';

//firebase auth
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';


//provider
import 'package:provider/provider.dart';

//services
import 'package:ppscgym/db.dart';
import 'package:ppscgym/model.dart';

//list
import 'package:ppscgym/lists/money.dart';

//Form
import 'package:ppscgym/pages/clientForm.dart';
import 'package:ppscgym/pages/moneyForm.dart';

//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


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
    String clientName =data.name;
    String adhar = data.adhar;
    DateTime dob =DateTime.parse(data.dob);
    String mobile =data.mobile;
    DateTime joinDate =DateTime.parse(data.joindate);
    String sessoin = data.session;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        body: Container(
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 120.0,
                  pinned: true,
                  actions: <Widget>[
                   IconButton(
                    icon: Icon(FontAwesomeIcons.userEdit),
                    onPressed: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                        builder: (context)=>ClientFormPage(data: data)));

                    }
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
                      Tab(
                        icon: Icon(FontAwesomeIcons.infoCircle),
                      ),
                      Tab(
                        icon: Icon(FontAwesomeIcons.wallet),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: <Widget>[
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(top:5,left: 20,right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                      
                          buildListTile("Adhar ID",adhar,FontAwesomeIcons.idCard),
                          buildListTile("Date Of Birth",DateFormat("dd/MM/yyyy").format(dob).toString(),FontAwesomeIcons.birthdayCake),
                          buildListTile("Join Date", DateFormat("dd/MM/yyyy").format(joinDate).toString(), FontAwesomeIcons.userCheck),
                          buildListTile("Session", sessoin, FontAwesomeIcons.userClock),
                          buildListTile("Contact", mobile,FontAwesomeIcons.mobile),
                          
                      
                          StreamProvider<Status>.value(  // All children will have access to Payment Status data
                            stream: db.streamStatus(clientId,user),
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
                                    tooltip: "Delete Client",
                                    icon: Icon(Icons.delete,color: Colors.white),
                                    iconSize: 30,
                                    onPressed: (){
                                      Navigator.pop(context);
                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        db.deleteClient(clientId, user);  
                                      });
                                    },
                                  )
                                )
                              ),
                              Divider(height: 20,),
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
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add Money',
          child: Icon(
            FontAwesomeIcons.plus
          ),
          onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context)=>MoneyFormPage(clientId: clientId)
              ));
          }
        ),
      ),
    );
  }

    Card buildListTile(String heading,String value,IconData icon) {
      return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Icon(icon,size: 34,color: Colors.white,),
            title: Text('$heading',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
            subtitle: Text('$value',style: TextStyle(color: Colors.white70),),
          ),
        ),
      );
  }
}

class Payment extends StatelessWidget {
  const Payment({Key key}) : super(key: key);

  Card buildListTile(String heading,String value,IconData icon) {
      return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: ListTile(
            leading: Icon(icon,size: 34,color: Colors.white,),
            title: Text('$heading',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
            subtitle: Text('$value',style: TextStyle(color: Colors.white70),),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    
    var payment = Provider.of<Status>(context); 

    if(payment==null){
      return Column(
        children: <Widget>[
          Divider(height: 10,),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }else{
      //Check wih default data in Model
      return (payment.lastPayment=='...')?
      //Data is not Available👇
        Column(
          children: <Widget>[
            Divider(height: 50,),
            Text('No Payments',style: TextStyle(color: Colors.white70),)
          ],
        )
        
        
      : 
      //Data Available 👇
      Column(
        children: <Widget>[
          Divider(height: 50,),
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
          buildListTile("Total Payment", payment.total,FontAwesomeIcons.moneyCheck),
          buildListTile("Last Operation On", payment.lastPayment.substring(0,19), FontAwesomeIcons.solidClock),
          buildListTile("Operation", payment.operation,FontAwesomeIcons.cogs),
        ],
      );
    }
  }
}