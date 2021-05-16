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

  final todayDate = DateTime.now();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fromCtrl.text = toDDMMYYYY(todayDate);
    _toCtrl.text = getToDate(todayDate);
  }

  String getToDate(DateTime date) {
    return toDDMMYYYY(
        DateTime(date.year, date.month + widget.plan.months, date.day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text('Review Plan'),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              children: <Widget>[
                //
                // From date
                //

                TextFormFieldWidget(
                  labelText: 'From',
                  controller: _fromCtrl,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.text,
                  onTap: () async {
                    // Below line stops keyboard from appearing
                    FocusScope.of(context).requestFocus(new FocusNode());
                    DateTime? date = await pickDate(context);
                    if (date != null)
                      setState(() {
                        _fromCtrl.text = toDDMMYYYY(date);
                        _toCtrl.text = getToDate(date);
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
