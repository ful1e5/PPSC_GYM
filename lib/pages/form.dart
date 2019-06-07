import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppscgym/bloc/bloc.dart';
import 'package:ppscgym/bloc/inputFormator.dart';
import 'package:ppscgym/bloc/provider.dart';

class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: Form()
    );
  }
}

class Form extends StatelessWidget {
  const Form({Key key}) : super(key: key);

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
              //joint date
              Container(
                margin: EdgeInsets.only(top: 25.0),
              ),
              
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
            child: StreamBuilder(
              stream: bloc.submitValid,
              builder: (context, snapshot) {
                return IconButton(
                  icon: Icon(Icons.add),
                  color: Colors.blue,
                  onPressed: snapshot.hasData ? bloc.submit : null,
                );
              },
            ),
            onPressed: (){},
      ),
    );
  }

  Widget adharField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.adhar,
      builder: (context, snapshot) {
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
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget firstNameField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.fname,
      builder: (context, snapshot) {
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
            errorText: snapshot.error,
          ),
        );
      },
    );
  }
  
  Widget lasrNameField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.lname,
      builder: (context, snapshot) {
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
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget mobileField(Bloc bloc) {
    return StreamBuilder(
      stream: bloc.mob,
      builder: (context, snapshot) {
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
            errorText: snapshot.error,
          ),
        );
      },
    );
  }

  Widget session(Bloc bloc){
    return StreamBuilder(
      stream: bloc.session,
      builder: (context,snapshot){
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: "Morning",
              groupValue: snapshot.data,
              onChanged: (e)=>bloc.setValue(e),
            ),
            Text(
              'Morning',
              style: TextStyle(fontSize: 16.0),
            ),
            Radio(
              value: "Evening",
              groupValue: snapshot.data,
              onChanged: (e)=>bloc.setValue(e),
            ),
            Text(
              'Evening',
              style: new TextStyle(
                fontSize: 16.0,
              ),
            )
          ],
        );
      }
    );
  }

  Widget dateField(Bloc bloc) {
  
    return StreamBuilder(
      stream: bloc.mob,
      builder: (context, snapshot) {
        return   Container();
    );
  }
  
}