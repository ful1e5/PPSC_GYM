import 'package:flutter/material.dart';
import 'package:ppscgym/widgets/textformfield.dart';

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
                    TextFormFieldWidget(
                      labelText: "Adhar ID",
                      maxLength: 12,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 12) {
                          return 'Invalid ID';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormFieldWidget(
                      labelText: "Name",
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormFieldWidget(
                        controller: _dobCtrl,
                        labelText: "Date Of Birth",
                        keyboardType: TextInputType.text,
                        onTap: () async {
                          // Below line stops keyboard from appearing
                          FocusScope.of(context).requestFocus(new FocusNode());

                          final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1975),
                              lastDate: DateTime(2024));

                          if (date != null)
                            setState(
                              () {
                                _dobCtrl.text =
                                    "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString()}";
                              },
                            );
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required!';
                          }
                          return null;
                        })
                  ],
                ))));
  }
}
