//flutter
import 'package:flutter/material.dart';

//service
import 'package:ppscgym/auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('SignIn With Google'),
                onPressed: () => authSercice.googleSignIn(),
              ),
            ],
          ),
        )
      );
  }
}