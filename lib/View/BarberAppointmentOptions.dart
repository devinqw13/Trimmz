import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../globals.dart' as globals;

class AppointmentOptionsBottomSheet extends StatefulWidget {
  AppointmentOptionsBottomSheet({@required this.appointment, @required this.showCancel, this.showFullCalendar, this.showFull});
  final appointment;
  final ValueChanged showCancel;
  final bool showFull;
  final ValueChanged showFullCalendar;

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
                              //TODO: dynamic with barber or client based on account type
                              child: Center(child: Text(appointment['name'].substring(0,1), style: TextStyle(fontSize: 20)))
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //TODO: dynamic with barber or client based on account type
                                Text(
                                  appointment['name'], 
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
                                      //TODO: dynamic fee based on transfer method
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Fees (2.5%)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey
                                            )
                                          ),
                                          Text(
                                            '- \$' + ((double.parse(appointment['price']) + double.parse(appointment['tip'])) * .025).toStringAsFixed(2),
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
                                            '\$' + (double.parse(appointment['price']) + double.parse(appointment['tip']) -  ((double.parse(appointment['price']) + double.parse(appointment['tip'])) * .025)).toStringAsFixed(2),
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
                                                      onPressed: () {

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
                                      ) : (globals.userType != 2 && appointment['status'] == '0' && DateTime.now().isBefore(DateTime.parse(appointment['full_time']))) ? Container(
                                        child: RichText(
                                          softWrap: true,
                                          text: new TextSpan(
                                            children: <TextSpan> [
                                              new TextSpan(text: 'Appointment coming soon', style: new TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                            ]
                                          )
                                        )
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