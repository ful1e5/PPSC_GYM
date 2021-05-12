import 'package:flutter/material.dart';

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
        body: Container());
  }
}
