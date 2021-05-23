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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<List<Client>> clientsFuture;

  late Map<int, bool> selectedFlag;
  late bool isSelectionMode;

  final String nonFoundMessage = 'No Records Found';

  late Set<String> dTabs = {'Morning', 'Evening', 'Home'};
  late Set<String> tabs = dTabs;
  late TabController tabCtrl;
  final int homeIndex = 2;

  @override
  void initState() {
    super.initState();

    tabCtrl = TabController(
      length: tabs.length,
      initialIndex: homeIndex,
      vsync: this,
    );

    refreshPlans();

    refreshClients();
    resetSelection();
  }

  @override
  void dispose() {
    tabCtrl.dispose();
    super.dispose();
  }

  refreshPlans() async {
    final handler = DatabaseHandler();
    final p = await handler.retrievePlans();
    final pTabs = p.map((e) => '${e.months} Month Plan').toList();
    setState(() {
      tabs = Set.from(dTabs)..addAll(pTabs);
      tabCtrl = TabController(
          length: tabs.length, initialIndex: homeIndex, vsync: this);
      print(tabs);
    });
  }

  refreshClients() {
    final handler = DatabaseHandler();
    clientsFuture = Future<List<Client>>.delayed(
      Duration.zero,
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
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: buildActions(),
          bottom: tabBarWidget(
            controller: tabCtrl,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: buildTabView(),
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
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlansPage()),
            ).then((context) {
              setState(() {
                refreshPlans();
              });
            });
          },
        ),
      ];
    }
  }

  Widget buildTabView() {
    return FutureBuilder(
      future: clientsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Client>> snapshot) {
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
                      refreshClients();
                    });
                  },
                ),
                Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    controller: tabCtrl,
                    children: tabViewChildren(clients),
                  ),
                ),
              ],
            );
          }
        } else {
          return centerMessageWidget(nonFoundMessage);
        }
      },
    );
  }

  List<Widget> tabViewChildren(List<Client> clients) {
    return tabs.map((t) {
      if (t == 'Morning') {
        return clientList(
          clients.where((e) => e.session == 'Morning').toList(),
        );
      } else if (t == 'Evening') {
        return clientList(
          clients.where((e) => e.session == 'Evening').toList(),
        );
      } else if (t == 'Home') {
        return clientList(clients);
      } else if (t.contains('Month Plan')) {
        final int mounth = int.parse(t.split(" ")[0]);
        final fclients = clients.where((c) => c.planMonth == mounth).toList();
        return clientList(fclients);
      } else {
        return centerMessageWidget("No Data Found");
      }
    }).toList();
  }

  Widget clientList(List<Client> clients) {
    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: Colors.white,
      onRefresh: () async {
        setState(() {
          refreshClients();
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            resetSelection();
          });
        },
        child: buildClientsCard(clients),
      ),
    );
  }

  Widget buildClientsCard(List<Client> clients) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: clients.length,
      itemBuilder: (BuildContext context, int index) {
        Client client = clients[index];
        int id = client.id;
        String name = client.name;
        String session = client.session;
        String gender = client.gender;
        String? exDate = client.planExpiryDate;
        int? planMonth = client.planMonth;

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
              (planMonth != null)
                  ? '$session ($planMonth Month Plan)'
                  : session,
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
      ).then((context) async {
        setState(() {
          refreshClients();
          refreshPlans();
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
              refreshClients();
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
        refreshClients();
        resetSelection();
        tabCtrl.index = homeIndex;
      });
    }
  }
}
