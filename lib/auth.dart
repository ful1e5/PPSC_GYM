import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class AuthSercice {

  /// Creating Authentication Instaces

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;


  /// For Listining The State
  Observable<FirebaseUser> user;  //Firebase user
  Observable<Map<String ,dynamic>> profile; //custom user data in Firestore
  PublishSubject loading = PublishSubject();

  /// Constructor

  AuthSercice(){

    user = Observable(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u){

      if(u != null){
        return _db.collection('user').document(u.uid).snapshots().map((snap) => snap.data);
      }else{
        return Observable.just({ });
      }
    });

  }
  
  /// For SignIn
  Future<FirebaseUser> googleSignIn() async {

      /// Flip The Loading State to true
      loading.add(true);

      /// Step to User SignIn
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      /// 👆 After Complete It Give Auth Token
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
 
      /// 👇 Getting Credential for LogIn
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );    
      /// SignIn To Firebase
      final FirebaseUser user = await _auth.signInWithCredential(credential);

      /// method 
      updateUserData(user);
      print("Signed In " +user.displayName);

      /// Turning Loding To false
      loading.add(false);
      
      return user;
    }
    
    /// Update Data to FireStore
    void updateUserData(FirebaseUser user) async {
      DocumentReference ref = _db.collection('user').document(user.uid);

      return ref.setData({
        'uid': user.uid,
        'email': user.email,
        'photoURl': user.photoUrl,
        'displayName': user.displayName,
        'lastseen': DateTime.now()
      },
      /// For Overwrite Update
      merge: true);
    }

    void signOut(){
      _auth.signOut();
    }

  }

final AuthSercice authSercice = AuthSercice();