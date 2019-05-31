import 'package:flutter/material.dart';
import 'package:ppscgym/Pages/add_gymer_page.dart';
import 'package:ppscgym/services/authentication.dart';
import 'package:ppscgym/utils/list_card.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ppscgym/utils/top_bar.dart';
import 'package:rect_getter/rect_getter.dart';

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

  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 100); 
  GlobalKey rectGetterKey = RectGetter.createGlobalKey(); 
  Rect rect;

  //Initialy Verify User
  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  //Check User
  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  //If not Resend Verify Link
  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  //If not Popup Box
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
                //Function Call 
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

  //After Sent Verify Mail
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

  //FLoating Button Animation
   void _onTap() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));  //<-- set rect to be size of fab
    WidgetsBinding.instance.addPostFrameCallback((_) {                //<-- on the next frame...
      setState(() =>
          rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide)); //<-- set rect to be big
      Future.delayed(animationDuration + delay, _goToNextPage); //<-- after delay, go to next page
    });
  }

  void _goToNextPage() {
    Navigator.of(context)
        .push(FadeRouteBuilder(page: AddGymer()))
        .then((_) => setState(() => rect = null));
  }

  Widget _ripple() {
  if (rect == null) {
    return Container();
  }
  return AnimatedPositioned( //<--replace Positioned with AnimatedPositioned
    duration: animationDuration, //<--specify the animation duration
    left: rect.left,
    right: MediaQuery.of(context).size.width - rect.right,
    top: rect.top,
    bottom: MediaQuery.of(context).size.height - rect.bottom,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
    ),
  );
}

  //Main 
  @override
  Widget build(BuildContext context) {

    //Page List
    List<Widget> _views = [
    ListCard(userId: widget.userId),
    Container(child: Center(child: Text("SEARCH SCREEN EXAMPLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
    Container(child: Center(child: Text("TRASH SCREEN EXAMPLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
    Container(child: Center(child: Text("PROFILE SCREEN EXAMPLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
    ];

    return Stack(
      children: <Widget>[
        Scaffold(
          body: Container(
            color: const Color(0xFF141E30),
            child: Stack(
              children: <Widget>[
                TopBar(height: 300.0,header: "GYMER",startColor: const Color(0xFF243B55),endColor: const Color(0xFF141E30),),
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
            )
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
              backgroundColor: const Color(0xFF141E30),
              animationCurve: Curves.easeInOut,
              animationDuration: Duration(milliseconds: 500),
              onTap: (index) {
                setState(() {
                  _page = index;
                });
              },
            ),
            floatingActionButton: RectGetter(           
            key: rectGetterKey,                       
            child: FloatingActionButton(
              onPressed: _onTap,
              child: Icon(Icons.add),
            ),
          ),
        ),
        _ripple()
      ],
    );
  }

}


//Fade Paging Routing Class 
//Used For Floting Button

class FadeRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRouteBuilder({@required this.page})
      : super(
          pageBuilder: (context, animation1, animation2) => page,
          transitionsBuilder: (context, animation1, animation2, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
        );
}
