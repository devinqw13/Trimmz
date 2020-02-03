import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../globals.dart' as globals;
import '../calls.dart';

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

  @override
  void initState() {
    appointment = widget.appointment;
    super.initState();
  }

  clientCancel(int barberId, int appointmentId) async {
    var res =  await getBarberPolicies(context, barberId);
    if(res.cancelEnabled) {
      // TODO: charge customer the barbers cancelFee
    }else {
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
        widget.updateAppointments(res1);
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
                                  df2.format(DateTime.parse(appointment['full_time'])) + ' - ' + df2.format(DateTime.parse(appointment['full_time']).add(Duration(minutes: int.parse(appointment['duration'])))),
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
                                            '\$'+appointment['price'],
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
                                            '\$'+appointment['tip'],
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
                                            globals.spPayoutMethod == 'standard' ? '- \$' + ((double.parse(appointment['price']) + double.parse(appointment['tip'])) * .025).toStringAsFixed(2) : '- \$' + ((double.parse(appointment['price']) + double.parse(appointment['tip'])) * .03).toStringAsFixed(2),
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
                                            '\$' + (int.parse(appointment['price']) + int.parse(appointment['tip']) + 1).toString() :
                                            globals.spPayoutMethod == 'standard' ?
                                            '\$' + (double.parse(appointment['price']) + double.parse(appointment['tip']) -  ((double.parse(appointment['price']) + double.parse(appointment['tip'])) * .025)).toStringAsFixed(2) :
                                            '\$' + (double.parse(appointment['price']) + double.parse(appointment['tip']) -  ((double.parse(appointment['price']) + double.parse(appointment['tip'])) * .03)).toStringAsFixed(2),
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
                                      appointment['status'] == '0' && globals.userType == 2 ? Container(
                                        child: Column(
                                          children: <Widget>[
                                            DateTime.now().isAfter(DateTime.parse(appointment['full_time'])) ? Row(
                                              children: <Widget> [
                                                Expanded(
                                                  child: Container(
                                                    child: RaisedButton(
                                                      onPressed: () async {
                                                        //TODO: MARK STATUS COMPLETE(1) AND CHARGE CUSTOMER(PRICE + TIP + 1), ALSO DO PAYOUT BASED ON METHOD (Price + tip - fees(method))

                                                        List tokens = await getNotificationTokens(context, int.parse(appointment['clientid']));
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
                                                      onPressed: () async {
                                                        //TODO: MARK STATUS AS NO-SHOW(4) AND CHARGE CUSTOMER IF BARBER HAS NO-SHOW POLICY

                                                        List tokens = await getNotificationTokens(context, int.parse(appointment['clientid']));
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
                                                        
                                                      },
                                                      child: Text('Mark as no-show appointment'),
                                                    )
                                                  ) 
                                                )
                                              ]
                                            ) : Container()
                                          ]
                                        )
                                      ): (globals.userType != 2 && appointment['status'] == '0' && DateTime.now().isAfter(DateTime.parse(appointment['full_time']))) ? Container(
                                        child: RichText(
                                          softWrap: true,
                                          text: new TextSpan(
                                            children: <TextSpan> [
                                              new TextSpan(text: 'Pending: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                              new TextSpan(text: 'waiting for barber to update appointment', style: TextStyle(fontStyle: FontStyle.italic)),
                                            ]
                                          )
                                        )
                                      ) : (globals.userType != 2 && appointment['status'] == '0' && DateTime.now().isBefore(DateTime.parse(appointment['full_time']))) ? Row(
                                      children: <Widget> [
                                        Expanded(
                                          child: Container(
                                            child: RaisedButton(
                                              onPressed: () {
                                                clientCancel(int.parse(appointment['barberid']), int.parse(appointment['id']));
                                              },
                                              child: Text('Cancel Appointment'),
                                            )
                                          )
                                        )
                                      ]
                                    ) : (globals.userType != 2 && appointment['status'] == '3') ? Container(
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
                                              appointment['status'] == '2' ?
                                              new TextSpan(text: 'cancelled on: ', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)):
                                              appointment['status'] == '1' ?
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
                    child: Text('MESSAGES')
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
          ]
        )
      )
    );
  }
}