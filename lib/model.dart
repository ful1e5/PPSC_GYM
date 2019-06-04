import 'package:cloud_firestore/cloud_firestore.dart';

class Client{

  final String id ;
  final String firstname;
  final String lastname;
  final String adhar;
  final String session;
  final String joindate;
  final String mobile;

  Client({this.id, this.firstname, this.lastname, this.adhar, this.session,this.joindate,this.mobile});

  factory Client.fromFirestore(DocumentSnapshot doc){
    Map data =doc.data;

    return Client(
      id: doc.documentID,
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      adhar: data['adhar'] ?? '',
      session: data['session'] ?? '',
      joindate: data['joindate'] ?? '',
      mobile: data['mobile'] ?? ''
    );
  }
}

class Money{
  final String id;
  final String money;
  final String from;
  final String expiry;

  Money({this.id, this.money, this.from, this.expiry});

  factory Money.fromFirestore(DocumentSnapshot doc){
    Map data =doc.data;

    return Money(
      id: doc.documentID,
      money: data['money'] ?? '',
      from: data['from'] ?? 0,
      expiry: data['expiry'] ?? ''
    );
  }
}