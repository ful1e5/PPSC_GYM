import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/widgets.dart';

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

  Future<String?> updatePlan(Plan plan) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.updatePlan(plan);
  }

  Future<void> deletePlan(int id) async {
    final DatabaseHandler handler = DatabaseHandler();
    await handler.deletePlan(id);
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
            icon: Icon(Icons.add_rounded),
          )
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<Plan>> snapshot) {
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
        },
      ),
    );
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
                                fontSize: 27.0, fontWeight: FontWeight.w300)),
                        Text("$price \u20B9",
                            style: TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () {
                        addPlanDialog(oldData: snapshot.data![index]);
                      },
                      icon: Icon(Icons.edit, color: Colors.white, size: 25.0),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }

  addPlanDialog({Plan? oldData}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
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
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: buildForm(oldData: oldData)),
            ),
          );
        });
  }

  Widget buildForm({Plan? oldData}) {
    if (oldData != null) {
      _monthCtrl.text = oldData.months.toString();
      _priceCtrl.text = oldData.price.toString();
    } else {
      _monthCtrl.text = "";
      _priceCtrl.text = "";
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
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
                },
              ),
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
                maxLength: 5,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This field required";
                  } else if (int.parse(value) > 50000) {
                    return "Max Price set to 50,000\u20B9";
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                oldData != null ? deleteButton(oldData) : Container(),
                Spacer(),
                OutlinedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      late Plan plan;
                      late String? error;

                      if (oldData != null) {
                        plan = Plan(
                            id: oldData.id,
                            months: int.parse(_monthCtrl.text),
                            price: int.parse(_priceCtrl.text));
                        error = await updatePlan(plan);
                      } else {
                        plan = Plan(
                            months: int.parse(_monthCtrl.text),
                            price: int.parse(_priceCtrl.text));
                        error = await insertPlan(plan);
                      }

                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red, content: Text(error)));
                      } else {
                        if (oldData != null) {
                          if (!mapEquals(oldData.toMap(), plan.toMap())) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.orange,
                                content: Text("Plan Edited")));

                            setState(() {
                              _refreshData(0);
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("Plan Created")));

                          setState(() {
                            _refreshData(0);
                          });
                        }
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
                  child: (oldData != null)
                      ? const Text("Update")
                      : const Text("Add"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget deleteButton(Plan plan) {
    return OutlinedButton(
        onPressed: () async {
          await deletePlan(plan.id ?? 0);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text("${plan.months} Plan Deleted")));

          setState(() {
            _refreshData(0);
          });
          Navigator.pop(context);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
        ),
        child: const Text("Delete"));
  }
}
