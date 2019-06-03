import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:ppscgym/model.dart';


class DatabaseService{

  final Firestore _db =  Firestore.instance;


  /// Get a stream of a single Client
  Stream<Client> streamClient(String id,FirebaseUser user){
    return _db
      .collection('user')
      .document(user.uid)
      .collection('clients')
      .document(id)
      .snapshots()
      .map((snap) => Client.fromMap(snap.data));
  }

  /// Query a subcollection 
  Stream<List<Weapon>> streamMoney(String heroId,FirebaseUser user){
    var ref = _db.collection('user').document(user.uid).collection('clients').document(heroId).collection('money');

    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Weapon.fromFirestore(doc)).toList());
  }


  /// Write data by Id and data 
  /// TODO: herId to clientId
  Future<void> createClient(String heroId,FirebaseUser user) {
    return _db.collection('user').document(user.uid).collection('clients').document(heroId).setData({
     'firstname': "kaiz",
      'lastname' : "khatri",
      'adhar' : "123456789321",
      'session': "morining"
    });
  }

  /// Update data by Id and data 
  Future<void> updateClient(String heroId,FirebaseUser user) {
    return _db.collection('user').document(user.uid).collection('clients').document(heroId).setData({
     'firstname': "kai",
      'lastname' : "katri",
      'adhar' : "12356789321",
      'session': "mining"
    },merge: true);
  }

}