import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppscgym/models/gymer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ppscgym/utils/input_formatters.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ppscgym/utils/fab_button.dart';

class AddGymer extends StatefulWidget {

  AddGymer({Key key, this.userId})
      : super(key: key);
  
  final String userId;

  @override
  _AddGymerState createState() => _AddGymerState();
}

class _AddGymerState extends State<AddGymer> {

  //Text Styling
  TextStyle style = TextStyle(fontFamily: 'Raleway' ,fontSize: 20.0,color: Colors.white);
  TextStyle dropStyle = TextStyle(fontFamily: 'Raleway' ,fontSize: 20.0,color: Colors.black);
  TextStyle hintStyle = TextStyle(fontFamily: 'Raleway',fontSize: 20.0,color: Colors.white30);

  //Animated paging Controll
  final PageController controller = new PageController();
  //Set Curret index to 0
  int currentIndex = 0;

  //Model List
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


  //Flags
  //for auto genrating _expire_date
  bool _setDate;

  //Data
  //TODO : Inherite from Model
  String _firstname;
  String _lastname;
  String _adhar;
  String _money;
  String _joinDate;
  String _expireDate;
  String _session;
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
    _refresh();
    _onGymerAddedSubscription.cancel();
    super.dispose();
  }

  //TODO : Remove ZombieCode after build proper dialog
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

  //zombiecode till Here


  // Custom Widgets For Form
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


  Widget _showSession(){
    return Padding(
      padding: EdgeInsets.all(1),
      child: SizedBox(
        width: 150.0,
        height: 70.0,
        child: Card(
          elevation: 5.0,
          shape:  RoundedRectangleBorder(borderRadius:  BorderRadius.circular(25.0)),
          color: Colors.white,
          child:Center(
            child: DropdownButton<String>(
              style: dropStyle,
              hint: (_session==null)?Text("Session",style: TextStyle(color: Colors.black),) : Text("$_session",style: TextStyle(color: Colors.black),) ,
              iconSize: 20,
              value: _session,
              onChanged: (String newValue) {
                setState(() {
                  _session = newValue;
                });
              },
              items: <String>['Morning', 'Evening']
                .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: TextStyle(color: Colors.black),),
                  );
                })
                .toList(),
            )
          )
        )
      )
    );
  }

  Widget _showAdharNumberInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "AdharCard",
        hintStyle: style,
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

  Widget _showJoinDateButton() {
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
            _setDate==true ? '$_joinDate':'Join Date',
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
                _joinDate="${_date.day.toString().padLeft(2,'0')}-${_date.month.toString().padLeft(2,'0')}-${_date.year.toString()}";
                _setDate=true;
                int _mounth= _date.month+1;
                _expireDate="${_date.day.toString().padLeft(2,'0')}-${_mounth.toString().padLeft(2,'0')}-${_date.year.toString()}";                });
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
          color: Colors.redAccent,
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
                _expireDate="${_date.day.toString().padLeft(2,'0')}-${_date.month.toString().padLeft(2,'0')}-${_date.year.toString()}";
              });
            }, 
            currentTime: DateTime.now(), locale: LocaleType.en);
          },    
        ),
      )
    );
  }

  //Methods Here
  void  _refresh(){
    _firstNameController.clear();
    _lastNameController.clear();
    _adharnumberController.clear();
    _moneyController.clear();
    setState(() {
      _session=null;  
      _setDate=false;
      if(currentIndex==1){
        currentIndex--;
        controller.animateToPage(currentIndex, 
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn);
      }
    });
  }
  

  Container _buildCard(Column _list) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.circular(25),
        color: const Color(0xFF141E30),
      ),
      child:Form(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              child:Padding(
                padding: const EdgeInsets.all(32.0),
                child: _list
              )
            ),
          ],
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    //controllable fab 
    var customFabButton;
    if(currentIndex == 0){
      customFabButton = CustomFabButton(
        icon: Icons.navigate_next,
        onPressed: () =>{
          setState(() {
            currentIndex++;
            controller.animateToPage(currentIndex, 
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInCubic);
          })
        },
        color: Colors.white
      );
    }else{
      customFabButton = CustomFabButton(icon: Icons.save,color: Colors.white);
    }

    //return main form
    return Scaffold(
      appBar: AppBar(
        title: Text("ADD GYMER"),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0.0,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          IconButton(
          icon: Icon(Icons.refresh),
          tooltip: 'Refresh Form',
          onPressed: () {
            _refresh();
            print('Form is Refreshed.');
          },
        ),
        ],
      ),
      body:PageView(
        onPageChanged: (index){
          setState(() {
            currentIndex=index;
          });
        },
        controller: controller,
        children: <Widget>[
          Container(
            color: Colors.red,
            child: _buildCard(Column(
              children: <Widget>[
                _showTextInput("FirstName ", "John", _firstname,Icon(Icons.person,color: Colors.white,),_firstNameController),
                SizedBox(height: 20.0),
                _showTextInput("LastName ", "Liccon", _lastname,Icon(Icons.group,color: Colors.white,),_lastNameController),
                SizedBox(height: 20.0),
                _showSession(),
                SizedBox(height: 20.0),
              ],
            ))
          ),
          Container(
            color: Colors.red,
            child:  _buildCard(Column(
              children: <Widget>[
                _showAdharNumberInput(),
                SizedBox(height: 20.0),
                _showMoneyInput(),
                SizedBox(height: 70.0),
                _showJoinDateButton(),
                SizedBox(height: 20.0),
                _showExpireDateButton(),
                SizedBox(height: 10.0),
              ],
            ))
          )
        ],
      ),
      floatingActionButton: customFabButton,
    );
  }
}