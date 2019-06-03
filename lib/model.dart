import 'package:cloud_firestore/cloud_firestore.dart';

class Client{

  final String firstname;
  final String lastname;
  final String adhar;
  final String session;

  Client({this.firstname, this.lastname, this.adhar, this.session});

  factory Client.fromMap(Map data){
    return Client(
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      adhar: data['adhar'] ?? '',
      session: data['session'] ?? ''
    );
  }
}

class Weapon{
  final String id;
  final String name;
  final String hitpoints;
  final String img;

  Weapon({this.id, this.name, this.hitpoints, this.img});

  factory Weapon.fromFirestore(DocumentSnapshot doc){
    Map data =doc.data;

    return Weapon(
      id: doc.documentID,
      name: data['name'] ?? '',
      hitpoints: data['hitpoints'] ?? 0,
      img: data['img'] ?? ''
    );
  }
}