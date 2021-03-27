import 'package:flutter/material.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:trimmz/Controller/AppointmentDetailsController.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/calls.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:trimmz/CustomDialogBox.dart';
import 'package:intl/intl.dart';

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

  Future<bool> confirmationPopup(Appointment appointment, int status) async {
    String title = "";
    String desc = "";
    Color buttonColor;

    if(status == 1) {
      title = "Complete Appointment";
      desc = "Are you sure you want to complete your appointment with ${appointment.clientName} for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime))} at ${DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime))}";
      buttonColor = Colors.blue;
    }else if(status == 2) {
      title = "Cancel Appointment";
      desc = "Are you sure you want to cancel your appointment with ${appointment.clientName} for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime))} at ${DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime))}";
      buttonColor = Colors.red;
    }else if(status == 4) {
      title = "Mark No-Show Appointment";
      desc = "Are you sure you want to mark your appointment with ${appointment.clientName} for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime))} at ${DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime))} as no-show";
      buttonColor = Colors.purple[300];
    }

    var response = await showCustomDialog(
      context: context, 
      title: title, 
      description: desc, 
      descAlignment: TextAlign.left,
      buttons: {
        "Confirm": {
          "action": () => Navigator.of(context).pop(true),
          "color": buttonColor,
          "textColor": Colors.white
        },
        "Cancel": {
          "action": () => Navigator.of(context).pop(false),
          "color": Colors.blueGrey,
          "textColor": Colors.white
        }
      }
    );
    return response;
  }

  handleAppointmentStatus(Appointment appointment, int status) async {
    bool result = await confirmationPopup(appointment, status);
    if(result == null || !result) {
      return;
    }
    widget.controllerState.progressHUD();
    var results = await appointmentHandler(context, globals.user.token, appointment.id, status);
    if(results != null){
      setState(() {
        widget.onUpdate(results);
      });
    }
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