import 'package:flutter/material.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/helpers.dart';
import 'package:line_icons/line_icons.dart';

class AppointmentsController extends StatefulWidget {
  final List<Appointment> appointments;
  AppointmentsController({Key key, this.appointments}) : super (key: key);

  @override
  AppointmentsControllerState createState() => new AppointmentsControllerState();
}

class AppointmentsControllerState extends State<AppointmentsController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<Appointment> appointments = [];

  @override
  void initState() {
    appointments = widget.appointments;

    _progressHUD = new ProgressHUD(
      color: Colors.white,
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

  viewAppointment(Appointment appointment) {
    progressHUD();

    progressHUD();
  }

  _buildActionButtons(int status, Appointment appointment) {
    List<Widget> children = [];
    Widget viewButton = new Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: RaisedButton(
          color: Color(0xFFF7F7F7),
          onPressed: () => viewAppointment(appointment),
          child: Text(
            "View",
            style: TextStyle(
              color: Colors.black
            ),
          ),
        )
      )
    );
    Widget completeButton = new Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: RaisedButton(
          color: Colors.blue,
          onPressed: () => viewAppointment(appointment),
          child: Text(
            "Complete",
            style: TextStyle(
              color: Colors.white
            ),
          ),
        )
      )
    );
    Widget cancelButton = new Expanded(
      child: Container(
        margin: EdgeInsets.all(2),
        child: RaisedButton(
          color: Colors.red,
          onPressed: () => viewAppointment(appointment),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white
            ),
          ),
        )
      )
    );

    switch(status) {
      case 0: {
        if(DateTime.now().isAfter(DateTime.parse(appointment.appointmentFullTime))) {
          children.add(completeButton);
          children.add(cancelButton);
        }
        children.add(viewButton);
        return children;
      }
      case 1: {
        children.add(viewButton);
        return children;
      }
      case 2: {
        children.add(viewButton);
        return children;
      }
      case 3: {
        children.add(viewButton);
        return children;
      }
      default: {
        children.add(viewButton);
        return children;
      }
    }
  }

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.all(10),
      height: double.infinity,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: appointments.length,
              shrinkWrap: true,
              reverse: true,
              padding: EdgeInsets.all(0.0),
              itemBuilder: (context, index) {
                final df = new DateFormat('EEE, MMM d h:mm a');
                Color statusBar = getStatusBar(appointments[index].status, appointments[index].appointmentFullTime);
                return Container(
                  margin: EdgeInsets.only(bottom: 5.0),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: statusBar,
                        width: 3.0
                      )
                    )
                  ),
                  child: ExpansionTile(
                    leading: buildUserProfilePicture(context, appointments[index].clientProfilePicture, appointments[index].clientName),
                    title: Text(
                      appointments[index].clientID == 0 ? "${appointments[index].manualClientName}" : appointments[index].clientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          // child: RichText(
                          //   softWrap: true,
                          //   overflow: TextOverflow.ellipsis,
                          //   text: TextSpan(
                          //     style: TextStyle(
                          //       color: Colors.grey
                          //     ),
                          //     children: [
                          //       TextSpan(
                          //         text: df.format(DateTime.parse(appointments[index].appointmentFullTime.toString())),
                          //       ),
                          //       TextSpan(
                          //         text: "\n${appointments[index].packageName}\n",
                          //       ),
                          //       TextSpan(
                          //         text: appointments[index].cashPayment ? 'In Shop' : 'Mobile Pay',
                          //       ),
                          //     ]
                          //   ),
                          // )
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                df.format(DateTime.parse(appointments[index].appointmentFullTime.toString())),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700
                                ),
                              ),
                              Text(
                                "${appointments[index].packageName}",
                                style: TextStyle(
                                  color: Colors.grey
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(appointments[index].cashPayment ? LineIcons.money : Icons.credit_card, size: 18, color: Color(0xFFD4AF37)),
                                  Padding(padding: EdgeInsets.all(2)),
                                  Text(
                                    appointments[index].cashPayment ? 'In Shop' : 'Mobile Pay',
                                    style: TextStyle(
                                      color: Colors.grey
                                    ),
                                  )
                                ]
                              )
                            ],
                          ),
                        )
                      ]
                    ),
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildActionButtons(appointments[index].status, appointments[index])
                        )
                      )
                    ],
                  ),
                );
              },
            ),
          ]
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
        accentColor: globals.darkModeEnabled ? Colors.white : Colors.black,
        dividerColor: Colors.transparent,
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Appointments",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new Stack(
                children: [
                  _buildScreen(),
                  _progressHUD
                ]
              )
            )
          )
        )
      )
    );
  }
}