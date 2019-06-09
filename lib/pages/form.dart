import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ppscgym/bloc/bloc.dart';
import 'package:ppscgym/bloc/inputFormator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:provider/provider.dart';

class FormPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
  
    final bloc = Provider.of(context);
    return Scaffold(
        body: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              adharField(bloc),
              firstNameField(bloc),
              lasrNameField(bloc),
              mobileField(bloc),
              session(bloc),
              joinDateField(bloc),
              Container(
                margin: EdgeInsets.only(top: 25.0),
              ),
              StreamBuilder(
                stream: bloc.submitValid,
                builder: (context, snapshot) {
                  return RaisedButton(
                    child: Text('Login'),
                    color: Colors.blue,
                    onPressed: snapshot.hasData ? bloc.submit : null,
                  );
                },
              )
            ],
          ),
        ),
    );
  }

  Widget adharField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.adhar,
      builder: (context,snapshot){
        return TextField(
          onChanged: bloc.changeAdhar,
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
      },
    );
  }

  Widget firstNameField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.fname,
      builder: (context,snapshot){
        return TextField(
          onChanged: bloc.changeFirstName,
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
      },
    );
  }
  
  Widget lasrNameField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.lname,
      builder: (context,snapshot){
        return TextField(
          onChanged: bloc.changeLastName,
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
      },
    );
  }

  Widget mobileField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.mob,
      builder: (context,snapshot){
        return TextField(
          onChanged: bloc.changeMobile,
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
      },
    );
  }

  Widget session(Bloc bloc){
    return StreamBuilder(
      stream: bloc.session,
      builder: (context,snapshot){
        return Center(
          child: DropdownButton<String>(
            hint: (session==null)?Text("Select Session") : Text("$session") ,
            iconSize: 20,
            value: snapshot.data,
            onChanged: (String value) =>bloc.setValue(value),
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
      },
    );
  }

  Widget joinDateField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.joinDate,
      builder: (context,snapshot){
        return DateTimePickerFormField(
          onChanged: bloc.changeJoinDate,
          inputType: InputType.date,
          format: DateFormat("dd/MM/yyyy"),
          initialDate: DateTime.now(),
          editable: false,
          decoration: InputDecoration(
              labelText: 'Join Date',
              hasFloatingPlaceholder: true
          ),
        ); 
      },
    );
  }
}