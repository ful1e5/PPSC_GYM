import 'package:flutter/material.dart';
import 'package:ppscgym/widgets/textformfield.dart';

class AddUserPage extends StatefulWidget {
  AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: const Text('Add User'),
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
                      labelText: "Adhar ID", keyboardType: TextInputType.number)
                ],
              ),
            )));
  }
}
