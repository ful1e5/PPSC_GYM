import 'package:flutter/material.dart';
import 'package:ppscgym/widgets.dart';
import 'package:flutter/services.dart';

class PlansPage extends StatefulWidget {
  PlansPage({Key? key}) : super(key: key);

  @override
  _PlansPageState createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Customize Plans'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [addPlanButton()],
        ),
      ),
    );
  }

  Widget addPlanButton() {
    return Container(
      alignment: Alignment.center,
      height: 100.0,
      child: OutlinedButton(
        onPressed: () {
          addPlanDialog();
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.all(15.0)),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
        ),
        child: Text(" Add Plan",
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      ),
    );
  }

  addPlanDialog() {
    // BuildContext dialogContext;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // dialogContext = context;

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
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextFormFieldWidget(
                          labelText: "Months",
                          formatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                          ),
                          child: Text("add"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
