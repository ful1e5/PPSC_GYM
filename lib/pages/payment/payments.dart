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
    return FutureBuilder(
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
    );
  }

  Widget _buildListView(AsyncSnapshot<List<Payment>> snapshot) {
    if (snapshot.data?.length == 0) {
      return centerMessageWidget(nonFoundMessage);
    } else {
      return Column(
        children: [
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              int money = snapshot.data![index].money;
              String startDate = snapshot.data![index].startDate;
              String endDate = snapshot.data![index].endDate;

              return Card(
                color: Colors.red, //TODO: dynamic colors of payment card
                margin: EdgeInsets.fromLTRB(35.0, 15.0, 35.0, 15.0),
                semanticContainer: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //TODO: add plan months
                          Text('$money \u20B9',
                              style: TextStyle(
                                  fontSize: 32.0, fontWeight: FontWeight.w300)),
                          Text('$startDate to $endDate',
                              style: TextStyle(
                                  fontSize: 11.0, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.edit, color: Colors.white, size: 25.0),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
  }
}
