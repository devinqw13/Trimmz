import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/Calls/FinancialCalls.dart';
import 'package:trimmz/Model/BarberPolicies.dart';
import '../Calls/FinancialCalls.dart';
import '../functions.dart';
import '../globals.dart' as globals;
import '../Calls/GeneralCalls.dart';
import 'package:progress_hud/progress_hud.dart';
import '../View/Widgets.dart';

class AppointmentOptionsBottomSheet extends StatefulWidget {
  AppointmentOptionsBottomSheet({@required this.appointment, @required this.showCancel, this.showFullCalendar, this.showFull, this.updateAppointments});
  final appointment;
  final ValueChanged showCancel;
  final bool showFull;
  final ValueChanged showFullCalendar;
  final ValueChanged updateAppointments;

  @override
  _AppointmentOptionsBottomSheet createState() => _AppointmentOptionsBottomSheet();
}

class _AppointmentOptionsBottomSheet extends State<AppointmentOptionsBottomSheet> {
  var appointment;
  final df = new DateFormat('EEEE, MMMM d, y');
  final df2 = new DateFormat('h:mm a');
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  bool canPress = true;
  String standardBarberPrice = '';
  String instantBarberPrice = '';

  @override
  void initState() {
    appointment = widget.appointment;
    print(appointment);
    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    standardBarberPrice = (((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) - num.parse(((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * globals.stdRateFee).toStringAsFixed(2))) * 100).toStringAsFixed(0);

    instantBarberPrice = (((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) - num.parse(((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * globals.intRateFee).toStringAsFixed(2))) * 100).toStringAsFixed(0);
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

  showWarningDialog(BuildContext context, BarberPolicies policy, int barberId) {
  return showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Center(child: Text('Cancel Appointment',
        style: TextStyle(fontSize: 19.0),)),
      content: new Container(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text("You will be charged ${policy.cancelFee.contains('\$') ? '${policy.cancelFee}' : '${policy.cancelFee} of the appointment amount'} for violating the barber\'s cancel policy",
              style: new TextStyle(
                fontSize: 13.0
              ),
              textAlign: TextAlign.left,
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new RaisedButton(
                    child: new Text("OK",
                    textAlign: TextAlign.center),
                    onPressed: () async {
                      if(canPress) {
                        setState(() {
                          canPress = false;
                        });

                        var total;
                        if(policy.cancelFee.contains('\$')) {
                          total = int.parse(policy.cancelFee.replaceAll(new RegExp('[\\\$]'),''));
                        }else {
                          double percent = (int.parse(policy.cancelFee.replaceAll(new RegExp('[\\%]'),'')) / 100);
                          total = (appointment['price'] * percent);
                        }

                        var res = await spChargeCard(context, total, globals.spPaymentId, globals.spCustomerId, appointment['email'], appointment['barberSPID'], appointment['barberSPMethod'], appointment['barberSPPayout']);
                        if(res) {
                          var res2 = await updateAppointmentStatus(context, appointment['id'], 2);
                          if(res2) {
                            List tokens = await getNotificationTokens(context, barberId);
                            for(var token in tokens){
                              Map<String, dynamic> dataMap =  {
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                'action': 'APPOINTMENT',
                                'title': 'Appointment Cancelled',
                                'body': '${globals.username} has cancelled their appointment with you',
                                'sender': '${globals.token}',
                                'recipient': '$barberId',
                                'appointment': appointment,
                              };
                              await sendPushNotification(context, 'Appointment Cancelled', '${globals.username} has cancelled their appointment with you.', token, dataMap);
                            }
                            setState(() {
                              appointment['updated'] = DateTime.now().toString();
                              appointment['status'] = 2;
                            });
                            var res1 = await getUserAppointments(context, globals.token);
                            widget.updateAppointments(res1);
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                new Expanded(
                  child: new RaisedButton(
                    child: new Text("Cancel",
                    textAlign: TextAlign.center),
                    onPressed: () { 
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            )
          ],
        )
      ),
    )
  );
}
  clientCancel(int barberId, int appointmentId) async {
    progressHUD();
    var res = await getBarberPolicies(context, barberId) ?? new BarberPolicies();
    if(res.cancelEnabled) {
      if(DateTime.parse(appointment['full_time']).difference(DateTime.now()).inHours < res.cancelWithinTime) {
        progressHUD();
        showWarningDialog(context, res, barberId);
      }else {
        print('here');
        var res = await updateAppointmentStatus(context, appointmentId, 2);
        if(res) {
          List tokens = await getNotificationTokens(context, barberId);
          for(var token in tokens){
            Map<String, dynamic> dataMap =  {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'action': 'APPOINTMENT',
              'title': 'Appointment Cancelled',
              'body': '${globals.username} has cancelled their appointment with you',
              'sender': '${globals.token}',
              'recipient': '$barberId',
              'appointment': appointment,
            };
            await sendPushNotification(context, 'Appointment Cancelled', '${globals.username} has cancelled their appointment with you.', token, dataMap);
          }
          setState(() {
            appointment['updated'] = DateTime.now().toString();
            appointment['status'] = 2;
          });
          var res1 = await getUserAppointments(context, globals.token);
          progressHUD();
          widget.updateAppointments(res1);
        }
      }
    }else {
      progressHUD();
      var res = await updateAppointmentStatus(context, appointmentId, 2);
      if(res) {
        List tokens = await getNotificationTokens(context, barberId);
        for(var token in tokens){
          Map<String, dynamic> dataMap =  {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'action': 'APPOINTMENT',
            'title': 'Appointment Cancelled',
            'body': '${globals.username} has cancelled their appointment with you',
            'sender': '${globals.token}',
            'recipient': '$barberId',
            'appointment': appointment,
          };
          await sendPushNotification(context, 'Appointment Cancelled', '${globals.username} has cancelled their appointment with you.', token, dataMap);
        }
        setState(() {
          appointment['updated'] = DateTime.now().toString();
          appointment['status'] = 2;
        });
        var res1 = await getUserAppointments(context, globals.token);
        progressHUD();
        widget.updateAppointments(res1);
      }
    }
  }

  markNoShow() async {
    progressHUD();
    var res = await getBarberPolicies(context, appointment['barberid']) ?? new BarberPolicies();
    if(res.noShowEnabled) {
      if(res.noShowFee.contains('\$')){
        var amountFee = res.noShowFee.split('\$')[1];
        
      }else {
        var amountFee = res.noShowFee.split('%')[0];
        
      }
    }else {
      var res = await updateAppointmentStatus(context, appointment['id'], 4);
      if(res) {
        var res1 = await getBarberAppointments(context, globals.token);
        widget.updateAppointments(res1);
        setState(() {
          appointment['status'] = 4;
        });
      }
    }
    List tokens = await getNotificationTokens(context, appointment['clientid']);
    sendNotifications(context, tokens, appointment['clientid'], 'No-Show Appointment', '${globals.username} has marked your appointment as a no-show', 'APPOINTMENT', appointment, 'appointment');
    progressHUD();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 655,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: globals.darkModeEnabled ? Color.fromARGB(255, 21, 21, 21) : Color(0xFFFAFAFA),
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
                  Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            globals.userType != 2 ?
                            buildProfilePictures(context, appointment['barber_pp'], appointment['barber_name'], 25) :
                            buildProfilePictures(context, appointment['client_pp'], appointment['clientid'] == 0 ? appointment['manual_client_name'] : appointment['name'], 25),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  globals.userType != 2 ? appointment['barber_name'] : appointment['clientid'] == 0 ? appointment['manual_client_name'] : appointment['name'], 
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: globals.darkModeEnabled ? Colors.white : Colors.black
                                  )
                                ),
                                Text(
                                  df.format(DateTime.parse(appointment['full_time'])),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: globals.darkModeEnabled ? Colors.white : Colors.black
                                  ),
                                ),
                                Text(
                                  df2.format(DateTime.parse(appointment['full_time'])) + ' - ' + df2.format(DateTime.parse(appointment['full_time']).add(Duration(minutes: appointment['duration']))),
                                  style: TextStyle(
                                    color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10, top: 10),
                                  color: Colors.grey,
                                  width: MediaQuery.of(context).size.width * .7,
                                  height: 1
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .7,
                                  child: Column(
                                    children: <Widget> [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Amount',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          ),
                                          Text(
                                            '\$'+appointment['price'].toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          )
                                        ]
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Tip',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          ),
                                          Text(
                                            '\$'+appointment['tip'].toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          )
                                        ]
                                      ),
                                      globals.userType != 2 ? Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Processing Fees',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          ),
                                          Text(
                                            '\$1',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          )
                                        ]
                                      ) :
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            globals.spPayoutMethod == 'standard' ? 'Fees (${(globals.stdRateFee * 100).toStringAsFixed(1)}%)' : 'Fees (${(globals.intRateFee * 100).toStringAsFixed(1)}%)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          ),
                                          Text(
                                            globals.spPayoutMethod == 'standard' ? '- \$' + ((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * globals.stdRateFee).toStringAsFixed(2) :
                                            '- \$' + ((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * globals.intRateFee).toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: globals.darkModeEnabled ? Colors.grey : Colors.grey[700]
                                            )
                                          )
                                        ]
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: globals.darkModeEnabled ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            )
                                          ),
                                          Text(
                                            globals.userType != 2 ?
                                            '\$' + (appointment['price'] + appointment['tip'] + 1).toString() :
                                            globals.spPayoutMethod == 'standard' ?
                                            '\$' + (double.parse(standardBarberPrice) / 100).toString() :
                                            '\$' + (double.parse(instantBarberPrice) / 100).toString(),
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: globals.darkModeEnabled ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold
                                            )
                                          )
                                        ]
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10, top: 10),
                                        color: Colors.grey,
                                        width: MediaQuery.of(context).size.width * .7,
                                        height: 1
                                      ),
                                      appointment['status'] == 0 && globals.userType == 2 ? Container(
                                        child: Column(
                                          children: <Widget>[
                                            DateTime.now().isAfter(DateTime.parse(appointment['full_time'])) ? Row(
                                              children: <Widget> [
                                                Expanded(
                                                  child: Container(
                                                    child: RaisedButton(
                                                      color: Colors.blue,
                                                      textColor: Colors.white,
                                                      onPressed: () async {
                                                        progressHUD();
                                                        if(appointment['clientid'] == 0) {
                                                          print('here');
                                                          var res2 = await updateAppointmentStatus(context, appointment['id'], 1);
                                                          if(res2) {
                                                            var res1 = await getBarberAppointments(context, globals.token);
                                                            widget.updateAppointments(res1);
                                                            setState(() {
                                                              appointment['status'] = 1;
                                                            });
                                                          }
                                                        }else {
                                                          int total = appointment['price'] + appointment['tip'];
                                                          var res = await spChargeCard(context, total, appointment['paymentid'], appointment['customerid'], appointment['email']);
                                                          if(res) {
                                                            var res2 = await updateAppointmentStatus(context, appointment['id'], 1);
                                                            if(res2) {
                                                              var res1 = await getBarberAppointments(context, globals.token);
                                                              widget.updateAppointments(res1);
                                                              setState(() {
                                                                appointment['status'] = 1;
                                                              });
                                                              List tokens = await getNotificationTokens(context, appointment['clientid']);
                                                              for(var token in tokens){
                                                                Map<String, dynamic> dataMap =  {
                                                                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                                                  'action': 'APPOINTMENT',
                                                                  'title': 'Appointment Completed',
                                                                  'body': '${globals.username} has cancelled your appointment',
                                                                  'sender': '${globals.token}',
                                                                  'recipient': '${appointment['clientid']}',
                                                                  'appointment': appointment,
                                                                };
                                                                await sendPushNotification(context, 'Appointment Completed', '${globals.username} has completed your appointment.', token, dataMap);
                                                              }
                                                            }
                                                          }
                                                        }
                                                        progressHUD();
                                                      },
                                                      child: Text('Complete Appointment'),
                                                    )
                                                  ) 
                                                )
                                              ]
                                            ) : Container(),
                                            Row(
                                              children: <Widget> [
                                                Expanded(
                                                  child: Container(
                                                    child: RaisedButton(
                                                      color: Colors.blue,
                                                      textColor: Colors.white,
                                                      onPressed: () async {
                                                        if(appointment['clientid'] == 0) {
                                                          progressHUD();
                                                          var res1 = await updateAppointmentStatus(context, appointment['id'], 2);
                                                          if(res1) {
                                                            var res1 = await getBarberAppointments(context, globals.token);
                                                            widget.updateAppointments(res1);
                                                            setState(() {
                                                              appointment['status'] = 2;
                                                            });
                                                          }
                                                          progressHUD();
                                                        }else {
                                                          widget.showCancel(true);
                                                        }
                                                      },
                                                      child: Text('Cancel Appointment'),
                                                    )
                                                  )
                                                )
                                              ]
                                            ),
                                            DateTime.now().isAfter(DateTime.parse(appointment['full_time'])) ? Row(
                                              children: <Widget> [
                                                Expanded(
                                                  child: Container(
                                                    child: RaisedButton(
                                                      color: Colors.blue,
                                                      textColor: Colors.white,
                                                      onPressed: () {
                                                        markNoShow();
                                                      },
                                                      child: Text('Mark as no-show appointment'),
                                                    )
                                                  ) 
                                                )
                                              ]
                                            ) : Container()
                                          ]
                                        )
                                      ): (globals.userType != 2 && appointment['status'] == 0 && DateTime.now().isAfter(DateTime.parse(appointment['full_time']))) ? Container(
                                        child: RichText(
                                          softWrap: true,
                                          text: new TextSpan(
                                            style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                                            children: <TextSpan> [
                                              new TextSpan(text: 'Pending: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                              new TextSpan(text: 'waiting for barber to update appointment', style: TextStyle(fontStyle: FontStyle.italic)),
                                            ]
                                          )
                                        )
                                      ) : (globals.userType != 2 && appointment['status'] == 0 && DateTime.now().isBefore(DateTime.parse(appointment['full_time']))) ? Row(
                                      children: <Widget> [
                                        Expanded(
                                          child: Container(
                                            child: RaisedButton(
                                              onPressed: () {
                                                clientCancel(appointment['barberid'], appointment['id']);
                                              },
                                              child: Text('Cancel Appointment'),
                                            )
                                          )
                                        )
                                      ]
                                    ) : (globals.userType != 2 && appointment['status'] == 3) ? Container(
                                        child: RichText(
                                          softWrap: true,
                                          text: new TextSpan(
                                            style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                                            children: <TextSpan> [
                                              DateTime.now().isBefore(DateTime.parse(appointment['full_time'])) ?
                                              new TextSpan(text: 'Pending: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)) :
                                              new TextSpan(text: 'Expired: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),

                                              DateTime.now().isBefore(DateTime.parse(appointment['full_time'])) ?
                                              new TextSpan(text: 'waiting for barber to accept or decline appointment', style: TextStyle(fontStyle: FontStyle.italic)) :
                                              new TextSpan(text: 'barber didn\'t respond to request in time', style: TextStyle(fontStyle: FontStyle.italic)),
                                            ]
                                          )
                                        )
                                      ) : Container(
                                        child:
                                        RichText(
                                          softWrap: true,
                                          text: new TextSpan(
                                            style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                                            children: <TextSpan>[
                                              new TextSpan(text: 'Marked ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                              appointment['status'] == 2 ?
                                              new TextSpan(text: 'cancelled on: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)):
                                              appointment['status'] == 1 ?
                                              new TextSpan(text: 'completed on: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)) :
                                              new TextSpan(text: 'no-show on: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                              new TextSpan(text: df.format(DateTime.parse(appointment['updated'])), style: TextStyle(fontStyle: FontStyle.italic)),
                                            ],
                                          ),
                                        ),
                                      )
                                    ]
                                  )
                                ),
                              ]
                            )
                          ]
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10, top: 10),
                    color: Colors.grey,
                    width: MediaQuery.of(context).size.width,
                    height: 1
                  ),
                  Expanded(
                    child: Container()
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
                              if(widget.showFull == null){
                                Navigator.pop(context);
                              }else {
                                Navigator.pop(context);
                                widget.showFullCalendar(DateTime.parse(appointment['full_time']));
                              }
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