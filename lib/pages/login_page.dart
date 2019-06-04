//flutter
import 'package:flutter/material.dart';

//service
import 'package:ppscgym/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: RaisedButton(
            child: Text('SignIn With Google'),
            onPressed: () => authSercice.googleSignIn(),
          ),
        )
      );
  }
}