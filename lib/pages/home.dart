import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ppscgym/pages/plans.dart';

import 'package:ppscgym/widgets.dart';

import 'package:ppscgym/pages/client/add.dart';
import 'package:ppscgym/pages/client/info.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseHandler handler;
  late Future<List<Client>> _future;

  late Map<int, bool> selectedFlag;
  late bool isSelectionMode;

  final String nonFoundMessage = "No Records Found";

  @override
  void initState() {
    super.initState();

    handler = DatabaseHandler();
    _refreshData(3);
    _resetSelection();
  }

  void _resetSelection() {
    isSelectionMode = false;
    selectedFlag = {};
  }

  void _refreshData(int seconds) {
    _future = Future<List<Client>>.delayed(
        Duration(seconds: seconds, milliseconds: 100),
        () => handler.retrieveClients());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text('Home'),
          actions: _buildActions(),
        ),
        body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: () async {
            setState(() {
              _refreshData(1);
            });
            return;
          },
          child: FutureBuilder(
            future: _future,
            builder:
                (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final String? newClient = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddClientPage()),
            );

            if (newClient == "added") {
              setState(() {
                _refreshData(0);
                _resetSelection();
              });
            }
          },
          child: const Icon(Icons.add_rounded, size: 32.0),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      onWillPop: () async {
        if (isSelectionMode) {
          setState(() {
            _resetSelection();
          });
          return false;
        } else {
          return true;
        }
      },
    );
  }

  Widget _buildListView(AsyncSnapshot<List<Client>> snapshot) {
    if (snapshot.data?.length == 0) {
      return centerMessageWidget(nonFoundMessage);
    } else {
      return ListView.builder(
        itemCount: snapshot.data?.length,
        itemBuilder: (BuildContext context, int index) {
          int id = snapshot.data![index].id;
          String name = snapshot.data![index].name;
          String session = snapshot.data![index].session;
          String gender = snapshot.data![index].gender;

          selectedFlag[id] = selectedFlag[id] ?? false;
          bool isSelected = selectedFlag[id] ?? false;

          return Card(
            color: Colors.transparent,
            margin: EdgeInsets.all(5),
            semanticContainer: true,
            child: ListTile(
              onTap: () => _onTap(isSelected, id),
              onLongPress: () => onLongPress(isSelected, id),
              leading: _buildLeadingIcon(isSelected, gender),
              title: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                session,
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildLeadingIcon(bool isSelected, String gender) {
    if (isSelectionMode) {
      return CircleAvatar(
        radius: 30.0,
        backgroundColor: isSelected ? Colors.white : Colors.white24,
        child: isSelected
            ? const Icon(Icons.check, size: 25, color: Colors.black)
            : null,
      );
    } else {
      return CircleAvatar(
        radius: 30.0,
        backgroundColor: Colors.white24,
        child: Icon(getGenderIconData(gender), size: 25, color: Colors.white54),
      );
    }
  }

  void _onTap(bool isSelected, int id) {
    if (isSelectionMode) {
      setState(() {
        selectedFlag[id] = !isSelected;
        isSelectionMode = selectedFlag.containsValue(true);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClientInfoPage(clientId: id)),
      );
    }
  }

  void onLongPress(bool isSelected, int id) {
    setState(() {
      selectedFlag[id] = !isSelected;
      // If there will be any true in the selectionFlag then
      // selection Mode will be true
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  List<Widget> _buildActions() {
    // The button will be visible when the selectionMode is enabled.
    if (isSelectionMode) {
      bool isFalseAvailable = selectedFlag
          .containsValue(false); // check if all item is not selected
      return [
        IconButton(
          tooltip: "Delete",
          icon: Icon(Icons.delete),
          onPressed: () {
            selectedFlag.removeWhere((id, value) => value == false);
            BuildContext dialogContext;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                dialogContext = context;
                return ConfirmDialog(
                  confirmText: "Delete",
                  info: RichText(
                    text: TextSpan(
                      text: "${selectedFlag.length} ",
                      style: TextStyle(
                          fontSize: 17.0, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: (selectedFlag.length == 1)
                              ? 'entry is '
                              : 'entries are ',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text:
                              'selected.All client payment informations are wiped out permanently from memory. Type ',
                          style: TextStyle(
                              fontSize: 16.0,
                              overflow: TextOverflow.visible,
                              color: Colors.white70,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: 'confirm ',
                        ),
                        TextSpan(
                          text: 'to proceed.',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  onConfirm: () {
                    for (MapEntry e in selectedFlag.entries) {
                      if (e.value) {
                        handler.deleteClient(e.key);
                      }
                    }
                    setState(() {
                      _refreshData(0);
                      _resetSelection();
                    });
                    Navigator.pop(dialogContext);
                  },
                );
              },
            );
          },
        ),
        IconButton(
          tooltip: isFalseAvailable ? "SelectAll" : "Clear",
          icon: Icon(
            isFalseAvailable ? Icons.done_all : Icons.remove_done,
          ),
          onPressed: _selectAll,
        )
      ];
    } else {
      return [
        IconButton(
          tooltip: 'Plans',
          icon: const Icon(Icons.insert_chart_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlansPage()),
            );
          },
        )
      ];
    }
  }

  void _selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }
}
