//flutter
import 'package:flutter/material.dart';

//Icon
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Icon(
                FontAwesomeIcons.dumbbell,
                size: 100,
                color: Colors.white,
              ),
            ),
            Divider(height: 300,color: Colors.transparent,),
            Card(
              elevation: 8.0,
              margin:EdgeInsets.symmetric(horizontal: 56.0),
              child: InkWell(
                onTap: () => authSercice.googleSignIn(),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Icon(FontAwesomeIcons.google),
                      Spacer(),
                      Text("CONNECT WITH GOOGLE",
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            )
          
          ],
        )
      );
  }
}