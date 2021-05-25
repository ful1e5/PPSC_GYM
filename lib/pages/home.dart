import 'dart:async';
import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/pages/member/add.dart';
import 'package:ppscgym/pages/member/info.dart';
import 'package:ppscgym/pages/setting.dart';
import 'package:ppscgym/search.dart';

import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<List<Member>> membersFuture;

  late Map<int, bool> selectedFlag;
  late bool isSelectionMode;

  final String nonFoundMessage = 'No Records Found';

  late Set<String> dTabs = {'Morning', 'Evening', 'All'};
  late Set<String> tabs = dTabs;
  late TabController tabCtrl;
  final int defaultTabIndex = 2;

  @override
  void initState() {
    super.initState();

    tabCtrl = TabController(
      length: tabs.length,
      initialIndex: defaultTabIndex,
      vsync: this,
    );

    refreshPlans();

    refreshMembers();
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
          length: tabs.length, initialIndex: defaultTabIndex, vsync: this);
    });
  }

  refreshMembers() {
    final handler = DatabaseHandler();
    membersFuture = Future<List<Member>>.delayed(
      Duration.zero,
      () => handler.retrieveMembers(),
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
          title: Text('PPSC GYM'),
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
          onPressed: () async => await toAddMemberPage(),
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
          icon: const Icon(Icons.settings),
          tooltip: 'Setting',
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingPage()),
            ).then((context) {
              setState(() {
                refreshPlans();
              });
            });
          },
        ),

        // TODO: Remove from here
        // IconButton(
        //   icon: const Icon(Icons.insert_chart_rounded),
        //   tooltip: 'Plans',
        //   onPressed: () async {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => PlansPage()),
        //     ).then((context) {
        //       setState(() {
        //         refreshPlans();
        //       });
        //     });
        //   },
        // ),
      ];
    }
  }

  Widget buildTabView() {
    return FutureBuilder(
      future: membersFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loaderWidget();
        } else if (snapshot.hasError) {
          return centerMessageWidget('Error !');
        } else if (snapshot.hasData) {
          final members = snapshot.data!;
          if (snapshot.data?.length == 0) {
            return centerMessageWidget(nonFoundMessage);
          } else {
            return Column(
              children: [
                SearchBar(
                  members: members,
                  syncFunction: () {
                    setState(() {
                      refreshMembers();
                    });
                  },
                ),
                Expanded(
                  child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    controller: tabCtrl,
                    children: tabViewChildren(members),
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

  List<Widget> tabViewChildren(List<Member> members) {
    return tabs.map((t) {
      if (t == 'Morning') {
        return memberList(
          members.where((e) => e.session == 'Morning').toList(),
        );
      } else if (t == 'Evening') {
        return memberList(
          members.where((e) => e.session == 'Evening').toList(),
        );
      } else if (t == 'All') {
        return memberList(members);
      } else if (t.contains('Month Plan')) {
        final int mounth = int.parse(t.split(" ")[0]);
        final fmembers = members.where((c) => c.planMonth == mounth).toList();
        return memberList(fmembers);
      } else {
        return centerMessageWidget("No Data Found");
      }
    }).toList();
  }

  Widget memberList(List<Member> members) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.blue,
      displacement: 2.0,
      edgeOffset: 2.0,
      onRefresh: () async {
        setState(() {
          refreshMembers();
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            resetSelection();
          });
        },
        child: buildMembersCard(members),
      ),
    );
  }

  Widget buildMembersCard(List<Member> members) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (BuildContext context, int index) {
        Member member = members[index];
        int id = member.id;
        String name = member.name;
        String session = member.session;
        String gender = member.gender;
        String? exDate = member.planExpiryDate;
        int? planMonth = member.planMonth;

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
                  ? '$session - $planMonth Month Plan'
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
        MaterialPageRoute(builder: (context) => MemberInfoPage(memberId: id)),
      ).then((context) async {
        setState(() {
          refreshMembers();
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

  deleteMember(int id) async {
    final handler = DatabaseHandler();
    await handler.deleteMember(id);
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
                  text: "All member's payment informations are wiped "
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
                await deleteMember(e.key);
              }
            }
            setState(() {
              refreshMembers();
              resetSelection();
            });
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }

  Future<void> toAddMemberPage() async {
    final String? newMember = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMemberPage(),
      ),
    );

    if (newMember == 'member added') {
      setState(() {
        refreshMembers();
        resetSelection();
        tabCtrl.index = defaultTabIndex;
      });
    }
  }
}
