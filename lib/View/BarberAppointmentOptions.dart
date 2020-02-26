import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/Calls/FinancialCalls.dart';
import 'package:trimmz/Model/BarberPolicies.dart';
import '../Calls/FinancialCalls.dart';
import '../globals.dart' as globals;
import '../Calls/GeneralCalls.dart';
import 'package:progress_hud/progress_hud.dart';

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

    standardBarberPrice = (((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) - ((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * .025)) * 100).toStringAsFixed(0);

    instantBarberPrice = (((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) - ((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * .03))).toStringAsFixed(2);
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

  clientCancel(int barberId, int appointmentId) async {
    var res = await getBarberPolicies(context, barberId) ?? new BarberPolicies();
    if(res.cancelEnabled) {
      // TODO: charge customer the barbers cancelFee
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
          await sendPushNotification(context, 'Appointment Cancelled', '${globals.username} has cancelled their appointment with you.', int.parse(appointment['clientid']), token, dataMap);
        }
        setState(() {
          appointment['updated'] = DateTime.now().toString();
          appointment['status'] = '2';
        });
        var res1 = await getUserAppointments(context, globals.token);
        progressHUD();
        widget.updateAppointments(res1);
      }
    }
  }

  markNoShow() async {
    //TODO: MARK STATUS AS NO-SHOW(4) AND CHARGE CUSTOMER IF BARBER HAS NO-SHOW POLICY
    var res = await getBarberPolicies(context, appointment['barberid']) ?? new BarberPolicies();
    if(res.noShowEnabled) {
      if(res.noShowFee.contains('\$')){
        var stringList = res.noShowFee.split('\$');
        print(stringList);
        // var res2 = await spChargeCard(context, int.parse(stringList[1]), appointment['paymentid'], appointment['customerid'], appointment['email']);
        // if(res2) {
        //   setState(() {
        //     appointment['status'] = 4;
        //   });
        //   List tokens = await getNotificationTokens(context, appointment['clientid']);
        //   for(var token in tokens){
        //     Map<String, dynamic> dataMap =  {
        //       'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        //       'action': 'APPOINTMENT',
        //       'title': 'No-Show Appointment',
        //       'body': '${globals.username} has marked your appointment as a no-show',
        //       'sender': '${globals.token}',
        //       'recipient': '${appointment['clientid']}',
        //       'appointment': appointment,
        //     };
        //     await sendPushNotification(context, 'No-Show Appointment', '${globals.username} has marked your appointment as a no-show', int.parse(appointment['clientid']), token, dataMap);
        //   }
        // }
      }else {

      }
    }else {
      updateAppointmentStatus(context, appointment['id'], 4);
      List tokens = await getNotificationTokens(context, appointment['clientid']);
      for(var token in tokens){
        Map<String, dynamic> dataMap =  {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'action': 'APPOINTMENT',
          'title': 'No-Show Appointment',
          'body': '${globals.username} has marked your appointment as a no-show',
          'sender': '${globals.token}',
          'recipient': '${appointment['clientid']}',
          'appointment': appointment,
        };
        await sendPushNotification(context, 'No-Show Appointment', '${globals.username} has marked your appointment as a no-show', int.parse(appointment['clientid']), token, dataMap);
      }
    }
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
                  Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple,
                                gradient: new LinearGradient(
                                  colors: [Color(0xFFF9F295), Color(0xFFB88A44)],
                                )
                              ),
                              child: globals.userType != 2 ? Center(
                                child: Text(appointment['barber_name'].substring(0,1), style: TextStyle(fontSize: 20))
                              ) : Center(child: Text(appointment['name'].substring(0,1), style: TextStyle(fontSize: 20)))
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  globals.userType != 2 ? appointment['barber_name'] : appointment['name'], 
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(
                                  df.format(DateTime.parse(appointment['full_time'])),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  df2.format(DateTime.parse(appointment['full_time'])) + ' - ' + df2.format(DateTime.parse(appointment['full_time']).add(Duration(minutes: appointment['duration']))),
                                  style: TextStyle(
                                    color: Colors.grey
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
                                              color: Colors.grey
                                            )
                                          ),
                                          Text(
                                            '\$'+appointment['price'].toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey
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
                                              color: Colors.grey
                                            )
                                          ),
                                          Text(
                                            '\$'+appointment['tip'].toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey
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
                                              color: Colors.grey
                                            )
                                          ),
                                          Text(
                                            '\$1',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey
                                            )
                                          )
                                        ]
                                      ) :
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            globals.spPayoutMethod == 'standard' ? 'Fees (2.5%)' : 'Fees (3%)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey
                                            )
                                          ),
                                          Text(
                                            globals.spPayoutMethod == 'standard' ? '- \$' + ((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * .025).toStringAsFixed(2) : '- \$' + ((double.parse(appointment['price'].toString()) + double.parse(appointment['tip'].toString())) * .03).toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey
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
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold
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
                                              color: Colors.white,
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
                                                      onPressed: () async {
                                                        progressHUD();
                                                        int total = appointment['price'] + appointment['tip'];
                                                        var res = await spChargeCard(context, total, appointment['paymentid'], appointment['customerid'], appointment['email']);
                                                        if(res) {
                                                          var res2 = await updateAppointmentStatus(context, appointment['id'], 1);
                                                          if(res2) {
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
                                                              await sendPushNotification(context, 'Appointment Completed', '${globals.username} has completed your appointment.', int.parse(appointment['clientid']), token, dataMap);
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
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        widget.showCancel(true);
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