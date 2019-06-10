import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ppscgym/db.dart';
import 'package:ppscgym/formator/inputFormator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:provider/provider.dart';

class FormPage extends StatelessWidget {

  static GlobalKey<FormState> _adharFormKey = GlobalKey<FormState>();
  static GlobalKey<FormState> _infoFormKey = GlobalKey<FormState>();


  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  String sessionValue,adhar,firstname,lastname,mobile;
  DateTime joindate;
  
  @override
  Widget build(BuildContext context) {
    final db =DatabaseService();
    var user = Provider.of<FirebaseUser>(context);

    //TODO: update logic

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
      body: PageView(
        //physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        children: <Widget>[
          Container(
            child:buildForm(<Widget>[adharField()],_adharFormKey)
          ),
          Container(
            child:buildForm(<Widget>[firstNameField(),Divider(height: 35,),lastNameField(),Divider(height: 35,),mobileField(),Divider(height: 40,),session(),Divider(height: 20,),joinDateField(),Divider(height: 100,color: Colors.transparent,)],_infoFormKey)
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.navigate_next
        ),
        onPressed: (){
          if (_adharFormKey.currentState.validate()) {
            _adharFormKey.currentState.save();
            pageController.animateToPage(1, duration: Duration(milliseconds: 500), curve: Curves.easeInCirc);
            if(_infoFormKey.currentState.validate()){
            _infoFormKey.currentState.save();
            db.createClient(user,adhar,firstname,lastname,sessionValue,mobile,joindate);
            }
          }
        },
      ),
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