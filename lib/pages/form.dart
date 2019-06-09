import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ppscgym/db.dart';
import 'package:ppscgym/formator/inputFormator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:ppscgym/model.dart';
import 'package:provider/provider.dart';

class FormPage extends StatelessWidget {

  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String sessionValue;
  static Client data;
  @override
  Widget build(BuildContext context) {
    final db =DatabaseService();
    var user = Provider.of<FirebaseUser>(context);

    return Scaffold(
        body: Container(
          margin: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Builder(
              builder: (context)=> Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      adharField(),
                      firstNameField(),
                      lastNameField(),
                      mobileField(),
                      session(),
                      joinDateField(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: IconButton(
                          icon: Icon(Icons.add),
                          iconSize: 46,              
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              db.createClient(user,data);
                            }
                          },
                          tooltip: 'Submit',
                        ),
                      )
                    ],
                  ),
                )
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
      onSaved: (val)=>data.adhar=val,
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
      onSaved: (val)=>data.firstname=val,
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
      onSaved: (val)=>data.lastname=val,
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
      onSaved: (val)=>data.mobile=val,
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
      onSaved: (val)=>data.joindate=val,
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