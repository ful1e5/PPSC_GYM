import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/styles.dart';

import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class ClientPaymentHistory extends StatefulWidget {
  final Future<List<Payment>> future;
  final Function onDelete;

  ClientPaymentHistory({Key? key, required this.onDelete, required this.future})
      : super(key: key);

  @override
  _ClientPaymentHistoryState createState() => _ClientPaymentHistoryState();
}

class _ClientPaymentHistoryState extends State<ClientPaymentHistory> {
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
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
              );
              final boldTextStyle = TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                overflow: TextOverflow.visible,
                fontWeight: FontWeight.bold,
              );

              return Container(
                margin: EdgeInsets.fromLTRB(35.0, 15.0, 35.0, 15.0),
                child: PhysicalShape(
                  color: isExpired ? Colors.red : Colors.green,
                  clipper: TicketClipper(),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 25.0, horizontal: 18.0),
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
                            SizedBox(width: 28.0),
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
                        ...buildNote(note, normalTextStyle, boldTextStyle),
                        gapWidget(18.0),
                        (isDatePassed(endDate))
                            ? Container()
                            : deleteButton(data)
                      ],
                    ),
                  ),
                ),
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

  List<Widget> buildNote(
    String? note,
    TextStyle normalTextStyle,
    TextStyle boldTextStyle,
  ) {
    if (note == null) {
      return [Container()];
    } else {
      return [
        gapWidget(20.0),
        Text(
          "Note",
          style: normalTextStyle,
        ),
        gapWidget(8.0),
        Text(
          note,
          style: boldTextStyle,
        ),
      ];
    }
  }

  Widget deleteButton(Payment payment) {
    return OutlinedButton(
      style: materialButtonStyle(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        padding: EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 10.0,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.red,
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
          children: [
            WidgetSpan(
              child: const Icon(
                Icons.delete,
                size: 18.0,
              ),
            ),
            TextSpan(text: ' Delete'),
          ],
        ),
      ),
      onPressed: () {
        handleDelete(payment);
      },
    );
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
          height: 250.0,
          confirmText: "Delete",
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
    path.relativeArcToPoint(const Offset(0, 40),
        radius: const Radius.circular(10.0), largeArc: true);
    path.lineTo(0.0, size.height - 10);
    path.quadraticBezierTo(0.0, size.height, 10.0, size.height);
    path.lineTo(size.width - 10.0, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - 10);
    path.lineTo(size.width, 95);
    path.arcToPoint(Offset(size.width, 55),
        radius: const Radius.circular(10.0), clockwise: true);
    path.lineTo(size.width, 10.0);
    path.quadraticBezierTo(size.width, 0.0, size.width - 10.0, 0.0);
    path.lineTo(10.0, 0.0);
    path.quadraticBezierTo(0.0, 0.0, 0.0, 10.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
