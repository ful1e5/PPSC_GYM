import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

class AddPaymentPage extends StatefulWidget {
  final int clientId;
  final Plan plan;
  AddPaymentPage({Key? key, required this.clientId, required this.plan})
      : super(key: key);

  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final DateTime todayDate = DateTime.now();
  late DateTime firstDayOfMonthDate;

  late bool _fromToday = false;
  late bool _moneyFromPlan = true;
  late bool _addNote = false;

  late DateTime selectionDefaultDate = todayDate;
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _moneyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    firstDayOfMonthDate = DateTime(todayDate.year, todayDate.month, 1);
    setDateCtrls(firstDayOfMonthDate);

    _moneyCtrl.text = widget.plan.price.toString();
  }

  void setDateCtrls(DateTime date) {
    _startDateCtrl.text = toDDMMYYYY(date);
    _endDateCtrl.text = toDDMMYYYY(
        DateTime(date.year, date.month + widget.plan.months, date.day));
    selectionDefaultDate = date;
  }

  Future<void> insertPayment(Payment payment) async {
    final DatabaseHandler handler = DatabaseHandler();
    await handler.insertPayment(payment);
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

                Text('${widget.plan.months} Month Plan',
                    style:
                        TextStyle(fontSize: 37.0, fontWeight: FontWeight.bold)),
                gapWidget(30.0),

                //
                // Starting date
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
                gapWidget(20.0),

                TextFormFieldWidget(
                  labelText: 'Starting Date',
                  enabled: !_fromToday,
                  controller: _startDateCtrl,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.text,
                  onTap: () async {
                    // Below line stops keyboard from appearing
                    FocusScope.of(context).requestFocus(new FocusNode());
                    DateTime? date = await pickDate(context,
                        initialDate: selectionDefaultDate);
                    if (date != null)
                      setState(() {
                        setDateCtrls(date);
                      });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This Field is required';
                    } else if (stringToDateTime(value)
                        .isBefore(firstDayOfMonthDate)) {
                      return 'Date from previous months is not allowed';
                    }
                    return null;
                  },
                ),
                gapWidget(20.0),

                //
                // Ending date
                //

                TextFormFieldWidget(
                  enabled: false,
                  labelText: 'Ending Date',
                  controller: _endDateCtrl,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.text,
                ),
                gapWidget(20.0),

                SwitchListTile(
                  title: const Text('Money From Plan'),
                  value: _moneyFromPlan,
                  onChanged: (bool value) {
                    setState(() {
                      _moneyFromPlan = value;
                      if (_moneyFromPlan == true) {
                        _moneyCtrl.text = widget.plan.price.toString();
                      }
                    });
                  },
                ),
                gapWidget(20.0),

                //
                // Money
                //

                TextFormFieldWidget(
                  enabled: !_moneyFromPlan,
                  labelText: 'Money',
                  controller: _moneyCtrl,
                  autoFocus: true,
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  maxLength: 5,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field required';
                    } else if (int.parse(value) > 50000) {
                      return 'Max Price set to 50,000\u20B9';
                    }
                    return null;
                  },
                ),
                gapWidget(20.0),

                //
                // Note
                //

                SwitchListTile(
                  title: const Text('Add Note'),
                  value: _addNote,
                  onChanged: (bool value) {
                    setState(() {
                      _addNote = value;
                    });
                  },
                ),
                gapWidget(20.0),

                TextFormFieldWidget(
                    labelText: 'Note',
                    enabled: _addNote,
                    controller: _noteCtrl,
                    formatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z0-9\s-._]*$'),
                      ),
                    ],
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (_addNote == true &&
                          (value == null || value.isEmpty)) {
                        return 'Empty note not allowed.';
                      }
                      return null;
                    }),
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
            height: 300,
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
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(14.0),
          child: Text(
            "You Can't able to edit or delete payment information, once it's verified by algorithm. Tap 'I Agree' to proceed.",
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 12.0, wordSpacing: 2.0),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              OutlinedButton(
                child: const Text('Close'),
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
                  child: const Text('I Agree'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: () async {
                    Payment payment = Payment(
                        clientId: widget.clientId,
                        months: widget.plan.months,
                        startDate: _startDateCtrl.text,
                        endDate: _endDateCtrl.text,
                        money: int.parse(_moneyCtrl.text),
                        note: (_addNote == true) ? _noteCtrl.text : null);

                    await insertPayment(payment);

                    //TODO: use widgets popups
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.green,
                        content:
                            Text('${widget.plan.months} Months Plan Active')));

                    Navigator.pop(context); // Popup Dialog

                    // TODO: 'payment added'
                    Navigator.pop(context, 'added'); // Popup Widget
                  }),
            ],
          ),
        )
      ],
    );
  }
}
