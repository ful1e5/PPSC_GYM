import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/widgets.dart';
import 'package:flutter/services.dart';

class PlansPage extends StatefulWidget {
  PlansPage({Key? key}) : super(key: key);

  @override
  _PlansPageState createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late DatabaseHandler handler;
  late Future<List<Plan>> _future;

  final _formKey = GlobalKey<FormState>();
  final _monthCtrl = TextEditingController();

  final String nonFoundMessage = "0 Plan Found";
  @override
  void initState() {
    super.initState();

    handler = DatabaseHandler();
    _refreshData(2);
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    super.dispose();
  }

  void _refreshData(int seconds) {
    _future = Future<List<Plan>>.delayed(
        Duration(seconds: seconds, milliseconds: 100),
        () => handler.retrievePlans());
  }

  Future<String?> insertPlan(Plan plan) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.insertPlan(plan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text('Customize Plans'),
          actions: [
            IconButton(
                onPressed: () {
                  addPlanDialog();
                },
                icon: Icon(Icons.add_chart))
          ],
        ),
        body: FutureBuilder(
            future: _future,
            builder:
                (BuildContext context, AsyncSnapshot<List<Plan>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return loaderWidget();
              }
              if (snapshot.hasError) {
                return centerMessageWidget("Error !");
              }
              if (snapshot.hasData) {
                return _buildListView(snapshot);
              }
              return centerMessageWidget(nonFoundMessage);
            }));
  }

  Widget _buildListView(AsyncSnapshot<List<Plan>> snapshot) {
    if (snapshot.data?.length == 0) {
      return centerMessageWidget(nonFoundMessage);
    } else {
      return ListView.builder(
        itemCount: snapshot.data?.length,
        itemBuilder: (BuildContext context, int index) {
          String months = snapshot.data![index].months.toString();
          return Container(
            height: 500.0,
            child: Card(
              color: Colors.blue,
              semanticContainer: true,
              margin: EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  RichText(
                      text:
                          TextSpan(style: TextStyle(fontSize: 28.0), children: [
                    TextSpan(
                        text: months,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: " Months")
                  ]))
                ],
              ),
            ),
          );
        },
      );
    }
  }

  addPlanDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          _monthCtrl.text = "";

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25.0),
              ),
              side: BorderSide(
                width: 3.0,
                color: Colors.white70,
              ),
            ),
            backgroundColor: Colors.black,
            child: Container(
              height: 200,
              color: Colors.transparent,
              child: Padding(padding: EdgeInsets.all(20), child: buildForm()),
            ),
          );
        });
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(children: [
        SizedBox(height: 20),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormFieldWidget(
                labelText: "Months",
                controller: _monthCtrl,
                autoFocus: true,
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                maxLength: 2,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This field required";
                  } else if (int.parse(value) > 12) {
                    return "Maximum limit is 12 months";
                  }
                  return null;
                }),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Plan plan = Plan(months: int.parse(_monthCtrl.text));

                      final String? error = await insertPlan(plan);

                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red, content: Text(error)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("Plan Created")));
                        setState(() {
                          _refreshData(0);
                        });
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  child: Text("Add"),
                )))
      ]),
    );
  }
}
