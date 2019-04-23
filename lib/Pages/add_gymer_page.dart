import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppscgym/models/gymer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ppscgym/utils/top_bar.dart';
import 'package:ppscgym/utils/input_formatters.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddGymer extends StatefulWidget {

  AddGymer({Key key, this.userId})
      : super(key: key);
  
  final String userId;

  @override
  _AddGymerState createState() => _AddGymerState();
}

class _AddGymerState extends State<AddGymer> {

  TextStyle style = TextStyle(fontFamily: 'Raleway' ,fontSize: 20.0,color: Colors.black);
  TextStyle titleStyle = TextStyle(fontFamily: 'Raleway' ,fontSize: 20.0,color: Colors.black,fontWeight: FontWeight.bold);
  TextStyle hintStyle = TextStyle(fontFamily: 'Raleway',fontSize: 20.0,color: Colors.black38);

  List<Gymer> _gymerList;
  Query _gymerQuery;


  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _adharnumberController = TextEditingController();
  final _moneyController = TextEditingController();
  final _textEditingController =TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  StreamSubscription<Event> _onGymerAddedSubscription;


  bool _setDate;

  String _firstname;
  String _lastname;
  String _adhar;
  String _money;
  String _entryDate;
  String _expireDate;
  DateTime _date = DateTime.now().toLocal();

  @override
  void initState() {
    _setDate=false;
    super.initState();
    _gymerList = List();
    _gymerQuery = _database
        .reference()
        .child("gymer")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onGymerAddedSubscription = _gymerQuery.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    setState(() {
      _gymerList.add(Gymer.fromSnapshot(event.snapshot));
    });
  }

  _addGymer(String gymerFirstName,String gymerLastName) {
    if (gymerFirstName.length > 0 && gymerLastName.length > 0) {

      Gymer todo =  Gymer(gymerFirstName.toString(),gymerLastName.toString(), widget.userId, false);
      _database.reference().child("gymer").push().set(todo.toJson());
    }
  }

  @override
  void dispose() {
    _onGymerAddedSubscription.cancel();
    super.dispose();
  }


  _showDialog(BuildContext context) async {
   
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            content:  Row(
              children: <Widget>[
                 Expanded(child:  TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration:  InputDecoration(
                    labelText: 'FirstName',
                  ),
                  
                ))
              ],
            ),
            actions: <Widget>[
               FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
               FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    _addGymer(_textEditingController.text.toString(),_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
      }
    );
  }

  Widget _showTextInput(String _label, String _hint, _field,Icon _icon,TextEditingController _ctrl) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: _label,
        hintStyle: hintStyle,
        hintText: _hint,
        prefixIcon: _icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
      ),
      controller: _ctrl,
      keyboardType: TextInputType.text,
      style: style,
      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
      onSaved: (value) => _field = value,
    );
  }

   Widget _showAdharNumberInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "AdharCard",
        hintStyle: hintStyle,
        hintText: "XXXX XXXX XXXX",
        prefixIcon: Icon(Icons.assignment_ind,color: Colors.white,),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
      ),
      controller: _adharnumberController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        WhitelistingTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12), 
        AdharCardNumberInputFormatter()
      ],
      style: style,
      validator: (value) => value.isEmpty ? 'Field can\'t be empty' : 0,
      onSaved: (value) => _adhar = value,
    );
  }

  Widget _showMoneyInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Money",
        hintStyle: hintStyle,
        hintText: "XXXX",
        prefixIcon: Icon(Icons.attach_money,color: Colors.white,),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
      ),
      controller: _moneyController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        WhitelistingTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4), 
      ],
      style: style,
      validator: (value) => value.isEmpty ? 'Field can\'t be empty' : 0,
      onSaved: (value) => _money = value,
    );
  }

  Widget _showEntryDateButton() {
    return  Padding(
        padding: EdgeInsets.all(1),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 60.0,
          child:  RaisedButton(
            elevation: 5.0,
            shape:  RoundedRectangleBorder(borderRadius:  BorderRadius.circular(25.0)),
            color: Colors.green,
            child: Text(
              _setDate==true ? '$_entryDate':'Entry Date',
              style:  TextStyle(fontSize: 20.0, color: Colors.white),
            ),
            onPressed: () {DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: DateTime(2019, 1, 1),
              maxTime: DateTime(2019, 31, 12), 
              onConfirm: (date) {
                print('confirm $date'); 
                setState(() {
                  _date=date;
                  _entryDate="${_date.year.toString()}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}";
                  _setDate=true;
                  int _mounth= _date.month+1;
                  _expireDate="${_date.year.toString()}-${_mounth.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}";                });
              }, 
              currentTime: DateTime.now(), locale: LocaleType.en);
            },    
          ),
        )
      );
    }
    
    Widget _showExpireDateButton() {
    return  Padding(
        padding: EdgeInsets.all(1),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 60.0,
          child:  RaisedButton(
            elevation: 5.0,
            shape:  RoundedRectangleBorder(borderRadius:  BorderRadius.circular(25.0)),
            color: Colors.red,
            child: Text(
              _setDate==true ? '$_expireDate':'Expire Date',
              style:  TextStyle(fontSize: 20.0, color: Colors.white),
            ),
            onPressed: () {DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: DateTime(2019, 1, 1),
              maxTime: DateTime(2019, 31, 12), 
              onConfirm: (date) {
                print('confirm $date'); 
                setState(() {
                  _date=date;
                  _expireDate="${_date.year.toString()}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}";
                });
              }, 
              currentTime: DateTime.now(), locale: LocaleType.en);
            },    
          ),
        )
      );
    }
  //TODO: clear
  // _firstNameController.clear();
  // _lastNameController.clear();
  // _adharnumberController.clear();
  // _moneyController.clear();
  Card _buildCard(Column _list,Color _cardColor) {
    return Card(
      semanticContainer: true,
      color: _cardColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      margin: const EdgeInsets.all(15.0),
      child:Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: _list
              ),
            )
          ],
        ),
      )
    );
  }

  PageView _buildCardContent(Column _basicList,Column _moreList) {
    return PageView(
      children: <Widget>[
        Container(
          color: Colors.black,
          child: _buildCard(_basicList,Colors.blueGrey),
        ),
        Container(
          color: Colors.black,
          child:  _buildCard(_moreList,Colors.blueGrey),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADD GYMER"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),
      body: Hero(
        tag: "Add Gymer",
        child: _buildCardContent(
          Column(children: <Widget>[
                _showTextInput("FirstName ", "John", _firstname,Icon(Icons.person,color: Colors.white,),_firstNameController),
                SizedBox(height: 20.0),
                _showTextInput("LastName ", "Liccon", _lastname,Icon(Icons.group,color: Colors.white,),_lastNameController),
                SizedBox(height: 20.0),
              ],
            ),
          Column(children: <Widget>[
              _showAdharNumberInput(),
                SizedBox(height: 20.0),
                _showMoneyInput(),
                SizedBox(height: 20.0),
                _showEntryDateButton(),
                SizedBox(height: 20.0),
                _showExpireDateButton(),
                SizedBox(height: 10.0),
            ],
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 1.0,
          child: Icon(Icons.save),
          onPressed: (){print("save");},
      ),
    );
  }
}