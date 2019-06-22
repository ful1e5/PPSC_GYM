//flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

//depedencies
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:provider/provider.dart';

//service
import 'package:ppscgym/db.dart';
import 'package:ppscgym/model.dart';

//Formator
import 'package:ppscgym/formator/inputFormator.dart';

//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientFormPage extends StatelessWidget {

  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  Client data;
  ClientFormPage({Key key, this.data}) : super(key: key);

  String sessionValue,adhar,firstname,lastname,mobile;
  DateTime joindate,dob;
  
  @override
  Widget build(BuildContext context) {
    final db =DatabaseService();
    var user = Provider.of<FirebaseUser>(context);

    

    if(data!=null){
      adhar=data.adhar;
      firstname=data.firstname;
      lastname=data.lastname;
      sessionValue=data.session;
      mobile=data.mobile;
      joindate=DateTime.parse(data.joindate);
      dob=DateTime.parse(data.dob);
    }

    return Scaffold(
      body:NestedScrollView(
        headerSliverBuilder: (BuildContext context,bool innerBoxIsScrolled){
          return <Widget>[
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text((data==null)?'ADD INFO':'EDIT INFO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                  )),
              ),
            )
          ];
        },
        body:  buildForm(<Widget>[
          adharField(),
          Divider(height: 40,),
          firstNameField(),
          Divider(height: 40,),
          lastNameField(),
          Divider(height: 40,),
          dateOfBirthField(),
          Divider(height: 40,),
          mobileField(),
          Divider(height: 70,),
          session(),
          Divider(height: 40,),
          joinDateField(),
          Divider(height: 100,color: Colors.transparent,)
        ],
        _formKey
        ),
      ),
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: 
      (data==null)?
      FloatingActionButton(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        foregroundColor: Colors.white,
        child: Icon(FontAwesomeIcons.userPlus),
        onPressed: (){
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            db.createClient(user,adhar,firstname,lastname,sessionValue,mobile,joindate,dob);
            Navigator.pop(context);
          } 
        },
      )
      //FOr updating
      :FloatingActionButton(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        foregroundColor: Colors.white,
        child: Icon(FontAwesomeIcons.userEdit),
        onPressed: (){
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            db.updateClient(user,adhar,data.id,firstname,lastname,sessionValue,mobile,joindate,dob);
            Navigator.pop(context);
          } 
        },
      )
    
    );
  }

  Form buildForm(List<Widget> _list,GlobalKey<FormState> _formKey) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 50, 25, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _list
          ),
        ),
      ),
    );
  }

  Widget adharField() {
    return TextFormField(
      validator: (value){
        if (value.isEmpty) {
          return 'Please enter Adhar Number';
        }else{
          if(value.length==14)
            return null;
          else
            return 'Enter Valid Adhar Number';
        }
      },
      initialValue: (adhar==null)?'':'$adhar',
      onSaved: (val)=>adhar=val,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,

        WhiteSpaceOn(4),  
        //Added 2 whitesSpaces + 12(Adhar) =14
        LengthLimitingTextInputFormatter(14),
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.idCard,color: Color.fromRGBO(58, 66, 86, 1.0)),
        border: OutlineInputBorder(),
        hintText: 'XXXX XXXX XXXX',
        labelText: 'Adhar Number ',
      ),

    );
  }

  Widget firstNameField() {
   
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter First Name';
        }
        return null;
      },
      initialValue: (firstname==null)?'':'$firstname',
      onSaved: (val)=>firstname=val,
      keyboardType: TextInputType.text,
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
      ],
      maxLength: 10,
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.userAlt,color: Color.fromRGBO(58, 66, 86, 1.0)),
        border: OutlineInputBorder(),
        hintText: 'John',
        labelText: 'First Name',
      ),
    );
  }
  
  Widget lastNameField() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter Last Name';
        }
        return null;
      },
      initialValue: (lastname==null)?'':'$lastname',
      onSaved: (val)=>lastname=val,
      keyboardType: TextInputType.text,
      inputFormatters: [
        WhitelistingTextInputFormatter(RegExp("[a-zA-Z]")),
      ],
      maxLength: 10,
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.users,color: Color.fromRGBO(58, 66, 86, 1.0)),
        border: OutlineInputBorder(),
        hintText: 'Wrick',
        labelText: 'Last Name',
      ),
    );
  }

  Widget dateOfBirthField() {
  
    return DateTimePickerFormField(
      initialDate: DateTime.now(),
      validator: (value) {
        if (value==null) {
          return 'Please enter Date Of Birth';
        }
        return null;
      },
      initialValue: (dob==null)?DateTime(1999):dob,
      onSaved: (val)=>dob=val,
      inputType: InputType.date,
      format: DateFormat("dd/MM/yyyy"),
      editable: false,
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.birthdayCake,color: Color.fromRGBO(58, 66, 86, 1.0)),
        border: OutlineInputBorder(),
        labelText: 'Date Of Birth',
        hasFloatingPlaceholder: true
      ),
    ); 
  }

  Widget mobileField() {
    return TextFormField(
      validator: (value) {
         if (value.isEmpty) {
          return 'Please enter Contact Number';
        }else{
          if(value.length==11)
            return null;
          else
            return 'Enter Valid Contact Number';
        }
      },
      initialValue: (mobile==null)?'':'$mobile',
      onSaved: (val)=>mobile=val,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,

        WhiteSpaceOn(5),  
        //Added 1 whitesSpaces + 10(number) =11
        LengthLimitingTextInputFormatter(11),
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.mobile,color: Color.fromRGBO(58, 66, 86, 1.0)),
        border: OutlineInputBorder(),
        hintText: 'XXXXX XXXXX',
        labelText: 'Contact Number',
      ),
    );
  }

  Widget session(){
    return FormField<String>(
      validator: (value) {
        if(data==null){
          if(value==null){
            return "Select your session";
          }
        }else if (value == null) {
          if(data.session==null)
            return "Select your session";
        }
      },
      builder: (FormFieldState<String> state,) {
        return (data==null)?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.userClock,color: Color.fromRGBO(58, 66, 86, 1.0)),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text("Select Session"),
                  value:sessionValue,
                  onChanged: (String newValue) {
                    state.didChange(newValue);
                      sessionValue = newValue;
                  },
                  items: <String>[
                    'Morning',
                    'Evening',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
                  TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            ),
          ],
        )
        :Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.userClock,color: Color.fromRGBO(58, 66, 86, 1.0)),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text(data.session),
                  value:data.session,
                  onChanged: (String newValue) {
                    state.didChange(newValue);
                      sessionValue = newValue;
                  },
                  items: <String>[
                    'Morning',
                    'Evening',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              state.hasError ? state.errorText : '',
              style:
                  TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            ),
          ],
        );
      },
    );
  }

  Widget joinDateField() {
  
    return DateTimePickerFormField(
      initialDate: DateTime.now(),
      validator: (value) {
        if (value==null) {
          return 'Please enter Join Name';
        }
        return null;
      },
      initialValue: (joindate==null)?DateTime.now():joindate,
      onSaved: (val)=>joindate=val,
      inputType: InputType.date,
      format: DateFormat("dd/MM/yyyy"),
      editable: false,
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.userCheck,color: Color.fromRGBO(58, 66, 86, 1.0)),
        border: OutlineInputBorder(),
        labelText: 'Join Date',
        hasFloatingPlaceholder: true
      ),
    ); 
  }
  
}