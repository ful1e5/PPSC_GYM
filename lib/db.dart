import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:ppscgym/model.dart';


class DatabaseService{

  final Firestore _db =  Firestore.instance;

  Future<SuperHero> getHero(String id) async{

    var snap = await _db.collection('heroes').document(id).get();

    return SuperHero.fromMap(snap.data);

  }

  //Get a stream of a single document
  Stream<SuperHero> streamHero(String id){
    return _db
      .collection('heroes')
      .document(id)
      .snapshots()
      .map((snap) => SuperHero.fromMap(snap.data));
  }

  //Query a subcollection 
  Stream<List<Weapon>> streamWeapon(FirebaseUser user){
    var ref = _db.collection('heroes').document(user.uid).collection('weapons');

    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Weapon.fromFirestore(doc)).toList());
  }

  /// Write data
  Future<void> createHero(String heroId) {
    return _db.collection('heroes').document(heroId).setData({ 
      /* some data */ 
    });
  }
}