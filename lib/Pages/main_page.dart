import 'package:flutter/material.dart';
import 'package:ppscgym/Pages/add_gymer_page.dart';
import 'package:ppscgym/services/authentication.dart';
import 'package:ppscgym/utils/list_card.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ppscgym/utils/top_bar.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() =>  _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  
  bool _isEmailVerified = false;
  int _page = 0;
  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:  Text("Verify your account"),
          content:  Text("Please verify account in the link sent to email"),
          actions: <Widget>[
             FlatButton(
              child:  Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
             FlatButton(
              child:  Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:  Text("Verify your account"),
          content:  Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
             FlatButton(
              child:  Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> _views = [
    ListCard(userId: widget.userId),
    Container(child: Center(child: Text("SEARCH SCREEN EXAMPLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
    Container(child: Center(child: Text("TRASH SCREEN EXAMPLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
    Container(child: Center(child: Text("PROFILE SCREEN EXAMPLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE64C85),
      body: Stack(
        children: <Widget>[
          TopBar(height: 300.0,header: "GYMER",startColor: Colors.red,endColor: const Color(0xFFE64C85),),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 70.0),
              child: Column(
                children: <Widget>[
                   _views[_page]
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
          index: 0,
          height: 60.0,
          items: <Widget>[
            Icon(Icons.list, size: 30),
            Icon(Icons.search, size: 30),
            Icon(Icons.delete, size: 30),
            Icon(Icons.person_outline, size: 30)
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: const Color(0xFFE64C85),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 500),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
        floatingActionButton: FloatingActionButton(

          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 1.0,
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddGymer()));
          },
          heroTag: "Add Gymer",
          child: Icon(
            Icons.add,
          ),
          tooltip: "Add Gymer",
        ),
    );
  }

}