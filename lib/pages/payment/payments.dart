import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/widgets.dart';

class ClientPaymentHistory extends StatefulWidget {
  final Future<List<Payment>> future;
  ClientPaymentHistory({Key? key, required this.future}) : super(key: key);

  @override
  _ClientPaymentHistoryState createState() => _ClientPaymentHistoryState();
}

class _ClientPaymentHistoryState extends State<ClientPaymentHistory> {
  final String nonFoundMessage = "Empty Payment History";
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
      child: FutureBuilder(
        future: widget.future,
        builder: (BuildContext context, AsyncSnapshot<List<Payment>> snapshot) {
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
    );
  }

  Widget _buildListView(AsyncSnapshot<List<Payment>> snapshot) {
    if (snapshot.data?.length == 0) {
      return centerMessageWidget(nonFoundMessage);
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data?.length,
        itemBuilder: (BuildContext context, int index) {
          String startDate = snapshot.data![index].endDate;

          return Card(
            color: Colors.transparent,
            margin: EdgeInsets.all(5),
            semanticContainer: true,
            child: Text(startDate),
          );
        },
      );
    }
  }
}
