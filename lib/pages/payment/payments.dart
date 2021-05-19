import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class ClientPaymentHistory extends StatefulWidget {
  final Future<List<Payment>> future;
  final Function refreshData;
  ClientPaymentHistory(
      {Key? key, required this.refreshData, required this.future})
      : super(key: key);

  @override
  _ClientPaymentHistoryState createState() => _ClientPaymentHistoryState();
}

class _ClientPaymentHistoryState extends State<ClientPaymentHistory> {
  final String nonFoundMessage = "0 Payments";
  final String errorMessage = "Error Occured";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.future,
        builder: (BuildContext context, AsyncSnapshot<List<Payment>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(height: 250.0, child: loaderWidget());
          }
          if (snapshot.hasError) {
            return Container(
                height: 250.0, child: centerMessageWidget(errorMessage));
          }
          if (snapshot.hasData) {
            return _buildListView(snapshot);
          }
          return Container(
              height: 250.0, child: centerMessageWidget(nonFoundMessage));
        });
  }

  Widget _buildListView(AsyncSnapshot<List<Payment>> snapshot) {
    if (snapshot.data?.length == 0) {
      return Container(
          height: 250.0, child: centerMessageWidget(nonFoundMessage));
    } else {
      return Column(
        children: [
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              int months = snapshot.data![index].months;
              int money = snapshot.data![index].money;
              String startDate = snapshot.data![index].startDate;
              String endDate = snapshot.data![index].endDate;
              String? note = snapshot.data![index].note;

              bool isExpired = isDatePassed(endDate);

              return Card(
                color: isExpired ? Colors.red : Colors.green,
                margin: EdgeInsets.fromLTRB(35.0, 15.0, 35.0, 15.0),
                semanticContainer: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$months Months Plan',
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w300)),
                              Text('$money\u20B9',
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600)),
                              Divider(color: Colors.transparent, height: 10.0),
                              Text('$startDate to $endDate',
                                  style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        isExpired
                            ? Container()
                            : Expanded(
                                child: IconButton(
                                  onPressed: handleDelete,
                                  icon: Icon(Icons.delete_forever,
                                      color: Colors.white, size: 25.0),
                                ),
                              ),
                      ],
                    ),
                    (note != null)
                        ? Container(
                            padding: EdgeInsets.only(
                              top: 4.0,
                              bottom: 20.0,
                              right: 20.0,
                              left: 20.0,
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Note: $note",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
  }

  void handleDelete() {
    BuildContext dialogContext;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return ConfirmDialog(
          confirmText: "Delete",
          info: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'This payment is delete forever',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: 'Type ',
                  style: TextStyle(
                      fontSize: 16.0,
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
            widget.refreshData(1);
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }
}
