import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/pages/client/add.dart';
import 'package:ppscgym/pages/client/info.dart';
import 'package:ppscgym/pages/plans.dart';

import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Client>> _future;

  late Map<int, bool> selectedFlag;
  late bool isSelectionMode;

  final String nonFoundMessage = 'No Records Found';

  @override
  void initState() {
    super.initState();

    refreshClients(2);
    resetSelection();
  }

  refreshClients(int seconds) {
    final handler = DatabaseHandler();
    _future = Future<List<Client>>.delayed(
      Duration(seconds: seconds, milliseconds: 100),
      () => handler.retrieveClients(),
    );
  }

  resetSelection() {
    isSelectionMode = false;
    selectedFlag = {};
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: buildAppBar(),
        body: RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.white,
          onRefresh: () async {
            setState(() {
              refreshClients(0);
            });
          },
          child: GestureDetector(
              onTap: () {
                setState(() {
                  resetSelection();
                });
              },
              child: clientList()),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_rounded, size: 32.0),
          backgroundColor: Colors.white,
          onPressed: () async => await toAddClientPage(),
        ),
      ),
      onWillPop: () async {
        if (isSelectionMode) {
          setState(() {
            resetSelection();
          });
          return false;
        } else {
          return true;
        }
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      centerTitle: true,
      title: const Text('Home'),
      actions: buildActions(),
    );
  }

  void selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  buildActions() {
    // The button will be visible when the selectionMode is enabled.
    if (isSelectionMode) {
      bool isFalseAvailable = selectedFlag
          .containsValue(false); // check if all item is not selected
      return [
        IconButton(
          tooltip: 'Delete',
          icon: Icon(Icons.delete),
          onPressed: () async => await handleDelete(),
        ),
        IconButton(
          tooltip: isFalseAvailable ? 'SelectAll' : 'Clear',
          icon: Icon(
            isFalseAvailable ? Icons.done_all : Icons.remove_done,
          ),
          onPressed: selectAll,
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

  Widget clientList() {
    return FutureBuilder(
      future: _future,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Client>> snapshot,
      ) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loaderWidget();
        } else if (snapshot.hasError) {
          return centerMessageWidget('Error !');
        } else if (snapshot.hasData) {
          if (snapshot.data?.length == 0) {
            return centerMessageWidget(nonFoundMessage);
          } else {
            return buildListView(snapshot);
          }
        } else {
          return centerMessageWidget(nonFoundMessage);
        }
      },
    );
  }

  Widget buildListView(AsyncSnapshot<List<Client>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data?.length,
      itemBuilder: (BuildContext context, int index) {
        int id = snapshot.data![index].id;
        String name = snapshot.data![index].name;
        String session = snapshot.data![index].session;
        String gender = snapshot.data![index].gender;
        String? exDate = snapshot.data![index].planExpiryDate;

        selectedFlag[id] = selectedFlag[id] ?? false;
        bool isSelected = selectedFlag[id] ?? false;

        return Card(
          color: Colors.transparent,
          margin: EdgeInsets.all(5),
          semanticContainer: true,
          child: ListTile(
            onTap: () => onTap(isSelected, id),
            onLongPress: () => onLongPress(isSelected, id),
            leading: buildAvatar(isSelected, gender, exDate),
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

  void onTap(bool isSelected, int id) {
    if (isSelectionMode) {
      setState(() {
        selectedFlag[id] = !isSelected;
        isSelectionMode = selectedFlag.containsValue(true);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClientInfoPage(clientId: id)),
      ).then((context) {
        setState(() {
          refreshClients(0);
        });
      });
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

  Color getAvatarColor(String? exDate) {
    if (exDate == null) {
      return Colors.white24;
    } else if (isDatePassed(exDate)) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  Widget buildAvatar(bool isSelected, String gender, String? exDate) {
    if (isSelectionMode) {
      return AvatarWidget(
        color: isSelected ? Colors.white : Colors.white24,
        child: isSelected
            ? const Icon(
                Icons.check,
                size: 25,
                color: Colors.black,
              )
            : null,
      );
    } else {
      return AvatarWidget(
        color: getAvatarColor(exDate),
        child: Icon(
          getGenderIcon(gender),
          size: 25,
          color: Colors.white.withOpacity(0.8),
        ),
      );
    }
  }

  deleteClient(int id) async {
    final handler = DatabaseHandler();
    await handler.deleteClient(id);
  }

  Future<void> handleDelete() async {
    selectedFlag.removeWhere((id, value) => value == false);
    BuildContext dialogContext;

    final boldTextStyle = TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
    );
    final normalTextStyle = TextStyle(
      fontSize: 16.0,
      overflow: TextOverflow.visible,
      color: Colors.white70,
      fontWeight: FontWeight.normal,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return ConfirmDialog(
          height: 300,
          confirmText: 'Delete',
          child: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: normalTextStyle,
              children: <TextSpan>[
                TextSpan(text: '${selectedFlag.length} ', style: boldTextStyle),
                TextSpan(
                  text: (selectedFlag.length == 1)
                      ? 'entry is '
                      : 'entries are ' 'selected. ',
                ),
                TextSpan(
                  text: "All client's payment informations are wiped "
                      'out permanently from memory. Type ',
                ),
                TextSpan(text: 'confirm ', style: boldTextStyle),
                TextSpan(text: 'to proceed.'),
              ],
            ),
          ),
          onConfirm: () async {
            for (MapEntry e in selectedFlag.entries) {
              if (e.value) {
                await deleteClient(e.key);
              }
            }
            setState(() {
              refreshClients(0);
              resetSelection();
            });
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }

  Future<void> toAddClientPage() async {
    final String? newClient = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddClientPage(),
      ),
    );

    if (newClient == 'client added') {
      setState(() {
        refreshClients(0);
        resetSelection();
      });
    }
  }
}
