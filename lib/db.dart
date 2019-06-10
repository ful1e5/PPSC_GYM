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
  Future<void> createClient(FirebaseUser user,String adhar,String fname,String lname,String session,String mob,DateTime joindate) {
    return _db.collection('user').document(user.uid).collection('clients').document(adhar).setData({
      'firstname': fname,
      'lastname' : lname,
      'adhar'    : adhar,
      'session'  : session,
      'joindate' : joindate.toString(),
      'mobile'   : mob
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

  /// Delete CLient by Id
  Future<void> deleteClient(String clientId,FirebaseUser user) {
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).delete().catchError((error){
      return error;
    });
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
  Future<void> addMoney(String clientId,FirebaseUser user) {
    addPaymentStatus(clientId, user, "Added");
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document().setData({
      'money'  : 200,
      'from'   : "today",
      'expiry' : "tommorow",
    });
  }
  
  /// Update Money by Id in Client
  /// TODO: Add model to complete operation 
  Future<void> updateMoney(String clientId,String moneyId,FirebaseUser user) {
    addPaymentStatus(clientId, user, "Updated");
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document(moneyId).setData({
      'money'  : 20,
      'from'   : "today",
      'expiry' : "2 day letter",
    },merge: true);
  }

  /// Delete Money by Id in Client
  /// TODO: Add model to complete operation 
  Future<void> deleteMoney(String clientId,String moneyId,FirebaseUser user) {
    addPaymentStatus(clientId, user, "Deleted");
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document(moneyId).delete().catchError((error){
      return error;
    });
  }

  //For Updating Status
  Future<void> addPaymentStatus(String clientId,FirebaseUser user,String operation) {
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).setData({
      'last_payment'  : DateTime.now().toString(),
      'operation' : operation
    },merge: true);
  }

  Stream<PaymentStatus> streamPaymentStatus(String clientId,FirebaseUser user) {
    return _db
        .collection('user')
        .document(user.uid)
        .collection('clients')
        .document(clientId)
        .snapshots()
        .map((snap) => PaymentStatus.fromMap(snap.data));
  }

   
}