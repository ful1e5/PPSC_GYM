import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils/validators.dart';
import 'package:ppscgym/utils/date.dart';

class AddUserPage extends StatefulWidget {
  AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  final _dobCtrl = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: const Text('Add Client'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save',
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
              },
            ),
          ],
        ),
        body: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  children: <Widget>[
                    //
                    // Client ID
                    //

                    TextFormFieldWidget(
                      labelText: "Adhar ID",
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      maxLength: 12,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        return validateID(value);
                      },
                    ),
                    SizedBox(height: 20),

                    //
                    // Client Name
                    //

                    TextFormFieldWidget(
                      labelText: "Name",
                      formatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z\s]*$'))
                      ],
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        return checkNotEmpty(value: value);
                      },
                    ),
                    SizedBox(height: 20),

                    //
                    // Date Of Birth
                    //

                    TextFormFieldWidget(
                        controller: _dobCtrl,
                        labelText: "Date Of Birth",
                        keyboardType: TextInputType.text,
                        onTap: () async {
                          // Below line stops keyboard from appearing
                          FocusScope.of(context).requestFocus(new FocusNode());
                          DateTime? date = await pickDate(context);
                          if (date != null)
                            setState(
                              () {
                                _dobCtrl.text = formateDate(date);
                              },
                            );
                        },
                        validator: (value) {
                          return checkNotEmpty(
                              value: value, errorMessage: 'Pick a valid DOB');
                        })
                  ],
                ))));
  }
}
