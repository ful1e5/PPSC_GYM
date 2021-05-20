import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/services/database/handler.dart';

import 'package:ppscgym/pages/client/add.dart';
import 'package:ppscgym/pages/payment/payments.dart';
import 'package:ppscgym/pages/plans.dart';

import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils.dart';

class ClientInfoPage extends StatefulWidget {
  final int clientId;

  const ClientInfoPage({Key? key, required this.clientId}) : super(key: key);

  @override
  _ClientInfoPageState createState() => _ClientInfoPageState();
}

class _ClientInfoPageState extends State<ClientInfoPage> {
  late Future<Client> infoFuture;
  late Future<List<Payment>> paymentsFuture;
  late bool isPlanExpired;

  @override
  void initState() {
    super.initState();
    refreshClientData(0);
    refreshPaymentsData(1);
  }

  refreshClientData(int seconds) {
    final DatabaseHandler handler = DatabaseHandler();

    infoFuture = Future<Client>.delayed(
      Duration(seconds: seconds, microseconds: 10),
      () => handler.retrieveClient(widget.clientId),
    );
  }

  refreshPaymentsData(int seconds) {
    final DatabaseHandler handler = DatabaseHandler();
    paymentsFuture = Future<List<Payment>>.delayed(
      Duration(seconds: seconds, microseconds: 20),
      () => handler.retriveClientPayments(widget.clientId),
    );
  }

  void refreshAllData() {
    setState(() {
      refreshClientData(0);
      refreshPaymentsData(0);
    });
  }

  setPlanExpiry(String? exDate) {
    if (exDate == null) {
      isPlanExpired = true;
    } else if (isDatePassed(exDate)) {
      isPlanExpired = true;
    } else {
      isPlanExpired = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: infoFuture,
      builder: (BuildContext context, AsyncSnapshot<Client> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loaderWidget();
        } else if (snapshot.hasError) {
          return centerMessageWidget('Error !');
        } else if (snapshot.hasData) {
          //Initiating plan expiry boolean
          Client clientData = snapshot.data!;
          setPlanExpiry(clientData.planExpiryDate);

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: buildAppBar(clientData),
            body: buildBody(clientData),
          );
        } else {
          return centerMessageWidget('Client Data Found');
        }
      },
    );
  }

  AppBar buildAppBar(Client client) {
    return AppBar(
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          tooltip: 'Edit',
          icon: Icon(Icons.edit),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddClientPage(data: client),
              ),
            );

            if (result == 'client updated') {
              setState(() {
                refreshClientData(0);
              });
            }
          },
        ),
      ],
    );
  }

  Widget buildBody(Client clientData) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          clientInfo(clientData),
          Divider(color: Colors.transparent, height: 7.0),

          // CoolDown Widget
          (isPlanExpired)
              ? rechargeButton()
              : CountDown(
                  time: stringToDateTime(clientData.planExpiryDate!),
                  onTimeout: refreshAllData,
                ),
          Divider(color: Colors.transparent, height: 10.0),

          ClientPaymentHistory(
            future: paymentsFuture,
            onDelete: refreshAllData,
          ),
        ],
      ),
    );
  }

  Widget clientInfo(Client client) {
    String id = client.id.toString();
    String name = client.name;
    String gender = client.gender;
    String session = client.session;
    String dob = client.dob.toString();
    String mobile = client.mobile.toString();
    String? planExpiryDate = client.planExpiryDate;
    String totalMoney = client.totalMoney.toString();

    //Styling
    TextStyle cardTextStyle = TextStyle(fontSize: 17.0);
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
                      color: gender == 'Male' ? Colors.blue : Colors.pinkAccent,
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
            cardGroup(
              [
                infoCard(
                  Text(
                    (isPlanExpired) ? 'Plan Expired' : 'Plan Expire On',
                    style: cardTextStyle,
                  ),
                  planExpiryDate,
                ),
                infoCard(
                  Text('Total', style: cardTextStyle),
                  '$totalMoney \u20B9',
                ),
              ],
            ),
            cardGroup(
              [
                infoCard(Icon(Icons.phone, size: 25.0), mobile),
                infoCard(Icon(Icons.timelapse, size: 25.0), session),
                infoCard(Icon(Icons.cake, size: 25.0), dob),
              ],
            ),
            Divider(height: 10.0, color: Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget infoCard(Widget symbol, String? info) {
    return Column(
      children: [
        symbol,
        Divider(color: Colors.transparent, height: 5.0),
        Text(
          info ?? '-',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        )
      ],
    );
  }

  Widget cardGroup(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children
          .map(
            (c) => Container(
              padding: EdgeInsets.all(15.6),
              child: c,
            ),
          )
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
            TextSpan(text: ' Recharge Plan'),
          ],
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.only(top: 12.0, bottom: 12.0, right: 22.0, left: 22.0),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
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

        if (result == 'added') {
          setState(() {
            refreshAllData();
          });
        }
      },
    );
  }
}
