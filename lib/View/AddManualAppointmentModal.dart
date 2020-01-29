import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../calls.dart';

class AddManualAppointmentModal extends StatefulWidget {
  AddManualAppointmentModal({@required this.selectedDate, this.updateAppointmentList, this.showFullCalendar});
  final DateTime selectedDate;
  final ValueChanged updateAppointmentList;
  final ValueChanged showFullCalendar;

  @override
  _AddManualAppointmentModal createState() => _AddManualAppointmentModal();
}

class _AddManualAppointmentModal extends State<AddManualAppointmentModal> {
  bool show = false; // REMOVE JUST A PLACE HOLDER FOR CHECK

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: MediaQuery.of(context).size.height * .9,
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
                // add body widgets
                Container()
              ],
            ),
            Column(
              children: <Widget> [
                (show) ? Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () async {
                            Navigator.pop(context);
                            //widget.updateAppointmentList();
                            widget.showFullCalendar(widget.selectedDate);
                          },
                          child: Text('Book Appointment')
                        )
                      )
                    )
                  ]
                ) : Container(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () async {
                            Navigator.pop(context);
                            widget.showFullCalendar(widget.selectedDate);
                          },
                          child: Text('Cancel')
                        )
                      )
                    )
                  ]
                )
              ]
            )
          ]
        ),
      )
    );
  }
}