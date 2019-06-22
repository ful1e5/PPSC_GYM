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
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/background.jpeg',
                  image: 'https://source.unsplash.com/sHfo3WOgGTU',
                  fit: BoxFit.cover,
                ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Divider(height: 50,color: Colors.transparent,),
                Center(
                  child: Image.asset(
                  'assets/icon/login_icon.png'
                  )
                ),
                Divider(height: 150,color: Colors.transparent,),
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
            ),
          ],
        )
      );
  }
}