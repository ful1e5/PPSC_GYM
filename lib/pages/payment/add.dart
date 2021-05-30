import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/styles.dart';
import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils.dart';

class AddPaymentPage extends StatefulWidget {
  final Member member;
  final Plan plan;
  AddPaymentPage({Key? key, required this.member, required this.plan})
      : super(key: key);

  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final formKey = GlobalKey<FormState>();

  final DateTime todayDate = DateTime.now();
  late DateTime firstDayOfMonth;
  late DateTime selectionDefaultDate;

  late bool fromToday = false;
  late bool moneyFromPlan = true;
  late bool addNote = false;

  final startdateCtrl = TextEditingController();
  final enddateCtrl = TextEditingController();
  final moneyCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    firstDayOfMonth = DateTime(todayDate.year, todayDate.month, 1);
    selectionDefaultDate = todayDate;
    setDateCtrls(firstDayOfMonth);

    moneyCtrl.text = widget.plan.money.toString();
  }

  void setDateCtrls(DateTime date) {
    startdateCtrl.text = toDDMMYYYY(date);
    enddateCtrl.text = toDDMMYYYY(
      DateTime(date.year, date.month + widget.plan.months, date.day),
    );
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
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: const Text('Review Payment'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () {
            // Validate returns true if the form is valid, or false otherwise.
            if (formKey.currentState!.validate()) {
              warningDialog();
            }
          },
        )
      ],
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //
              // Status
              //

              Text(
                '${widget.plan.months} Month Plan',
                style: TextStyle(
                  fontSize: 37.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              gapWidget(30.0),

              //
              // Starting date
              //

              SwitchListTile(
                value: fromToday,
                title: const Text('From Today'),
                onChanged: (bool value) {
                  setState(() {
                    fromToday = value;
                    if (value == true) {
                      setDateCtrls(todayDate);
                    } else {
                      setDateCtrls(firstDayOfMonth);
                    }
                  });
                },
              ),
              gapWidget(20.0),

              TextFormFieldWidget(
                enabled: !fromToday,
                labelText: 'Starting Date',
                controller: startdateCtrl,
                enableInteractiveSelection: false,
                keyboardType: TextInputType.text,
                onTap: () async {
                  // Below line stops keyboard from appearing
                  FocusScope.of(context).requestFocus(new FocusNode());
                  DateTime? date = await pickDate(
                    context,
                    initialDate: selectionDefaultDate,
                  );
                  if (date != null) {
                    setState(() {
                      setDateCtrls(date);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This Field is required';
                  } else if (stringToDateTime(value)
                      .isBefore(firstDayOfMonth)) {
                    return 'Date from previous months is not allowed';
                  } else {
                    return null;
                  }
                },
              ),
              gapWidget(20.0),

              //
              // Ending date
              //

              TextFormFieldWidget(
                enabled: false,
                labelText: 'Ending Date',
                controller: enddateCtrl,
                enableInteractiveSelection: false,
                keyboardType: TextInputType.text,
              ),
              gapWidget(20.0),

              SwitchListTile(
                value: moneyFromPlan,
                title: const Text('Money From Plan'),
                onChanged: (bool value) {
                  setState(() {
                    moneyFromPlan = value;
                    if (moneyFromPlan == true) {
                      moneyCtrl.text = widget.plan.money.toString();
                    }
                  });
                },
              ),
              gapWidget(20.0),

              //
              // Money
              //

              TextFormFieldWidget(
                enabled: !moneyFromPlan,
                maxLength: 5,
                labelText: 'Money',
                controller: moneyCtrl,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field required';
                  } else if (int.parse(value) > 50000) {
                    return 'Max Money set to 50,000\u20B9';
                  } else {
                    return null;
                  }
                },
              ),
              gapWidget(20.0),

              //
              // Note
              //

              SwitchListTile(
                value: addNote,
                title: const Text('Add Note'),
                onChanged: (bool value) {
                  setState(() {
                    addNote = value;
                  });
                },
              ),
              gapWidget(20.0),

              TextFormFieldWidget(
                enabled: addNote,
                labelText: 'Note',
                controller: noteCtrl,
                keyboardType: TextInputType.text,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z0-9\s-._]*$'),
                  ),
                ],
                validator: (value) {
                  if (addNote == true && (value == null || value.isEmpty)) {
                    return 'Empty note not allowed.';
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  warningDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40.0)),
          ),
          child: Container(
            height: 310,
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(25.0),
              child: warningDialogView(),
            ),
          ),
        );
      },
    );
  }

  Widget warningDialogView() {
    return Column(
      children: [
        Center(
          child: Icon(
            Icons.privacy_tip_rounded,
            size: 80.0,
          ),
        ),
        gapWidget(15.0),
        Text(
          "You Can't able to edit or delete payment information, "
          "once it's verified by algorithm. "
          "Tap 'Agree' to proceed.",
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.3,
          ),
        ),
        gapWidget(50.0),
        OutlinedButton(
          child: const Text(
            'Agree',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: materialButtonStyle(
            foregroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 12.0),
          ),
          onPressed: () async {
            Payment payment = Payment(
              memberId: widget.member.id,
              months: widget.plan.months,
              startDate: startdateCtrl.text,
              endDate: enddateCtrl.text,
              money: int.parse(moneyCtrl.text),
              note: (addNote == true) ? noteCtrl.text : null,
            );

            await insertPayment(payment);
            successPopup(
              context,
              '${widget.member.name} get ${widget.plan.months} months membership',
            );

            Navigator.pop(context); // Popup Dialog
            Navigator.pop(context, 'payment added'); // Popup Widget
          },
        ),
      ],
    );
  }
}
