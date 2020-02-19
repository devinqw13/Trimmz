import 'package:flutter/material.dart';
import '../Calls/GeneralCalls.dart';
import '../globals.dart' as globals;

class CancelOptionsBottomSheet extends StatefulWidget {
  CancelOptionsBottomSheet({@required this.appointment, this.setAppointmentList, this.showAppointmentDetails});
  final appointment;
  final ValueChanged showAppointmentDetails;
  final ValueChanged setAppointmentList;

  @override
  _CancelOptionsBottomSheet createState() => _CancelOptionsBottomSheet();
}

class _CancelOptionsBottomSheet extends State<CancelOptionsBottomSheet> {
  var appointment;

  @override
  void initState() {
    appointment = widget.appointment;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
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
                          child: RaisedButton(
                            onPressed: () async {
                              //TODO: Cancel appointment and charge customer the price amount
                              List tokens = await getNotificationTokens(context, int.parse(appointment['clientid']));
                              for(var token in tokens){
                                Map<String, dynamic> dataMap =  {
                                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                  'action': 'APPOINTMENT',
                                  'title': 'Appointment Cancelled',
                                  'body': '${globals.username} has cancelled your appointment',
                                  'sender': '${globals.token}',
                                  'recipient': appointment['clientid'],
                                  'appointment': appointment,
                                };
                                await sendPushNotification(context, 'Appointment Cancelled', '${globals.username} has cancelled your appointment with a cancellation fee', int.parse(appointment['clientid']), token, dataMap);
                              }
                            },
                            child: Text('Cancel with payment'),
                          )
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            onPressed: () async {
                              var res1 = await updateAppointmentStatus(context, int.parse(appointment['id']), 2);
                              if(res1) {
                                List tokens = await getNotificationTokens(context, int.parse(appointment['clientid']));
                                for(var token in tokens){
                                  Map<String, dynamic> dataMap =  {
                                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                    'action': 'APPOINTMENT',
                                    'title': 'Appointment Cancelled',
                                    'body': '${globals.username} has cancelled your appointment',
                                    'sender': '${globals.token}',
                                    'recipient': '${appointment['clientid']}',
                                    'appointment': appointment,
                                  };
                                  await sendPushNotification(context, 'Appointment Cancelled', '${globals.username} has cancelled your appointment.', int.parse(appointment['clientid']), token, dataMap);
                                }

                                var res2 = await getBarberAppointments(context, globals.token);
                                Navigator.pop(context);
                                widget.setAppointmentList(res2);
                                setState(() {
                                  appointment['status'] = '2';
                                  appointment['updated'] = DateTime.now().toString();
                                });
                                widget.showAppointmentDetails(appointment);
                              }
                            },
                            child: Text('Cancel without payment'),
                          )
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
                              widget.showAppointmentDetails(appointment);
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
  }
}