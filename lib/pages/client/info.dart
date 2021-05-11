import 'package:flutter/material.dart';
import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/widgets.dart';

class ClientInfoPage extends StatefulWidget {
  final int clientId;

  const ClientInfoPage({Key? key, required this.clientId}) : super(key: key);

  @override
  _ClientInfoPageState createState() => _ClientInfoPageState();
}

class _ClientInfoPageState extends State<ClientInfoPage> {
  late DatabaseHandler handler;
  late Future<Client> _future;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    _refreshData(2);
  }

  void _refreshData(int seconds) {
    _future = Future<Client>.delayed(
        Duration(seconds: seconds, milliseconds: 100),
        () => handler.retrieveClient(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<Client> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return loaderWidget();
            }
            if (snapshot.hasError) {
              return centerMessageWidget("Error !");
            }
            if (snapshot.hasData) {
              return Center(child: Text(snapshot.data!.name));
            }
            return centerMessageWidget("Client Not Found");
          }),
    );
  }
}
