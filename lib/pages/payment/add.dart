import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class AddPaymentPage extends StatefulWidget {
  final Plan plan;
  AddPaymentPage({Key? key, required this.plan}) : super(key: key);

  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final DateTime todayDate = DateTime.now();
  late DateTime firstDayOfMonthDate;

  late bool _fromToday = false;
  late bool _moneyFromPlan = true;

  late DateTime fromDate = todayDate;
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    firstDayOfMonthDate = DateTime(todayDate.year, todayDate.month, 1);
    setDateCtrls(firstDayOfMonthDate);

    _priceCtrl.text = widget.plan.price.toString();
  }

  void setDateCtrls(DateTime date) {
    _fromCtrl.text = toDDMMYYYY(date);
    _toCtrl.text = toDDMMYYYY(
        DateTime(date.year, date.month + widget.plan.months, date.day));
    fromDate = date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text('Review Payment'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                addWarningDialog();
              }
            },
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //
                // Status
                //

                Text("${widget.plan.months} Month Plan",
                    style:
                        TextStyle(fontSize: 37.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),

                //
                // Switches
                //

                SwitchListTile(
                  title: const Text('From Today'),
                  value: _fromToday,
                  onChanged: (bool value) {
                    setState(() {
                      _fromToday = value;
                      if (value == true) {
                        setDateCtrls(todayDate);
                      } else {
                        setDateCtrls(firstDayOfMonthDate);
                      }
                    });
                  },
                ),
                SizedBox(height: 20),

                //
                // From date
                //

                TextFormFieldWidget(
                  labelText: 'From',
                  enabled: !_fromToday,
                  controller: _fromCtrl,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.text,
                  onTap: () async {
                    // Below line stops keyboard from appearing
                    FocusScope.of(context).requestFocus(new FocusNode());
                    DateTime? date =
                        await pickDate(context, initialDate: fromDate);
                    if (date != null)
                      setState(() {
                        setDateCtrls(date);
                      });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This Field is required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                //
                // To date
                //

                TextFormFieldWidget(
                  enabled: false,
                  labelText: 'To',
                  controller: _toCtrl,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.text,
                ),

                SizedBox(height: 20),

                SwitchListTile(
                  title: const Text('Money From Plan'),
                  value: _moneyFromPlan,
                  onChanged: (bool value) {
                    setState(() {
                      _moneyFromPlan = value;
                      if (_moneyFromPlan == true) {
                        _priceCtrl.text = widget.plan.price.toString();
                      }
                    });
                  },
                ),
                SizedBox(height: 20),

                TextFormFieldWidget(
                  enabled: !_moneyFromPlan,
                  labelText: "Price",
                  controller: _priceCtrl,
                  autoFocus: true,
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  maxLength: 5,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field required";
                    } else if (int.parse(value) > 50000) {
                      return "Max Price set to 50,000\u20B9";
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  addWarningDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25.0),
            ),
            side: BorderSide(
              width: 1.5,
              color: Colors.white10,
            ),
          ),
          backgroundColor: Colors.black87,
          child: Container(
            height: 290,
            color: Colors.transparent,
            child: Padding(padding: EdgeInsets.all(15), child: buildWarning()),
          ),
        );
      },
    );
  }

  Widget buildWarning() {
    return Column(
      children: [
        Center(
            child:
                Icon(Icons.warning, size: 100.0, color: Colors.yellowAccent)),
        SizedBox(height: 10),
        Center(
            child: Text(
          "You Cann't able to edit payment information after your transaction, Tap 'I Agree' to procced.",
          overflow: TextOverflow.visible,
          style: TextStyle(fontSize: 10.0),
        )),
        SizedBox(height: 50),
        Expanded(
          child: Row(
            children: [
              OutlinedButton(
                child: const Text("Close"),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Spacer(),
              OutlinedButton(
                child: const Text("I Agree"),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                ),
                onPressed: null,
              ),
            ],
          ),
        )
      ],
    );
  }
}
