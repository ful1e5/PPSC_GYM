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

//icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MoneyFormPage extends StatelessWidget {


  final String clientId;
  Money data;
  MoneyFormPage({Key key, this.clientId,this.data}) : super(key: key);

  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  String money,moneyId;
  DateTime fromDate,expireDate,nextmonth;

  
  @override
  Widget build(BuildContext context) {
    final db =DatabaseService();
    var user = Provider.of<FirebaseUser>(context);

    fromDate=DateTime.now();
    nextmonth=DateTime(fromDate.year,fromDate.month +1,fromDate.day);

    if(data!=null){
      money=data.money;
      moneyId=data.id;
      fromDate=DateTime.parse(data.from);
      expireDate=DateTime.parse(data.expiry);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.0),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Center(child: Text(
              (data==null)?
              'ADD PAYMENT '
              :'EDIT PAYMENT',
              style: TextStyle(
                fontSize: 50,
                color: Colors.white),)
              )
            ),
        ),
      ),
      body: buildForm(<Widget>[
          moneyField(),
          Divider(height: 40,),
          fromDateField(),
          Divider(height: 40,),
          expireDateField(),
          Divider(height: 100,color: Colors.transparent,)
        ],
        _formKey
        ),
          
      
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
      (data==null)?
      //Add new  Money Entry
       FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: Icon(FontAwesomeIcons.plus),
        onPressed: (){
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            db.addMoney(clientId, user,money,fromDate,expireDate);
            Navigator.pop(context);
          } 
        },
      )
      //For Update entry
      :
      FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: Icon(FontAwesomeIcons.edit),
        onPressed: (){
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            db.updateMoney(clientId, user,money,fromDate,expireDate,moneyId);
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

  Widget moneyField() {
    return TextFormField(
      validator: (value){
        if (value.isEmpty) {
          return 'Please enter Money';
        }else{
            return null;
        }
      },
      initialValue: (data==null)?'':'$money',
      onSaved: (val)=>money=val,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      maxLength: 4,
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.rupeeSign,color: Color.fromRGBO(58, 66, 86, 1.0)),
        border: OutlineInputBorder(),
        hintText: 'XXXX',
        labelText: 'Rupee ',
      ),

    );
  }
  
  Widget fromDateField() {
  
    return DateTimePickerFormField(
      validator: (value) {
        if (value==null) {
          return 'Please enter date';
        }
        return null;
      },
      initialValue: (fromDate==null)?DateTime.now():fromDate,
      onSaved: (val)=>fromDate=val,
      inputType: InputType.date,
      format: DateFormat("dd/MM/yyyy"),
      editable: false,
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.calendarDay,color: Colors.blue),
        border: OutlineInputBorder(),
        labelText: 'From Date',
        hasFloatingPlaceholder: true
      ),
    ); 
  }
  
  Widget expireDateField() {
  
    return DateTimePickerFormField(
      validator: (value) {
        if (value==null) {
          return 'Please enter expire date';
        }
        return null;
      },
      initialValue: (expireDate==null)?nextmonth:expireDate,
      onSaved: (val)=>expireDate=val,
      inputType: InputType.date,
      format: DateFormat("dd/MM/yyyy"),
      editable: false,
      decoration: InputDecoration(
        prefixIcon: Icon(FontAwesomeIcons.solidCalendarTimes,color: Colors.redAccent),
        border: OutlineInputBorder(),
        labelText: 'Expire Date',
        hasFloatingPlaceholder: true
      ),
    ); 
  }
}