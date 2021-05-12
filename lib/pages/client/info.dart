import 'package:flutter/material.dart';
import 'package:ppscgym/pages/client/add.dart';

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
    _refreshData(0);
  }

  void _refreshData(int seconds) {
    _future = Future<Client>.delayed(
        Duration(seconds: seconds, microseconds: 10),
        () => handler.retrieveClient(widget.clientId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: "Edit",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddClientPage()),
              );
            },
            icon: Icon(Icons.edit),
          )
        ],
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
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(children: [
                  clientInfo(snapshot),
                ]),
              );
            }
            return centerMessageWidget("Client Data Found");
          }),
    );
  }

  Widget clientInfo(AsyncSnapshot<Client> snapshot) {
    final String id = snapshot.data!.id.toString();
    final String name = snapshot.data!.name;
    final String gender = snapshot.data!.gender;
    final String session = snapshot.data!.session;
    final String dob = snapshot.data!.dob.toString();
    final String mobile = snapshot.data!.mobile.toString();

    return Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: name,
                        style: TextStyle(
                            fontSize: 34.0, fontWeight: FontWeight.bold)),
                    WidgetSpan(
                        child: Icon(getGenderIconData(gender),
                            size: 34.0,
                            color:
                                gender == "Male" ? Colors.blue : Colors.pink)),
                  ]),
                ),
                Divider(height: 10.0, color: Colors.transparent),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child:
                            Icon(Icons.tag, size: 16.0, color: Colors.white70)),
                    TextSpan(
                      text: id,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                ),
                Divider(height: 20.0, color: Colors.transparent),
                cardGroup([
                  infoCard(Text("6 Months", style: TextStyle(fontSize: 20.0)),
                      "Plan"), //TODO: dynamic
                  infoCard(Text("3", style: TextStyle(fontSize: 20.0)),
                      "Plans Expired"), //TODO: dynamic
                ], 15.6),
                Divider(height: 10.0, color: Colors.transparent),
                cardGroup([
                  infoCard(Icon(Icons.contact_phone, size: 25.0), mobile),
                  infoCard(Icon(Icons.timelapse, size: 25.0), session),
                  infoCard(Icon(Icons.cake, size: 25.0), dob),
                ], 15.6)
              ]),
        ));
  }

  Widget infoCard(Widget symbol, String info) {
    return Column(children: [
      symbol,
      Divider(color: Colors.transparent, height: 5.0),
      Text(info,
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: Colors.white70)),
    ]);
  }

  Widget cardGroup(List<Widget> children, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children
          .map((c) => Container(
                padding: EdgeInsets.all(spacing),
                child: c,
              ))
          .toList(),
    );
  }
}
