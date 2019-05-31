import 'package:flutter/material.dart';
import 'package:ppscgym/services/authentication.dart';
import 'package:transparent_image/transparent_image.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() =>  _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey =  GlobalKey<FormState>();

  TextStyle style = TextStyle(fontFamily: 'Raleway' ,fontSize: 20.0,color: Colors.white);
  TextStyle hintStyle = TextStyle(fontFamily: 'Raleway',fontSize: 20.0,color: Colors.white30);
  TextStyle secButtonStyle = TextStyle(color:Colors.white,fontSize: 18.0, fontWeight: FontWeight.w300,decoration: TextDecoration.underline);

  String _email;
  String _password;
  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Initially password is obscure
  bool _obscureText;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    _isLoading=false;
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }

      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          if (_isIos) {
            _errorMessage = e.details;
          } else
            _errorMessage = e.message;
        });
      }
    }
  }


  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _obscureText = true;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    _isLoading=false;
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    _isLoading=false;
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return  Scaffold(
      body: Stack(
      children: <Widget>[
        _showBody(),
        _showCircularProgress(),
      ],
    ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(
        child: Container(
          child: CircularProgressIndicator(),
      ));
    } return Container(height: 0.0, width: 0.0,);

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
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody(){
    return  Container(
        child:  Form(
          key: _formKey,
          child: Stack(
        children: <Widget>[
          Container(color: Colors.black),
          _showBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 50.0),
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 200.0),
                   _showEmailInput(),
                  SizedBox(height: 25.0),
                  _showPasswordInput(),
                  SizedBox(height:10.0),
                  Center(child:_showErrorMessage()),
                  SizedBox(height: 30.0),
                  _showPrimaryButton(),
                  _showSecondaryButton(),
                  
                ],
              ),
            ),
         ),
        ],
      )
    ));
  }

  Widget _showBackground() {
    return Positioned(
      top: 0,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: FadeInImage.memoryNetwork(
          placeholder: kTransparentImage,
          image: 'https://source.unsplash.com/sHfo3WOgGTU',
          fit: BoxFit.cover,
        ),
    );
  }
  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Container(
        padding: EdgeInsets.fromLTRB(20, 0, 15, 0),
        color: Colors.black38,
        child: Text(
          _errorMessage,
          style: TextStyle(
              fontSize: 14.0,
              color: Colors.white,
              height: 1.0,
              fontWeight: FontWeight.w800)
        )
      );
    } else {
      return  Container(
        height: 0.0,
      );
    }
  }

  Widget _showEmailInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
        hintStyle: hintStyle,
        prefixIcon: Icon(Icons.mail,color: Colors.white),
        hintText: "john@example.com",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      style: style,
      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
      onSaved: (value) => _email = value,
    );
  }

      
  Widget _showPasswordInput() {
    return TextFormField(
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(Icons.lock,color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
            ?Icons.visibility_off
            :Icons.visibility,
            color: Colors.white,
          ),
          onPressed: ()=>{
            setState((){
              _obscureText = !_obscureText;
            })
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
      ),
      keyboardType: TextInputType.text,
      style: style,
      validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      onSaved: (value) => _password = value,
    );
  }
      
  Widget _showSecondaryButton() {
    return  FlatButton(
      child: _formMode == FormMode.LOGIN
          ?  Text('Create an account',
              style: secButtonStyle )
          :  Text('Have an account? Sign in',
              style: secButtonStyle ),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return  Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 60.0,
          child:  RaisedButton(
            elevation: 5.0,
            shape:  RoundedRectangleBorder(borderRadius:  BorderRadius.circular(25.0)),
            color: _formMode == FormMode.LOGIN
            ?   Colors.red
            :   Colors.green,
            child: _formMode == FormMode.LOGIN
                ?  Text('Login',
                    style:  TextStyle(fontSize: 20.0, color: Colors.white))
                :  Text('Create account',
                    style:  TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
      
        
}
