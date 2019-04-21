import 'package:firebase_database/firebase_database.dart';

class Gymer {
  String key;
  String firstname;
  String lastname;
  bool paymentstatus;
  String userId;

  Gymer(this.firstname,this.lastname , this.userId, this.paymentstatus);

  Gymer.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    userId = snapshot.value["userId"],
    firstname = snapshot.value["firstName"],
    lastname = snapshot.value["lastName"],
    paymentstatus = snapshot.value["paymentSatus"];

  toJson(){
    return{
      "userId": userId,
      "firstname": firstname,
      "lastname": lastname,
      "paymentstatus": paymentstatus,
    };
  }
}