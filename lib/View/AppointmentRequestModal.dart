import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Model/AppointmentRequests.dart';
import 'package:intl/intl.dart';
import '../globals.dart' as globals;
import '../Calls/GeneralCalls.dart';
import '../dialogs.dart';
import 'package:progress_hud/progress_hud.dart';

class AppointmentRequestBottomSheet extends StatefulWidget {
  AppointmentRequestBottomSheet({this.requests, this.updateAppointments, this.updateAppointmentRequests});
  final List<AppointmentRequest> requests;
  final ValueChanged updateAppointments;
  final ValueChanged updateAppointmentRequests;

  @override
  _AppointmentRequestBottomSheet createState() => _AppointmentRequestBottomSheet();
}

class _AppointmentRequestBottomSheet extends State<AppointmentRequestBottomSheet> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<AppointmentRequest> requests;

  @override
  void initState() {
    setState(() {
      requests = widget.requests;
    });
    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
    super.initState();
  }

  void progressHUD() {
    setState(() {
      if (_loadingInProgress) {
        _progressHUD.state.dismiss();
      } else {
        _progressHUD.state.show();
      }
      _loadingInProgress = !_loadingInProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: MediaQuery.of(context).size.height * .5,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: globals.darkModeEnabled ? Color.fromARGB(255, 21, 21, 21) : Color(0xFFFAFAFA),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2, color: Colors.grey[400], spreadRadius: 0
            )
          ]
        ),
        child: new Stack(
          children: <Widget> [
            Container(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: requests.length,
                        padding: const EdgeInsets.all(5.0),
                        itemBuilder: (context, i) {
                          final df = new DateFormat('EEE, MMM d h:mm a');
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
                                        color: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[300],
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
                                        progressHUD();
                                        var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 0);
                                        if(result) {
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
                                            await sendPushNotification(context, 'Appointment Request Expired', '${globals.username} has dismissed your appointment request because it has expired.', token, dataMap);
                                          }

                                          var res = await getBarberAppointmentRequests(context, globals.token);
                                          progressHUD();
                                          setState(() {
                                            requests = res;
                                          });
                                          widget.updateAppointmentRequests(res);

                                          if(requests.length == 0) {
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                      child: Text('Dismiss', style: TextStyle(color: Colors.blue)),
                                    ),
                                  ]
                                ) :
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () async {
                                        progressHUD();
                                        var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 0);
                                        if(result){
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
                                            await sendPushNotification(context, 'Appointment Declined', '${globals.username} has declined your appointment request.', token, dataMap);
                                          }

                                          var res = await getBarberAppointmentRequests(context, globals.token);
                                          progressHUD();
                                          setState(() {
                                            requests = res;
                                          });
                                          widget.updateAppointmentRequests(res);

                                          if(requests.length == 0) {
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                      child: Text('Decline', style: TextStyle(color: Colors.red)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if(globals.spPayoutId == null) {
                                          showErrorDialog(context, 'Action Required', 'You must enter direct deposit information before accepting appointments.');
                                        }else {
                                          progressHUD();
                                          var result = await aptRequestDecision(context, globals.token, requests[i].requestId, 1);
                                          if(result) {
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
                                              await sendPushNotification(context, 'Appointment Confirmed', '${globals.username} has confirmed your appointment request.', token, dataMap);
                                            }

                                            var res = await getBarberAppointmentRequests(context, globals.token);
                                            setState(() {
                                              requests = res;
                                            });
                                            var res2 = await getBarberAppointments(context, globals.token);
                                            progressHUD();
                                            widget.updateAppointments(res2);
                                            widget.updateAppointmentRequests(res);

                                            if(requests.length == 0) {
                                              Navigator.pop(context);
                                            }
                                          }
                                        }
                                      },
                                      child: Text('Accept', style: TextStyle(color: Colors.blue)),
                                    ),
                                  ]
                                )
                              ]
                            ),
                          );
                        }
                      )
                    )
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RaisedButton(
                            color: Colors.blue,
                            textColor: Colors.white,
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
            _progressHUD
          ]
        )
      )
    );
  }
}