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
  final _priceCtrl = TextEditingController();

  final String nonFoundMessage = "0 Plan Found";
  @override
  void initState() {
    super.initState();

    handler = DatabaseHandler();
    _refreshData(0);
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _priceCtrl.dispose();
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
                icon: Icon(Icons.add_rounded))
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
        physics: BouncingScrollPhysics(),
        itemCount: snapshot.data?.length,
        itemBuilder: (BuildContext context, int index) {
          String months = snapshot.data![index].months.toString();
          String price = snapshot.data![index].price.toString();

          return Container(
              height: 140.0,
              child: Card(
                color: Colors.indigo,
                semanticContainer: true,
                margin: EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 32.0, right: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Row(
                  children: [
                    Container(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$months Month Plan",
                                style: TextStyle(
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.w300)),
                            Text("$price \u20B9",
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800)),
                          ],
                        )),
                    Expanded(
                        child: Icon(Icons.check_circle,
                            color: Colors.white, size: 30.0))
                  ],
                ),
              ));
        },
      );
    }
  }

  addPlanDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          _monthCtrl.text = "";
          _priceCtrl.text = "";

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
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormFieldWidget(
                labelText: "Price",
                controller: _priceCtrl,
                autoFocus: true,
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                maxLength: 3,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This field required";
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
                      Plan plan = Plan(
                          months: int.parse(_monthCtrl.text),
                          price: int.parse(_priceCtrl.text));

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
                        MaterialStateProperty.all<Color>(Colors.white),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  child: Text("Add"),
                )))
      ]),
    );
  }
}
