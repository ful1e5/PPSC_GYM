import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/services/database/handler.dart';

import 'package:ppscgym/pages/member/add.dart';
import 'package:ppscgym/pages/payment/payments.dart';
import 'package:ppscgym/pages/plans.dart';

import 'package:ppscgym/styles.dart';
import 'package:ppscgym/widgets.dart';
import 'package:ppscgym/utils.dart';

class MemberInfoPage extends StatefulWidget {
  final int memberId;

  const MemberInfoPage({Key? key, required this.memberId}) : super(key: key);

  @override
  _MemberInfoPageState createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  late Future<Member> infoFuture;
  late Future<List<Payment>> paymentsFuture;
  late bool isPlanExpired;

  @override
  void initState() {
    super.initState();
    refreshMemberData(0);
    refreshPaymentsData(0);
  }

  refreshMemberData(int seconds) {
    final DatabaseHandler handler = DatabaseHandler();

    infoFuture = Future<Member>.delayed(
      Duration(seconds: seconds, microseconds: 10),
      () => handler.retrieveMember(widget.memberId),
    );
  }

  refreshPaymentsData(int seconds) {
    final DatabaseHandler handler = DatabaseHandler();
    paymentsFuture = Future<List<Payment>>.delayed(
      Duration(seconds: seconds, microseconds: 20),
      () => handler.retriveMemberPayments(widget.memberId),
    );
  }

  void refreshAllData() {
    setState(() {
      refreshMemberData(0);
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
      builder: (BuildContext context, AsyncSnapshot<Member> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loaderWidget();
        } else if (snapshot.hasError) {
          return centerMessageWidget('Error !');
        } else if (snapshot.hasData) {
          //Initiating plan expiry boolean
          Member member = snapshot.data!;
          setPlanExpiry(member.planExpiryDate);

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: buildAppBar(member),
            body: buildBody(member),
          );
        } else {
          return centerMessageWidget('Data Not Found.');
        }
      },
    );
  }

  AppBar buildAppBar(Member member) {
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
                builder: (context) => AddMemberPage(data: member),
              ),
            );

            if (result == 'member updated') {
              setState(() {
                refreshMemberData(0);
              });
            }
          },
        ),
      ],
    );
  }

  Widget buildBody(Member member) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          memberInfo(member),
          gapWidget(7.0),

          // CoolDown Widget
          (isPlanExpired)
              //TODO: Test real time
              ? membershipButton(member)
              : CountDown(
                  text: 'Plan Countdown',
                  time: stringToDateTime(member.planExpiryDate!),
                  onTimeout: refreshAllData,
                ),
          gapWidget(10.0),

          PaymentHistory(
            future: paymentsFuture,
            onDelete: refreshAllData,
          ),
        ],
      ),
    );
  }

  Widget memberInfo(Member member) {
    String id = member.id.toString();
    String name = member.name;
    String gender = member.gender;
    String session = member.session;
    String dob = member.dob.toString();
    String mobile = member.mobile.toString();
    String? planExpiryDate = member.planExpiryDate;
    String totalMoney = member.totalMoney.toString();

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
                      getGenderIcon(gender),
                      size: 34.0,
                      color: gender == 'Male' ? Colors.blue : Colors.pinkAccent,
                    ),
                  ),
                ],
              ),
            ),
            gapWidget(10.0),
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
            gapWidget(20.0),
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
            gapWidget(10.0),
          ],
        ),
      ),
    );
  }

  Widget infoCard(Widget symbol, String? info) {
    return Column(
      children: [
        symbol,
        gapWidget(5.0),
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

  Widget membershipButton(Member member) {
    return OutlinedButton(
      style: materialButtonStyle(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 13.0,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 19.5,
            fontWeight: FontWeight.w800,
          ),
          children: [
            WidgetSpan(
              child: const Icon(
                Icons.assignment_ind,
                size: 26.0,
              ),
            ),
            TextSpan(text: '  Get Membership'),
          ],
        ),
      ),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlansPage(
              select: true,
              member: member,
            ),
          ),
        );

        if (result == 'payment added') {
          setState(() {
            refreshAllData();
          });
        }
      },
    );
  }
}
