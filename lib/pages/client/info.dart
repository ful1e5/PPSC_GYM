import 'package:flutter/material.dart';

import 'package:ppscgym/pages/client/add.dart';
import 'package:ppscgym/pages/payment/payments.dart';
import 'package:ppscgym/pages/plans.dart';
import 'package:ppscgym/utils.dart';

import 'package:ppscgym/widgets.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

class ClientInfoPage extends StatefulWidget {
  final int clientId;

  const ClientInfoPage({Key? key, required this.clientId}) : super(key: key);

  @override
  _ClientInfoPageState createState() => _ClientInfoPageState();
}

class _ClientInfoPageState extends State<ClientInfoPage> {
  late DatabaseHandler handler;
  late Future<Client> _infoFuture;
  late Future<List<Payment>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    _refreshInfoData(0);
    _refreshPaymentData(1);
  }

  void _refreshInfoData(int seconds) {
    _infoFuture = Future<Client>.delayed(
        Duration(seconds: seconds, microseconds: 10),
        () => handler.retrieveClient(widget.clientId));
  }

  void _refreshPaymentData(int seconds) {
    _paymentsFuture = Future<List<Payment>>.delayed(
        Duration(seconds: seconds, microseconds: 20),
        () => handler.retriveClientPayments(widget.clientId));
  }

  void onPaymentDelete() {
    setState(() {
      _refreshInfoData(0);
      _refreshPaymentData(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _infoFuture,
      builder: (BuildContext context, AsyncSnapshot<Client> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loaderWidget();
        }
        if (snapshot.hasError) {
          return centerMessageWidget("Error !");
        }
        if (snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              actions: [
                IconButton(
                  tooltip: "Edit",
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddClientPage(data: snapshot.data),
                      ),
                    );

                    if (result == 'added') {
                      setState(() {
                        _refreshInfoData(0);
                      });
                    }
                  },
                  icon: Icon(Icons.edit),
                )
              ],
            ),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  clientInfo(snapshot),
                  Divider(color: Colors.transparent, height: 7.0),
                  rechargeButton(), //TODO: remove on plan active
                  Divider(color: Colors.transparent, height: 10.0),
                  ClientPaymentHistory(
                      future: _paymentsFuture, onDelete: onPaymentDelete),
                ],
              ),
            ),
          );
        }
        return centerMessageWidget("Client Data Found");
      },
    );
  }

  Widget clientInfo(AsyncSnapshot<Client> snapshot) {
    final String id = snapshot.data!.id.toString();
    final String name = snapshot.data!.name;
    final String gender = snapshot.data!.gender;
    final String session = snapshot.data!.session;
    final String dob = snapshot.data!.dob.toString();
    final String mobile = snapshot.data!.mobile.toString();
    final String? planExpiryDate = snapshot.data!.planExpiryDate;
    final String totalMoney = snapshot.data!.totalMoney.toString();

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 8.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      fontSize: 34.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  WidgetSpan(
                    child: Icon(
                      getGenderIconData(gender),
                      size: 34.0,
                      color: gender == "Male" ? Colors.blue : Colors.pinkAccent,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 10.0, color: Colors.transparent),
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.tag,
                      size: 16.0,
                      color: Colors.white70,
                    ),
                  ),
                  TextSpan(
                    text: id,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 20.0, color: Colors.transparent),
            cardGroup([
              infoCard(
                  Text(
                    (planExpiryDate == null || isDatePassed(planExpiryDate))
                        ? "Plan Expired"
                        : "Plan Expire On",
                    style: TextStyle(fontSize: 17.0),
                  ),
                  planExpiryDate ?? "-"),
              infoCard(
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                  "$totalMoney \u20B9"),
            ], 15.6),
            cardGroup([
              infoCard(Icon(Icons.phone, size: 25.0), mobile),
              infoCard(Icon(Icons.timelapse, size: 25.0), session),
              infoCard(Icon(Icons.cake, size: 25.0), dob),
            ], 15.6),
            Divider(height: 10.0, color: Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget infoCard(Widget symbol, String info) {
    return Column(
      children: [
        symbol,
        Divider(color: Colors.transparent, height: 5.0),
        Text(
          info,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        )
      ],
    );
  }

  Widget cardGroup(List<Widget> children, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children
          .map((c) => Container(padding: EdgeInsets.all(spacing), child: c))
          .toList(),
    );
  }

  Widget rechargeButton() {
    return OutlinedButton(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 20.0),
          children: [
            WidgetSpan(
              child: const Icon(Icons.flash_on_rounded),
            ),
            TextSpan(text: " Recharge Plan"),
          ],
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.only(top: 12.0, bottom: 12.0, right: 22.0, left: 22.0)),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
      ),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlansPage(
              select: true,
              clientId: widget.clientId,
            ),
          ),
        );

        if (result == "added") {
          setState(() {
            _refreshInfoData(0);
            _refreshPaymentData(0);
          });
        }
      },
    );
  }
}
