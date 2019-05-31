import 'package:flutter/material.dart';

class SingleCard extends StatelessWidget {

  final String firstname;
  final String lastname;
  final bool status;

  const SingleCard({Key key, this.firstname, this.lastname, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(5.0),
      child: _buildCardContent(),
    );
  }

  Container _buildCardContent() {
    TextStyle gymerFirstNameStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600);
    TextStyle gymerLastNameStyle = TextStyle(fontSize: 36.0, fontWeight: FontWeight.w200);
    return Container(
      height: 104.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(firstname, style: gymerFirstNameStyle),
                  ),
                  Text(lastname, style: gymerLastNameStyle),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
