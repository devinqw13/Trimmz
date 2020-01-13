import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentOptionsBottomSheet extends StatefulWidget {
  AppointmentOptionsBottomSheet({@required this.appointment, @required this.getAppointments, this.showCancel});
  final appointment;
  final ValueChanged getAppointments;
  final ValueChanged showCancel;

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
          color: Colors.grey[900],
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
                              child: Center(child: Text(appointment['name'].substring(0,1), style: TextStyle(fontSize: 20)))
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
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
                                      (DateTime.now().isAfter(DateTime.parse(appointment['full_time'])) && appointment['status'] == '0') ?
                                      Row(
                                        children: <Widget> [
                                          Expanded(
                                            child: Container(
                                              //width: MediaQuery.of(context).size.width,
                                              child: RaisedButton(
                                                onPressed: () {

                                                },
                                                child: Text('Complete Appointment'),
                                              )
                                            ) 
                                          )
                                        ]
                                      ): Container(),
                                      (DateTime.now().isAfter(DateTime.parse(appointment['full_time'])) && appointment['status'] != '0') ?
                                      Container() : Row(
                                        children: <Widget> [
                                          Expanded(
                                            child: Container(
                                              //width: MediaQuery.of(context).size.width,
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
                                      (DateTime.now().isAfter(DateTime.parse(appointment['full_time'])) && appointment['status'] == '0') ?
                                      Row(
                                        children: <Widget> [
                                          Expanded(
                                            child: Container(
                                              //width: MediaQuery.of(context).size.width,
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
  }
}