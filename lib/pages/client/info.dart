import 'package:flutter/material.dart';

import 'package:ppscgym/widgets.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

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
    _refreshData(1);
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
      appBar: AppBar(backgroundColor: Colors.black),
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
              final String clientId = snapshot.data!.id.toString();
              return Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 8.0),
                          Text(
                            snapshot.data!.name,
                            style: TextStyle(
                                fontSize: 34.0, fontWeight: FontWeight.bold),
                          ),
                          Divider(height: 10.0, color: Colors.transparent),
                          RichText(
                            text: TextSpan(children: [
                              WidgetSpan(
                                child: Icon(Icons.tag,
                                    size: 16.0, color: Colors.white70),
                              ),
                              TextSpan(
                                text: clientId,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          )
                        ]),
                  ));
            }
            return centerMessageWidget("Client Not Found");
          }),
    );
  }
}
