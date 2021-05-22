import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ppscgym/pages/client/info.dart';

import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils.dart';

class SearchBar extends StatelessWidget {
  final List<Client> clients;
  final Function syncFunction;

  const SearchBar({Key? key, required this.clients, required this.syncFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showSearch(
            context: context, delegate: SearchClient(clients, syncFunction));
      },
      child: Card(
        color: Colors.white12,
        margin: EdgeInsets.symmetric(
          horizontal: 25.0,
          vertical: 15.0,
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
                '${clients.length} members',
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

class SearchClient extends SearchDelegate<Client?> {
  final List<Client> clientsData;
  final Function syncFunction;

  SearchClient(this.clientsData, this.syncFunction);

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

  Widget clientCard(Client client, BuildContext context) {
    int id = client.id;
    String name = client.name;
    String session = client.session;
    String gender = client.gender;
    String? exDate = client.planExpiryDate;

    return Card(
      color: Colors.black,
      child: ListTile(
        onTap: () {
          close(context, null);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClientInfoPage(clientId: id)),
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

  late Iterable<Client> filteredList;

  @override
  Widget buildSuggestions(BuildContext context) {
    filteredList = clientsData
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: filteredList
          .map(
            (client) => clientCard(client, context),
          )
          .toList(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView(
      children: filteredList
          .map(
            (client) => clientCard(client, context),
          )
          .toList(),
    );
  }
}
