import 'package:flutter/material.dart';

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
  late bool _fromToday = true;

  late DateTime fromDate = todayDate;
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    firstDayOfMonthDate = DateTime(todayDate.year, todayDate.month, 1);
    setDateCtrls(todayDate);
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
        actions: <Widget>[],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
