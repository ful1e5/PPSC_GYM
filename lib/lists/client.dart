//flutter
import 'package:flutter/material.dart';
import 'package:ppscgym/pages/client_detail_page.dart';

//depedencies
import 'package:provider/provider.dart';

//service
import 'package:ppscgym/model.dart';

//Icon
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientList extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    var client = Provider.of<List<Client>>(context);
    
    return 
      (client==null)?
      //Data is not Available👇
      Center(child: CircularProgressIndicator())
      //Data Available 👇
      :(client.length>0)?
        
        //List Available 👇
        Container(

          child:ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: client.length,
              itemBuilder: (contex,int index) {
                String _session=client[index].session;
                String name = client[index].name;
                String expiry=client[index].expiry;

                bool normal=true;

                if(expiry==''){
                  normal=true;
                }else{
                  //For Date genrating
                  String year=expiry.substring(0,4);
                  String month=expiry.substring(5,7);
                  String day=expiry.substring(8,10);

                  DateTime current = DateTime.now();
                  DateTime checkExpiry=DateTime.utc(int.parse(year),int.parse(month),int.parse(day));

                  if(current.isAfter(checkExpiry)){
                    normal=false;
                  }else{
                    normal=true;
                  }
                }

                return Card(
                  elevation: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color:(normal)?
                        Color.fromRGBO(64, 75, 96, .9)
                        :Colors.redAccent,
                      ),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ClientDetail(client[index])),
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        leading: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          decoration: BoxDecoration(border: Border(right: BorderSide(width: 1.0, color: Colors.white24))),
                          child: Icon(FontAwesomeIcons.userAlt, color: Colors.white),
                        ),
                        title:Text("$name",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            (_session=='Morning')?
                            Icon(FontAwesomeIcons.sun, color: Colors.yellowAccent,size: 21,)
                            :Icon(FontAwesomeIcons.moon,color: Colors.white,size: 21),
                            Text("   $_session", style: TextStyle(color: Colors.white,fontSize: 16))
                          ],
                        ),
                        trailing:Icon(
                          Icons.keyboard_arrow_right, 
                          color: Colors.white, 
                          size: 30.0,
                        )
                      ),
                    ),
                  ),
                );
              }
          )
        )
        //List Not Available 👇
        :Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(FontAwesomeIcons.solidMehBlank,size: 34,color: Colors.white24,),
              Text("\nNo clients",style: TextStyle(color: Colors.white24,fontSize: 19),)
            ],
          )
        );
      }
}
