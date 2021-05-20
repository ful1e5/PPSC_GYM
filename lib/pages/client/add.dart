import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class AddClientPage extends StatefulWidget {
  final Client? data;
  AddClientPage({Key? key, this.data}) : super(key: key);

  @override
  _AddClientPageState createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();

  late List<bool> sessionOptions;
  late List<bool> genderOptions;
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    setDefaultInfo();
  }

  void setDefaultInfo() {
    if (widget.data != null) {
      idCtrl.text = widget.data!.id.toString();
      nameCtrl.text = widget.data!.name;
      dobCtrl.text = widget.data!.dob;
      mobileCtrl.text = widget.data!.mobile.toString();

      sessionOptions =
          (widget.data!.session == "Morning") ? [true, false] : [false, true];
      genderOptions =
          (widget.data!.gender == "Male") ? [true, false] : [false, true];
    } else {
      sessionOptions = [true, false];
      genderOptions = [true, false];
    }
  }

  @override
  void dispose() {
    super.dispose();
    idCtrl.dispose();
    nameCtrl.dispose();
    dobCtrl.dispose();
    mobileCtrl.dispose();
  }

  // Database Methods
  insertClient(Client client) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.insertClient(client);
  }

  updateClient(Client client) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.updateClient(client);
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
      title: (widget.data != null)
          ? const Text("Edit Client")
          : const Text('Add Client'),
      actions: <Widget>[
        saveButton(),
      ],
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            children: <Widget>[
              //
              // Client Gender (default: Male)
              //

              ToggleButtons(
                isSelected: genderOptions,
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
              ),
              SizedBox(height: 40),

              //
              // Client Workout Session (default: Morning)
              //

              ToggleButtons(
                isSelected: sessionOptions,
                borderColor: Colors.white10,
                borderRadius: BorderRadius.circular(14),
                children: <Widget>[
                  optionButton("Morning"),
                  optionButton("Evening"),
                ],
                onPressed: (int index) {
                  setState(() {
                    updateOptions(index, sessionOptions);
                  });
                },
              ),
              SizedBox(height: 40),

              //
              // Client ID
              //

              TextFormFieldWidget(
                enabled: (widget.data != null) ? false : true,
                maxLength: 12,
                labelText: "Adhar ID",
                controller: idCtrl,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 12) {
                    return 'Invalid ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              //
              // Client Name
              //

              TextFormFieldWidget(
                labelText: "Name",
                controller: nameCtrl,
                keyboardType: TextInputType.text,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z\s]*$'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This field is required";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 20),

              //
              // Date Of Birth
              //

              TextFormFieldWidget(
                controller: dobCtrl,
                labelText: "Date Of Birth",
                enableInteractiveSelection: false,
                keyboardType: TextInputType.text,
                onTap: () async {
                  DateTime? date = await pickDate(context);
                  if (date != null) {
                    setState(() {
                      dobCtrl.text = toDDMMYYYY(date);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "DOB is required";
                  } else if (!is12YearOld(value)) {
                    return "You are not 12 year old";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 20),

              //
              // Client Mob.No.
              //

              TextFormFieldWidget(
                maxLength: 10,
                labelText: "Mobile",
                controller: mobileCtrl,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 10) {
                    return 'Invalid Mobile Number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
            id: int.parse(idCtrl.text),
            name: formatName(nameCtrl.text),
            gender: getGenderString(genderOptions),
            dob: dobCtrl.text,
            mobile: int.parse(mobileCtrl.text),
            session: getSessionString(sessionOptions),
          );

          late String? error;
          if (widget.data != null) {
            error = await updateClient(client);
          } else {
            error = await insertClient(client);
          }

          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.red, content: Text(error)));
          } else {
            if ((widget.data != null)) {
              if (!mapEquals(widget.data!.toMap(), client.toMap()))
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.amber,
                    content: Text("Entry Updated")));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Entry Created")));
            }
            Navigator.pop(context, "added");
          }
        }
      },
    );
  }
}
