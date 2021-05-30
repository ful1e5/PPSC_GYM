import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/styles.dart';
import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class PaymentHistory extends StatefulWidget {
  final Future<List<Payment>> future;
  final Function onDelete;

  PaymentHistory({Key? key, required this.onDelete, required this.future})
      : super(key: key);

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  final String nonFoundMessage = "0 Payments";
  final String errorMessage = "Error Occurred";

  Future<void> deletePamyment(Payment payment) async {
    final DatabaseHandler handler = DatabaseHandler();
    await handler.deletePayment(payment);
  }

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
      },
    );
  }

  Widget _buildListView(AsyncSnapshot<List<Payment>> snapshot) {
    if (snapshot.data?.length == 0) {
      return Container(
        height: 250.0,
        child: centerMessageWidget(nonFoundMessage),
      );
    } else {
      return Column(
        children: [
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data?.length,
            itemBuilder: (BuildContext context, int index) {
              Payment data = snapshot.data![index];
              int months = data.months;
              int money = data.money;
              String startDate = data.startDate;
              String endDate = data.endDate;
              String? note = data.note;

              bool isExpired = isDatePassed(endDate);

              final normalTextStyle = TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w300,
              );
              final boldTextStyle = TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                overflow: TextOverflow.visible,
                fontWeight: FontWeight.bold,
              );

              return Stack(
                children: [
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                    child: PhysicalShape(
                      color: isExpired ? Colors.red : Colors.green,
                      clipper: TicketClipper(),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 30.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: 25.0,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                cardSections(
                                  children: [
                                    Text(
                                      'Starting Date',
                                      style: normalTextStyle,
                                    ),
                                    gapWidget(8.0),
                                    Text(
                                      startDate,
                                      style: boldTextStyle,
                                    ),
                                    gapWidget(20.0),
                                    Text(
                                      'Plan',
                                      style: normalTextStyle,
                                    ),
                                    gapWidget(8.0),
                                    Text(
                                      '$months Months',
                                      style: boldTextStyle,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 35.0),
                                cardSections(
                                  children: [
                                    Text(
                                      'Ending Date',
                                      style: normalTextStyle,
                                    ),
                                    gapWidget(8.0),
                                    Text(
                                      endDate,
                                      style: boldTextStyle,
                                    ),
                                    gapWidget(20.0),
                                    Text(
                                      'Payment',
                                      style: normalTextStyle,
                                    ),
                                    gapWidget(8.0),
                                    Text(
                                      '$money \u20B9',
                                      style: boldTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ...buildNote(note),
                            ...deleteButton(data, isExpired)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 37.0,
                      vertical: 32.0,
                    ),
                    alignment: Alignment.centerRight,
                    child: Icon(isExpired ? Icons.verified : null, size: 18.0),
                  ),
                ],
              );
            },
          ),
        ],
      );
    }
  }

  Widget cardSections({List<Widget>? children}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children ?? const <Widget>[],
      ),
    );
  }

  List<Widget> buildNote(String? note) {
    if (note == null) {
      return [Container()];
    } else {
      return [
        gapWidget(25.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 35.0),
          child: Text(
            'Note : $note',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        )
      ];
    }
  }

  List<Widget> deleteButton(Payment payment, bool isExpired) {
    if (isExpired) {
      return [Container()];
    } else {
      return [
        gapWidget(20.0),
        OutlinedButton(
          style: materialButtonStyle(
            borderRadius: 50.0,
            padding: EdgeInsets.all(15.0),
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
          ),
          child: Icon(Icons.clear),
          onPressed: () {
            handleDelete(payment);
          },
        ),
      ];
    }
  }

  void handleDelete(Payment payment) {
    BuildContext dialogContext;

    TextStyle normalStyle = TextStyle(
      fontSize: 16.0,
      color: Colors.white70,
    );

    TextStyle boldStyle = TextStyle(
      fontSize: 16.0,
      color: Colors.white70,
      fontWeight: FontWeight.bold,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return ConfirmDialog(
          buttonText: "Delete",
          child: RichText(
            text: TextSpan(
              style: normalStyle,
              children: [
                TextSpan(
                  text: 'This payment data is deleted forever,  Type ',
                ),
                TextSpan(
                  text: 'confirm',
                  style: boldStyle,
                ),
                TextSpan(
                  text: ' to proceed.',
                ),
              ],
            ),
          ),
          onConfirm: () async {
            await deletePamyment(payment);
            await widget.onDelete();
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, 55);
    path.relativeArcToPoint(
      const Offset(0, 40),
      radius: const Radius.circular(10),
      largeArc: true,
    );
    path.lineTo(0.0, size.height - 20.0);
    path.quadraticBezierTo(0.0, size.height, 20.0, size.height);
    path.lineTo(size.width - 20.0, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - 20.0,
    );
    path.lineTo(size.width, 95);
    path.arcToPoint(
      Offset(size.width, 55),
      radius: const Radius.circular(10.0),
      clockwise: true,
    );
    path.lineTo(size.width, 20.0);
    path.quadraticBezierTo(size.width, 0.0, size.width - 20.0, 0.0);
    path.lineTo(20.0, 0.0);
    path.quadraticBezierTo(0.0, 0.0, 0.0, 20.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
