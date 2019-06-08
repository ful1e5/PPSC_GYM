import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'validators.dart';
import 'package:rxdart/rxdart.dart';

import 'package:ppscgym/db.dart';

//* Using a shortcut getter method on the class to create simpler and friendlier API for the class to provide access of a particular function on StreamController
//* Mixin can only be used on a class that extends from a base class, therefore, we are adding Bloc class that extends from the Object class
//NOTE: Or you can write "class Bloc extends Validators" since we don't really need to extend Bloc from a base class
class Bloc extends Object with Validators {

  FirebaseUser user;
  DatabaseService db;

  final _adharController = BehaviorSubject<String>();
  final _firstNameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();
  final _mobileController = BehaviorSubject<String>();
  final _sessionController = BehaviorSubject<String>();
  final _joinDateController = BehaviorSubject<DateTime>();

  // Add data to streamdate with bloc flutter
  Stream<String> get adhar => _adharController.stream.transform(validateAdhar);
  Stream<String> get fname => _firstNameController.stream.transform(validFirstName);
  Stream<String> get lname => _lastNameController.stream.transform(validLastName);
  Stream<String> get mob => _mobileController.stream.transform(validMob);
  Stream<String> get session => _sessionController.stream;
  Stream<String> get joinDate => _joinDateController.stream.transform(validJoinDate);

  Stream<bool> get submitValid =>
      Observable.combineLatest6(adhar, fname ,lname ,mob ,session, joinDate, (a, f, l, m, s,j) => true);

  // change data

  Function(String) get changeAdhar => _adharController.sink.add;
  Function(String) get changeFirstName => _firstNameController.sink.add;
  Function(String) get changeLastName => _lastNameController.sink.add;
  Function(String) get changeMobile => _mobileController.sink.add;
  Function(DateTime) get changeJoinDate => _joinDateController.sink.add;
  
  //for Session
  void setValue(value){
    _sessionController.sink.add(value);
  }

  submit() {
    
    final validAdhar = _adharController.value;
    final validFirstName = _firstNameController.value;
    final validLastName = _lastNameController.value;
    final validMob = _mobileController.value;
    final validSession =_sessionController.value;

  

    print(' adhar $validAdhar,fname $validFirstName,lname $validLastName,contact $validMob,session $validSession');
  }

  dispose() {
    _adharController.close();
    _firstNameController.close();
    _lastNameController.close();
    _mobileController.close();
    _sessionController.close();
    _joinDateController.close();
  }
}

//Note: This creates a global instance of Bloc that's automatically exported and can be accessed anywhere in the app
//final bloc = Bloc();
