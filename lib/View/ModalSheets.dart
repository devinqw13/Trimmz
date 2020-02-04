import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../calls.dart';
import '../dialogs.dart';
import '../Model/Packages.dart';
import '../Model/AppointmentRequests.dart';
import 'package:intl/intl.dart';

addBarberPackage(BuildContext context, String name, double price, int duration) async {
  if(name == "" || price.toString() == "" || duration.toString() == "") {
    showErrorDialog(context, "Field Left Empty", "A field was left empty. Please enter all fields required.");
    return false;
  }else {
    var res = await addPackage(context, globals.token, name, duration, price);
    return res;
  }
}

Future<List<Packages>> showAddPackageModalSheet(BuildContext context) async {
  final TextEditingController _pkgName = new TextEditingController();
  final TextEditingController _pkgPrice = new TextEditingController();
  final TextEditingController _pkgDuration = new TextEditingController();
  List<Packages> results; 
  await showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 380,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 21, 21, 21),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Colors.grey[400], spreadRadius: 0)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'New Service',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.blue
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 18.0
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _pkgName,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.white
                    ),
                    decoration: new InputDecoration(
                      hintText: 'Enter package name',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.white
                        )
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)
                      )
                    ),
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 18.0
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _pkgPrice,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.white
                    ),
                    decoration: new InputDecoration(
                      hintText: 'Enter price',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.white
                        )
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)
                      )
                    ),
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Duration (Mins)',
                    style: TextStyle(
                      fontSize: 18.0
                    )
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _pkgDuration,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.white
                    ),
                    decoration: new InputDecoration(
                      hintText: 'Enter Duration',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: new UnderlineInputBorder(
                        borderSide: new BorderSide(
                          color: Colors.white
                        )
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)
                      )
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RaisedButton(
                      onPressed: () async {
                        if(_pkgPrice.text != '' && _pkgDuration.text != '' && _pkgName.text != ''){
                          var res = await addBarberPackage(context, _pkgName.text, double.parse(_pkgPrice.text), int.parse(_pkgDuration.text));
                          if(res) {
                            var res = await getBarberPkgs(context, globals.token);
                            Navigator.pop(context);
                            results = res;
                          }else {
                            return;
                          }
                        }else {
                          showErrorDialog(context, 'Missing Fields', 'Enter all fields to submit a new package');
                        }
                      },
                      child: Text('Add Package')
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RaisedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')
                    ),
                  ),
                ),
              ],
            ),
          ]
        ),
      )
    );
  });
  return results;
}

Future<int> showAptRequestsModalSheet(BuildContext context, List<AppointmentRequest> requests) async {
  int results;
  await showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, builder: (builder) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 455,
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
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          final df = new DateFormat('EEE, MMM d hh:mm a');
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget> [
                                Row(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          requests[i].clientName,
                                          style: TextStyle(
                                            fontSize: 20.0
                                          ),
                                        ),
                                        Text(df.format(DateTime.parse(requests[i].dateTime.toString()))),
                                        Text(requests[i].packageName),
                                      ]
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(5)
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: Center(
                                        child: Text(
                                          '\$' + (requests[i].price + requests[i].tip).toString(),
                                          textAlign: TextAlign.center,
                                        )
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        shape: BoxShape.circle
                                      ),
                                    ),
                                  ],
                                ),
                                DateTime.now().isAfter(requests[i].dateTime) ?
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Expired',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey
                                      )
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 0);

                                        List tokens = await getNotificationTokens(context, requests[i].clientId);
                                        for(var token in tokens){
                                          Map<String, dynamic> dataMap =  {
                                            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                            'action': 'APPOINTMENT_REQUEST',
                                            'title': 'Appointment Request Expired',
                                            'body': '${globals.username} has dismissed your appointment request because it has expired.',
                                            'sender': '${globals.token}',
                                            'recipient': requests[i].clientId,
                                          };
                                          await sendPushNotification(context, 'Appointment Request Expired', '${globals.username} has dismissed your appointment request because it has expired.', requests[i].clientId, token, dataMap);
                                        }

                                        Navigator.pop(context);
                                        results = result;
                                      },
                                      child: Text('Dismiss', style: TextStyle(color: Colors.blue)),
                                    ),
                                  ]
                                ) :
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () async {
                                        var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 0);

                                        List tokens = await getNotificationTokens(context, requests[i].clientId);
                                        for(var token in tokens){
                                          Map<String, dynamic> dataMap =  {
                                            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                            'action': 'APPOINTMENT_REQUEST',
                                            'title': 'Appointment Declined',
                                            'body': '${globals.username} has declined your appointment request.',
                                            'sender': '${globals.token}',
                                            'recipient': requests[i].clientId,
                                          };
                                          await sendPushNotification(context, 'Appointment Declined', '${globals.username} has declined your appointment request.', requests[i].clientId, token, dataMap);
                                        }

                                        Navigator.pop(context);
                                        results = result;
                                      },
                                      child: Text('Decline', style: TextStyle(color: Colors.red)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 1);

                                        List tokens = await getNotificationTokens(context, requests[i].clientId);
                                        for(var token in tokens){
                                          Map<String, dynamic> dataMap =  {
                                            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                            'action': 'APPOINTMENT_REQUEST',
                                            'title': 'Appointment Confirmed',
                                            'body': '${globals.username} has confirmed your appointment request.',
                                            'sender': '${globals.token}',
                                            'recipient': requests[i].clientId,
                                          };
                                          await sendPushNotification(context, 'Appointment Confirmed', '${globals.username} has confirmed your appointment request.', requests[i].clientId, token, dataMap);
                                        }

                                        Navigator.pop(context);
                                        results = result;
                                      },
                                      child: Text('Accept', style: TextStyle(color: Colors.blue)),
                                    ),
                                  ]
                                )
                              ]
                            ),
                          );
                        },
                      )
                    )
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
  return results;
}

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
                                new TextSpan(text: 'The standard transfer fee is 2.5% of the appointment amount. Standard transfer usually takes about 1-3 business days to deposit.'),
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
                                new TextSpan(text: 'The instant transfer fee is 3% of the appointment amount.'),
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