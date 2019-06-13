import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ppscgym/db.dart';
import 'package:ppscgym/formator/inputFormator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:ppscgym/model.dart';
import 'package:provider/provider.dart';
import 'package:ppscgym/pages/moneyForm.dart';

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
      mobile=data.mobile;
      sessionValue=data.session;
      joindate=DateTime.parse(data.joindate);
      dob=DateTime.parse(data.dob);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.0),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(child: Text('ADD CLIENT ',style: TextStyle(fontSize: 50,color: Colors.white),))),
        ),
      ),
      body: buildForm(<Widget>[
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
          
      
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: 
      (data==null)?
      FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: (){
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            db.createClient(user,adhar,firstname,lastname,sessionValue,mobile,joindate,dob);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MoneyFormPage(clientId: adhar)),
            );
          } 
        },
      )
      //FOr updating
      :FloatingActionButton(
        child: Icon(Icons.update),
        onPressed: (){
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            db.updateClient(user,adhar,firstname,lastname,sessionValue,mobile,joindate,dob);
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
        hintText: 'XXXXX XXXXX',
        labelText: 'Contact Number',
      ),
    );
  }

  Widget session(){
    return FormField<String>(
      validator: (value) {
        if (value == null) {
          return "Select your session";
        }
      },
      builder: (FormFieldState<String> state,) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InputDecorator(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(0.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: (sessionValue==null)?Text("Select Session"):Text("$sessionValue"),
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
          labelText: 'Join Date',
          hasFloatingPlaceholder: true
      ),
    ); 
  }
  
}