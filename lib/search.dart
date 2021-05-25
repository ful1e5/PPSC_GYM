import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ppscgym/pages/member/info.dart';

import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils.dart';

class SearchBar extends StatelessWidget {
  final List<Member> members;
  final Function syncFunction;

  const SearchBar({Key? key, required this.members, required this.syncFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showSearch(
            context: context, delegate: SearchMember(members, syncFunction));
      },
      child: Card(
        color: Colors.white12,
        margin: EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 20.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 20.0,
                color: Colors.white24,
              ),
              SizedBox(width: 15.0),
              Text(
                '${members.length} members',
                style: TextStyle(
                  fontSize: 16.4,
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchMember extends SearchDelegate<Member?> {
  final List<Member> membersData;
  final Function syncFunction;

  SearchMember(this.membersData, this.syncFunction);

  @override
  String get searchFieldLabel => '';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.black, width: 4.5),
    );
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white12,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
        border: border,
        focusedBorder: border,
        enabledBorder: border,
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isEmpty
          ? Container()
          : GestureDetector(
              onTap: () => query = '',
              child: Container(
                padding: EdgeInsets.only(right: 20.0),
                alignment: Alignment.center,
                child: Text(
                  "clear",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
    ];
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

  Widget buildAvatar(String gender, String? exDate) {
    return avatarWidget(
      color: getAvatarColor(exDate),
      child: Icon(
        getGenderIcon(gender),
        size: 25,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget memberCard(Member member, BuildContext context) {
    int id = member.id;
    String name = member.name;
    String session = member.session;
    String gender = member.gender;
    String? exDate = member.planExpiryDate;

    return Card(
      color: Colors.black,
      child: ListTile(
        onTap: () {
          close(context, null);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MemberInfoPage(memberId: id)),
          ).then((context) {
            syncFunction();
          });
        },
        leading: buildAvatar(gender, exDate),
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
  }

  late Iterable<Member> filteredList;

  @override
  Widget buildSuggestions(BuildContext context) {
    filteredList = membersData
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()));

    return ListView(
      physics: BouncingScrollPhysics(),
      children: filteredList
          .map(
            (member) => memberCard(member, context),
          )
          .toList(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: filteredList
          .map(
            (member) => memberCard(member, context),
          )
          .toList(),
    );
  }
}
