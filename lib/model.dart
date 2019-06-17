import 'package:cloud_firestore/cloud_firestore.dart';

class Client{

  final String id ;
  final String name;
  final String firstname;
  final String lastname;
  final String adhar;
  final String session;
  final String joindate;
  final String mobile;
  final String expiry;
  final String dob;
  final String totalPayment;

  Client({this.id, this.name, this.firstname, this.lastname, this.adhar, this.session,this.joindate,this.mobile,this.expiry,this.dob,this.totalPayment});

  factory Client.fromFirestore(DocumentSnapshot doc){
    Map data =doc.data;

    return Client(
      id:doc.documentID,
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      name: data['name']?? '',
      adhar: data['adhar'] ?? '',
      session: data['session'] ?? '',
      joindate: data['joindate'] ?? '',
      mobile: data['mobile'] ?? '',
      expiry: data['expiry'] ?? '',
      dob:data['dob']??'',
      totalPayment:data['total']??''
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
      from: data['from'] ?? '...',
      expiry: data['expiry'] ?? '...'
    );
  }
}

class Status {

  final String lastPayment;
  final String operation;
  final String expiry;
  final String total;

  Status({ this.lastPayment, this.operation,this.expiry,this.total});

  factory Status.fromMap(Map data) {
    data = data ?? null;
    return Status(
      lastPayment: data['last_payment'] ?? '...',
      operation: data['operation'] ?? '...',
      expiry: data['expiry'] ?? '',
      total: data['total'] ?? '0'
    );
  }

}