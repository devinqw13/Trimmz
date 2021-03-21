import 'package:flutter/material.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:trimmz/Controller/AppointmentDetailsController.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/calls.dart';
import 'package:auto_size_text/auto_size_text.dart';

class UserAppointmentControlButtons extends StatefulWidget {
  final controllerState;
  final ValueChanged<Appointment> onUpdate;
  final Appointment appointment;
  UserAppointmentControlButtons({Key key, this.onUpdate, @required this.appointment, @required this.controllerState});

  @override
  _UserAppointmentControlButtons createState() => _UserAppointmentControlButtons();
}

class _UserAppointmentControlButtons extends State<UserAppointmentControlButtons> {
  Widget viewButton;
  Widget completeButton;
  Widget cancelButton;
  Widget noShowButton;

  void initState() {
    viewButton = new Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: RaisedButton(
          color: Color(0xFFF7F7F7),
          onPressed: () => viewAppointment(widget.appointment),
          child: AutoSizeText(
            "View",
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(
              color: Colors.black
            ),
          ),
        )
      )
    );

    completeButton = new Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: RaisedButton(
          color: Colors.blue,
          onPressed: () => handleAppointmentStatus(widget.appointment, 1),
          child: AutoSizeText(
            "Complete",
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        )
      )
    );

    cancelButton = new Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: RaisedButton(
          color: Colors.red,
          onPressed: () => handleAppointmentStatus(widget.appointment, 2),
          child: AutoSizeText(
            "Cancel",
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        )
      )
    );

    noShowButton = new Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: RaisedButton(
          color: Colors.purple[300],
          onPressed: () => handleAppointmentStatus(widget.appointment, 4),
          child: AutoSizeText(
            "No Show",
            maxLines: 1,
            minFontSize: 9,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        )
      )
    );

    super.initState();
  }

  viewAppointment(Appointment appointment) {
    final appointmentDetailsController = new AppointmentDetailsController(appointment: appointment);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentDetailsController));
  }

  handleAppointmentStatus(Appointment appointment, int status) async {
    widget.controllerState.progressHUD();
    var results = await appointmentHandler(context, globals.user.token, appointment.id, status);
    setState(() {
      // appointment.status = results.status;
      widget.onUpdate(results);
    });
    widget.controllerState.progressHUD();
  }

  List<Widget> buildChildren() {
    List<Widget> _children = [];

    if(widget.appointment.status == 0) {
      if(DateTime.now().isAfter(DateTime.parse(widget.appointment.appointmentFullTime))) {
        _children.add(completeButton);
        _children.add(noShowButton);
        _children.add(cancelButton);
      }else {
        _children.add(cancelButton);
      }
    }

    _children.add(viewButton);
    return _children;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: buildChildren()
    );
  }
}