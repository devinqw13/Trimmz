import 'package:flutter/material.dart';
import '../globals.dart' as globals;

showPayoutInfoModalSheet(BuildContext context) async {
  showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 255,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.grey[400],
              spreadRadius: 0
            )
          ]
        ),
        child: Stack(
          children: <Widget> [
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RichText(
                            softWrap: true,
                            text: new TextSpan(
                              children: <TextSpan>[
                                new TextSpan(text: 'Standard Transfer: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: 'The standard transfer fee is ${(globals.stdRateFee * 100).toStringAsFixed(1)}% of the appointment amount. Standard transfer usually takes about 1-3 business days to deposit.'),
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10),),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RichText(
                            softWrap: true,
                            text: new TextSpan(
                              children: <TextSpan>[
                                new TextSpan(text: 'Instant Transfer: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: 'The instant transfer fee is ${(globals.intRateFee * 100).toStringAsFixed(1)}% of the appointment amount.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close')
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ]
        )
      )
    );
  });
}