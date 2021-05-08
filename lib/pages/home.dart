import 'package:flutter/material.dart';
import 'package:ppscgym/pages/client/add.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHandler handler = DatabaseHandler();
  Future<List<Client>>? _future;

  @override
  void initState() {
    super.initState();
    this._future = this.handler.retrieveClients();
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
          ),
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
      body: FutureBuilder(
          future: _future,
          builder:
              (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _buildLoader();
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              return _buildDataView(snapshot);
            }
            return _buildNoData();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddUserPage()),
          );
          _future = Future.delayed(Duration(seconds: 2));
          setState(() {});
        },
        child: const Icon(Icons.add_rounded),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDataView(AsyncSnapshot<List<Client>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data?.length,
      itemBuilder: (BuildContext context, int index) {
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
      },
    );
  }

  Widget _buildLoader() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildNoData() {
    return Center(child: Text("No Data Found"));
  }
}
