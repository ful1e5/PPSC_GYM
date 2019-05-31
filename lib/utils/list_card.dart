import 'package:flutter/material.dart';
import 'package:ppscgym/models/gymer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ppscgym/utils/card.dart';

class ListCard extends StatefulWidget {
  
  final Gymer list;
  final String userId;

  const ListCard({Key key, this.list, this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>  _ListCardState();
}

class _ListCardState extends State<ListCard> {

  List<Gymer> _gymerList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Query _gymerQuery;

  @override
  void initState() {
    super.initState();

    _gymerList =  List();
    _gymerQuery = _database
        .reference()
        .child("gymer")
        .orderByChild("userId")
        .equalTo(widget.userId);
  }
  @override
  Widget build(BuildContext context) {
    if (_gymerList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _gymerList.length,
          itemBuilder: (BuildContext context, int index) {
            String _gymerId = _gymerList[index].key;
            String _firstname = _gymerList[index].firstname;
            String _lastname = _gymerList[index].lastname;
            bool _status = _gymerList[index].paymentstatus;

            return SingleCard(key:Key(_gymerId),firstname: _firstname, lastname: _lastname,status: _status);
          }
      );
    }else{
      return Card(
        elevation: 2.0,
        margin: const EdgeInsets.all(5.0),
        child:Container(
          height: 104,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.sentiment_neutral,size: 40,color: Colors.black12,),
              Padding(padding: EdgeInsets.only(left: 15),
              child: Text("NO RECORD !!",
              style: TextStyle(
                color: Colors.black12,
                fontFamily: "Relaway",
                fontSize: 30),
              ))
            ],
          ),
        )
      );
    }
  }
  
}

  