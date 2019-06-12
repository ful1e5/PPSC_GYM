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

  /// Write data 
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

  /// Update data 
  Future<void> updateClient(FirebaseUser user,String adhar,String fname,String lname,String session,String mob,DateTime joindate) {
    return _db.collection('user').document(user.uid).collection('clients').document(adhar).setData({
      'firstname': fname,
      'lastname' : lname,
      'adhar'    : adhar,
      'session'  : session,
      'joindate' : joindate.toString(),
      'mobile'   : mob
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
  Future<void> addMoney(String clientId,FirebaseUser user,String money,DateTime fromDate,DateTime expireDate) {
    addStatus(clientId, user, "Added Payment Entry");
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document().setData({
      'money'  : money,
      'from'   : fromDate.toString(),
      'expiry' : expireDate.toString(),
    });
  }
  
  /// Update Money by Id in Client
  Future<void> updateMoney(String clientId,FirebaseUser user,String money,DateTime fromDate,DateTime expireDate,String id) {
    addStatus(clientId, user, "Updated Payment Entry");
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document(id).setData({
      'money'  : money,
      'from'   : fromDate.toString(),
      'expiry' : expireDate.toString(),
    },merge: true);
  }

  /// Delete Money by Id in Client
  Future<void> deleteMoney(String clientId,String moneyId,FirebaseUser user) {
    addStatus(clientId, user, "Deleted Payment Entry");
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).collection('money').document(moneyId).delete().catchError((error){
      return error;
    });
  }

  //For Updating Status
  Future<void> addStatus(String clientId,FirebaseUser user,String operation) {
    return _db.collection('user').document(user.uid).collection('clients').document(clientId).setData({
      'last_payment'  : DateTime.now().toString(),
      'operation' : operation
    },merge: true);
  }

  Stream<Status> streamStatus(String clientId,FirebaseUser user) {
    return _db
        .collection('user')
        .document(user.uid)
        .collection('clients')
        .document(clientId)
        .snapshots()
        .map((snap) => Status.fromMap(snap.data));
  }

   
}