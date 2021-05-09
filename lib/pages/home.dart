import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ppscgym/pages/client/add.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

// Styling
final TextStyle textStyle = TextStyle(
    fontSize: 16.0, color: Colors.white12, fontWeight: FontWeight.bold);

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late DatabaseHandler handler;
  late Future<List<Client>> _future;

  @override
  void initState() {
    super.initState();

    handler = DatabaseHandler();
    _refreshData(3);
  }

  void _refreshData(int seconds) {
    _future = Future<List<Client>>.delayed(
        Duration(seconds: seconds, milliseconds: 100),
        () => handler.retrieveClients());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Menu',
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Menu')));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: () async {
            setState(() {
              _refreshData(2);
            });
            return;
          },
          child: FutureBuilder(
              future: _future,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _buildLoader();
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error !", style: textStyle));
                }
                if (snapshot.hasData) {
                  return _buildListView(snapshot);
                }
                return _buildNoData();
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? newClient = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserPage()),
          );

          if (newClient == "added") {
            setState(() {
              _refreshData(0);
            });
          }
        },
        child: const Icon(Icons.add_rounded),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildLoader() {
    return Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildNoData() {
    return Center(child: Text("No Records Found", style: textStyle));
  }

  Widget _buildListView(AsyncSnapshot<List<Client>> snapshot) {
    if (snapshot.data?.length == 0) {
      return _buildNoData();
    } else {
      return ListView.builder(
        itemCount: snapshot.data?.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildItem(snapshot, index);
        },
      );
    }
  }

  Widget _buildItem(AsyncSnapshot<List<Client>> snapshot, int index) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.all(10),
      semanticContainer: true,
      child: ListTile(
        leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: const Icon(Icons.info, size: 35, color: Colors.white54)),
        title: Text(snapshot.data![index].name,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
