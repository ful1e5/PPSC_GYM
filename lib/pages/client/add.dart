import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils.dart';

class AddClientPage extends StatefulWidget {
  AddClientPage({Key? key}) : super(key: key);

  @override
  _AddClientPageState createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();

  final List<bool> workoutSessionOptions = [true, false];
  final List<bool> genderOptions = [true, false];
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<String?> insertClient(Client client) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.insertClients([client]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text('Add Client'),
        actions: <Widget>[saveButton()],
      ),
      body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(children: <Widget>[
                  //
                  // Client Gender (default: Male)
                  //

                  ToggleButtons(
                    borderColor: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    children: <Widget>[
                      optionButton("Male"),
                      optionButton("Female"),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        updateOptions(index, genderOptions);
                      });
                    },
                    isSelected: genderOptions,
                  ),
                  SizedBox(height: 40),

                  //
                  // Client Workout Session (default: Morning)
                  //

                  ToggleButtons(
                    borderColor: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    children: <Widget>[
                      optionButton("Morning"),
                      optionButton("Evening"),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        updateOptions(index, workoutSessionOptions);
                      });
                    },
                    isSelected: workoutSessionOptions,
                  ),
                  SizedBox(height: 40),

                  //
                  // Client ID
                  //

                  TextFormFieldWidget(
                      labelText: "Adhar ID",
                      controller: _idCtrl,
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      maxLength: 12,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 12) {
                          return 'Invalid ID';
                        }
                        return null;
                      }),
                  SizedBox(height: 20),

                  //
                  // Client Name
                  //

                  TextFormFieldWidget(
                    labelText: "Name",
                    controller: _nameCtrl,
                    formatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[a-zA-Z\s]*$'))
                    ],
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field is required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  //
                  // Date Of Birth
                  //

                  TextFormFieldWidget(
                      labelText: "Date Of Birth",
                      controller: _dobCtrl,
                      enableInteractiveSelection: false,
                      keyboardType: TextInputType.text,
                      onTap: () async {
                        // Below line stops keyboard from appearing
                        FocusScope.of(context).requestFocus(new FocusNode());
                        DateTime? date = await pickDate(context);
                        if (date != null)
                          setState(
                            () {
                              _dobCtrl.text = toDDMMYYYY(date);
                            },
                          );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "DOB is required";
                        } else if (!is12YearOld(value)) {
                          return "You are not 12 year old";
                        }
                        return null;
                      }),
                  SizedBox(height: 20),

                  //
                  // Client Mob.No.
                  //

                  TextFormFieldWidget(
                    labelText: "Mobile",
                    controller: _mobileCtrl,
                    formatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.length != 10) {
                        return 'Invalid Mobile Number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                ]),
              ))),
    );
  }

  Widget optionButton(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 40.0, right: 40.0),
      child: Text(text),
    );
  }

  void updateOptions(int index, List<bool> options) {
    for (int buttonIndex = 0; buttonIndex < options.length; buttonIndex++) {
      if (buttonIndex == index) {
        options[buttonIndex] = true;
      } else {
        options[buttonIndex] = false;
      }
    }
  }

  Widget saveButton() {
    return IconButton(
      icon: const Icon(Icons.check),
      tooltip: 'Save',
      onPressed: () async {
        // Validate returns true if the form is valid, or false otherwise.
        if (_formKey.currentState!.validate()) {
          final client = Client(
            id: int.parse(_idCtrl.text),
            name: formatName(_nameCtrl.text),
            gender: getGenderString(genderOptions),
            dob: _dobCtrl.text,
            mobile: int.parse(_mobileCtrl.text),
            session: getSessionString(workoutSessionOptions),
          );

          final error = await insertClient(client);
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.red, content: Text(error)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.green, content: Text("Entry Created")));
            Navigator.pop(context, "added");
          }
        }
      },
    );
  }
}
