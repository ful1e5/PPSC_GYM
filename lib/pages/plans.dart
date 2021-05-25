import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/pages/payment/add.dart';

import 'package:ppscgym/styles.dart';
import 'package:ppscgym/widgets.dart';

class PlansPage extends StatefulWidget {
  final bool? select;
  final int? memberId;
  PlansPage({Key? key, this.select, this.memberId}) : super(key: key);

  @override
  _PlansPageState createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late bool select;
  late Future<List<Plan>> future;

  final formKey = GlobalKey<FormState>();
  final monthCtrl = TextEditingController();
  final moneyCtrl = TextEditingController();

  final String nonFoundMessage = '0 Plan Found';

  @override
  void initState() {
    super.initState();
    select = widget.select != null && widget.select != false ? true : false;
    refreshPlanData(0);
  }

  @override
  void dispose() {
    monthCtrl.dispose();
    moneyCtrl.dispose();
    super.dispose();
  }

  refreshPlanData(int seconds) {
    final DatabaseHandler handler = DatabaseHandler();
    future = Future<List<Plan>>.delayed(
      Duration(seconds: seconds, milliseconds: 100),
      () => handler.retrievePlans(),
    );
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
      backgroundColor: Colors.black,
      centerTitle: true,
      title:
          (select) ? const Text('Select Plan') : const Text('Customize Plans'),
      actions: (select)
          ? null
          : [
              IconButton(
                icon: Icon(Icons.add_rounded),
                tooltip: 'New Plan',
                onPressed: () {
                  planDialog();
                },
              )
            ],
    );
  }

  Widget buildBody() {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<List<Plan>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loaderWidget();
        } else if (snapshot.hasError) {
          return centerMessageWidget('Error !');
        } else if (snapshot.hasData) {
          if (snapshot.data?.length == 0) {
            return centerMessageWidget(nonFoundMessage);
          } else {
            List<Plan> plans = snapshot.data!;
            return listPlans(plans);
          }
        } else {
          return centerMessageWidget(nonFoundMessage);
        }
      },
    );
  }

  Widget listPlans(List<Plan> plansData) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: plansData.length,
      itemBuilder: (BuildContext context, int index) {
        Plan plan = plansData[index];
        String months = plan.months.toString();
        String money = plan.money.toString();

        return Container(
          height: 140.0,
          child: GestureDetector(
            onTap: () async => await onPlanTap(plan),
            child: Card(
              color: Colors.blue,
              semanticContainer: true,
              margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$months Month Plan',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          '$money \u20B9',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  planEditButton(plan),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onPlanTap(Plan plan) async {
    if (select) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPaymentPage(
            plan: plan,
            memberId: widget.memberId!,
          ),
        ),
      );
      Navigator.pop(context, result);
    }
  }

  Widget planEditButton(Plan plan) {
    if (!select) {
      return Expanded(
        child: IconButton(
          icon: Icon(
            Icons.edit,
            color: Colors.white,
            size: 25.0,
          ),
          onPressed: () {
            planDialog(oldData: plan);
          },
        ),
      );
    } else {
      return Container();
    }
  }

  planDialog({Plan? oldData}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            side: BorderSide(width: 1.5, color: Colors.white10),
          ),
          child: Container(
            height: 300,
            color: Colors.transparent,
            padding: EdgeInsets.all(20),
            child: buildPlanForm(oldData: oldData),
          ),
        );
      },
    );
  }

  Widget buildPlanForm({Plan? oldData}) {
    if (oldData != null) {
      monthCtrl.text = oldData.months.toString();
      moneyCtrl.text = oldData.money.toString();
    } else {
      monthCtrl.text = '';
      moneyCtrl.text = '';
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          gapWidget(10.0),

          //
          // Months
          //
          TextFormFieldWidget(
            maxLength: 2,
            autoFocus: true,
            labelText: 'Months',
            controller: monthCtrl,
            keyboardType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field required';
              } else if (int.parse(value) == 0) {
                return 'Not A Valid  Count';
              } else if (int.parse(value) > 12) {
                return 'Maximum limit is 12 months';
              }
              return null;
            },
          ),
          gapWidget(20.0),

          //
          // Money
          //

          TextFormFieldWidget(
            maxLength: 5,
            autoFocus: true,
            labelText: 'Money',
            controller: moneyCtrl,
            keyboardType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field required';
              } else if (int.parse(value) == 0) {
                return 'Not A Valid Count';
              } else if (int.parse(value) > 50000) {
                return 'Max Money is set to 50,000\u20B9';
              }
              return null;
            },
          ),
          gapWidget(30.0),

          //
          // Actions
          //

          dialogActions(oldData),
        ],
      ),
    );
  }

  Widget dialogActions(Plan? oldData) {
    late Widget deleteButton;

    if (oldData == null) {
      deleteButton = Container();
    } else {
      deleteButton = OutlinedButton(
        child: const Text('Delete'),
        style: materialButtonStyle(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
        ),
        onPressed: () async => await handleDelete(oldData),
      );
    }

    return Row(
      children: [
        deleteButton,
        Spacer(),
        OutlinedButton(
          child: (oldData != null) ? const Text('Update') : const Text('Add'),
          style: materialButtonStyle(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () async => await planAction(oldData),
        ),
      ],
    );
  }

  deletePlan(int id) async {
    final DatabaseHandler handler = DatabaseHandler();
    await handler.deletePlan(id);
  }

  Future<void> handleDelete(Plan plan) async {
    await deletePlan(plan.id ?? 0);
    successPopup(context, '${plan.months} Plan Deleted');

    setState(() {
      refreshPlanData(0);
    });
    Navigator.pop(context);
  }

  insertPlan(Plan plan) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.insertPlan(plan);
  }

  updatePlan(Plan plan) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.updatePlan(plan);
  }

  Future<void> planAction(Plan? oldData) async {
    if (formKey.currentState!.validate()) {
      late Plan plan;
      late String? error;

      if (oldData != null) {
        plan = Plan(
          id: oldData.id,
          months: int.parse(monthCtrl.text),
          money: int.parse(moneyCtrl.text),
        );
        error = await updatePlan(plan);
      } else {
        plan = Plan(
          months: int.parse(monthCtrl.text),
          money: int.parse(moneyCtrl.text),
        );
        error = await insertPlan(plan);
      }

      if (error != null) {
        errorPopup(context, error);
      } else {
        if (oldData != null) {
          if (!mapEquals(oldData.toMap(), plan.toMap())) {
            infoPopup(context, 'Plan Edited');
            setState(() {
              refreshPlanData(0);
            });
          }
        } else {
          successPopup(context, 'Plan Created');
          setState(() {
            refreshPlanData(0);
          });
        }
        Navigator.pop(context);
      }
    }
  }
}
