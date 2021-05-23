import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ppscgym/search.dart';

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
  late Future<List<Client>> clientsFuture;
  late List<Plan> plans;

  late Map<int, bool> selectedFlag;
  late bool isSelectionMode;

  final String nonFoundMessage = 'No Records Found';

  @override
  void initState() {
    super.initState();

    refreshClients(1);
    refreshPlans();
    resetSelection();
  }

  refreshClients(int seconds) {
    final handler = DatabaseHandler();
    clientsFuture = Future<List<Client>>.delayed(
      Duration(seconds: seconds, milliseconds: 100),
      () => handler.retrieveClients(),
    );
  }

  refreshPlans() async {
    final handler = DatabaseHandler();
    plans = await handler.retrievePlans();
  }

  resetSelection() {
    isSelectionMode = false;
    selectedFlag = {};
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 2,
      child: WillPopScope(
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
              child: clientList(),
            ),
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
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      actions: buildActions(),
      bottom: TabBar(
        isScrollable: true,
        unselectedLabelColor: Colors.redAccent,
        physics: BouncingScrollPhysics(),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        automaticIndicatorColorAdjustment: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.redAccent,
        ),
        tabs: tabList(),
      ),
    );
  }

  List<Widget> defaultTabs() {
    return [
      Tab(icon: Icon(Icons.brightness_2_rounded)),
      Tab(icon: Icon(Icons.brightness_high_rounded)),
      Tab(icon: Icon(Icons.home)),
    ];
  }

  List<Widget> tabList() {
    return defaultTabs();
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
          icon: Icon(Icons.delete),
          tooltip: 'Delete',
          onPressed: () async => await deleteDialog(),
        ),
        IconButton(
          icon: Icon(
            isFalseAvailable ? Icons.done_all : Icons.remove_done,
          ),
          tooltip: isFalseAvailable ? 'SelectAll' : 'Clear',
          onPressed: selectAll,
        )
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.insert_chart_rounded),
          tooltip: 'Plans',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlansPage()),
            );
          },
        ),
      ];
    }
  }

  Widget clientList() {
    return FutureBuilder(
      future: clientsFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Client>> snapshot,
      ) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loaderWidget();
        } else if (snapshot.hasError) {
          return centerMessageWidget('Error !');
        } else if (snapshot.hasData) {
          final clients = snapshot.data!;
          if (snapshot.data?.length == 0) {
            return centerMessageWidget(nonFoundMessage);
          } else {
            return Column(
              children: [
                SearchBar(
                  clients: clients,
                  syncFunction: () {
                    setState(() {
                      refreshClients(0);
                    });
                  },
                ),
                Expanded(child: buildListView(clients)),
              ],
            );
          }
        } else {
          return centerMessageWidget(nonFoundMessage);
        }
      },
    );
  }

  Widget buildListView(List<Client> clients) {
    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (BuildContext context, int index) {
        Client client = clients[index];
        int id = client.id;
        String name = client.name;
        String session = client.session;
        String gender = client.gender;
        String? exDate = client.planExpiryDate;

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
      return avatarWidget(
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
      return avatarWidget(
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

  Future<void> deleteDialog() async {
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
