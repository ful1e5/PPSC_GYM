import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ppscgym/bloc/inputFormator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class FormPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
        body: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              adharField(),
              firstNameField(),
              lasrNameField(),
              mobileField(),
              session(),
              joinDateField(),
              Container(
                margin: EdgeInsets.only(top: 25.0),
              ),
              
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){},
        )
    );
  }

  Widget adharField() {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,

        WhiteSpaceOn(4),  
        //Added 2 whitesSpaces + 12(Adhar) =14
        LengthLimitingTextInputFormatter(14),
      ],
      decoration: InputDecoration(
        hintText: 'XXXX XXXX XXXX',
        labelText: 'Adhar Number',
      ),
    );
  }

  Widget firstNameField() {
   
    return TextField(
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
  
  Widget lasrNameField() {
    return TextField(
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
    return TextField(
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
    String session;
    return Center(
      child: DropdownButton<String>(
        hint: (session==null)?Text("Select Session") : Text("$session") ,
        iconSize: 20,
        value: session,
        onChanged: (String newValue) {
            session = newValue;
        },
        items: <String>['Morning', 'Evening']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
      )
    );
  }

  Widget joinDateField() {
  
    return DateTimePickerFormField(
      inputType: InputType.date,
      format: DateFormat("dd/MM/yyyy"),
      initialDate: DateTime.now(),
      editable: false,
      decoration: InputDecoration(
          labelText: 'Join Date',
          hasFloatingPlaceholder: true
      ),
    ); 
  }
  
  
  
}