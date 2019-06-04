import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:ppscgym/model.dart';


class DatabaseService{

  final Firestore _db =  Firestore.instance;

  /// DB Operation For Client
  /// Query a subcollection to get list of Clinets
  Stream<List<Client>> streamClient(FirebaseUser user){
    var ref = _db.collection('user').document(user.uid).collection('clients');

    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Client.fromFirestore(doc)).toList());
  }

  /// Query a subcollection to get list of Deleted Clinets
  Stream<List<Client>> streamDeletedClient(FirebaseUser user){
    var ref = _db.collection('user').document(user.uid).collection('clients');

    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Client.fromFirestore(doc)).toList());
  }

  /// Write data by Id 
  /// TODO: Add model to complete operation
  /// TODO: Handle auto Id
  Future<void> createClient(FirebaseUser user) {
    return _db.collection('user').document(user.uid).collection('clients').document().setData({
      'firstname': "kaiz",
      'lastname' : "khatri",
      'adhar'    : "123456789321",
      'session'  : "morining",
      'joindate' : "Today",
      'mobile'   : "23829323"
    });
  }

  /// Update data by Id  
  /// TODO: Add model to complete operation
  Future<void> updateClient(String clientId,FirebaseUser user) {
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).setData({
      'firstname': "kai",
      'lastname' : "katri",
      'adhar'    : "12356789321",
      'session'  : "mining",
      'joindate' : "Today",
      'mobile'   : "23829323"
    },merge: true);
  }

  /// DB Operation For Money
  /// Query a subcollection to get list of Money
  Stream<List<Money>> streamMoney(String clientId,FirebaseUser user){
    var ref = _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money');

    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Money.fromFirestore(doc)).toList());
  }
  
  /// Add Money List in Single Client 
  /// TODO: Add model to complete operation 
  /// TODO: handle auto id
  Future<void> addMoney(String clientId,FirebaseUser user) {
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document().setData({
      'money'  : "200",
      'from'   : "today",
      'expiry' : "tommorow",
    });
  }
  
  /// Update Money by Id in Client
  /// TODO: Add model to complete operation 
  Future<void> updateMoney(String clientId,String moneyId,FirebaseUser user) {
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document(moneyId).setData({
      'money'  : "100",
      'from'   : "today",
      'expiry' : "2 day letter",
    },merge: true);
  }

}