import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/Model/Appointment.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/palette.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:trimmz/PulsingWidget.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/CustomDialogBox.dart';

class AppointmentDetailsController extends StatefulWidget {
  final Appointment appointment;
  AppointmentDetailsController({Key key, this.appointment}) : super (key: key);

  @override
  AppointmentDetailsControllerState createState() => new AppointmentDetailsControllerState();
}

class AppointmentDetailsControllerState extends State<AppointmentDetailsController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  Appointment appointment;

  @override
  void initState() {
    appointment = widget.appointment;

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

  buildServicesColumn(List<Service> services) {
    Map servicesMap = {};
    List<Widget> _children = [];

    for(var service in services) {
      if(!servicesMap.containsKey(service.id)) {
        servicesMap[service.id] = [Map.from(service.toMap())];
      }else {
        servicesMap[service.id].add(Map.from(service.toMap()));
      }
    }

    servicesMap.forEach((appointmentId, s) {
      _children.add(
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: s[0]['name'],
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.0,
                )
              ),
              s.length > 1 ? TextSpan(
                text: " (${s.length})",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0
                )
              ): TextSpan()
            ]
          ),
        )
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children
    );
  }

  buildServicesColumn2(List<Service> services) {
    Map servicesMap = {};
    List<Widget> _children = [];

    for(var service in services) {
      if(!servicesMap.containsKey(service.id)) {
        servicesMap[service.id] = [Map.from(service.toMap())];
      }else {
        servicesMap[service.id].add(Map.from(service.toMap()));
      }
    }

    servicesMap.forEach((appointmentId, s) {
      _children.add(
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: s[0]['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w600
                )
              ),
              s.length > 1 ? TextSpan(
                text: " (${s.length})",
                style: TextStyle(
                  fontWeight: FontWeight.w600
                )
              ): TextSpan()
            ]
          ),
        )
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children
    );
  }

  Widget _buildStatusLabel(int status, String time) {
    Widget returnWidget;
    switch(status) {
      case 0: {
        Widget widget;
        if(DateTime.now().isAfter(DateTime.parse(time))) {
          widget = PulsingWidget(
            child: Container(
              padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
              child: Text(
                "AWAITING ACTION",
                style: TextStyle(
                  fontSize: 12.0
                )
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(15.0)
              ),
            )
          );
        }else {
          widget = Container(
            padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
            child: Text(
              "UPCOMING",
              style: TextStyle(
                fontSize: 12.0
              )
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15.0)
            ),
          );
        }
        returnWidget = widget;
        break;
      }
      case 1: {
        returnWidget = Container(
          padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
          child: Text(
            "COMPLETED",
            style: TextStyle(
              fontSize: 12.0
            )
          ),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(15.0)
          ),
        );
        break;
      }
      case 2: {
        returnWidget = Container(
          padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
          child: Text(
            "CANCELLED",
            style: TextStyle(
              fontSize: 12.0
            )
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(15.0)
          ),
        );
        break;
      }
      case 3: {
        returnWidget = PulsingWidget(
          child: Container(
            padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
            child: Text(
              "PENDING",
              style: TextStyle(
                fontSize: 12.0
              )
            ),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(15.0)
            ),
          )
        );
        break;
      }
      case 4: {
        returnWidget =  Container(
          padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
          child: Text(
            "NO SHOW",
            style: TextStyle(
              fontSize: 12.0
            )
          ),
          decoration: BoxDecoration(
            color: Colors.purple[300],
            borderRadius: BorderRadius.circular(15.0)
          ),
        );
        break;
      }
      default: {
        returnWidget = Container();
      }
    }
    return returnWidget;
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BOOKED WITH",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              appointment.clientID == globals.user.token ?
              buildUserProfilePicture(context, appointment.userProfilePicture, appointment.userName):
              buildUserProfilePicture(context, appointment.clientProfilePicture, appointment.clientID == 0 ? appointment.manualClientName : appointment.clientName),
              Expanded(
                flex: 9,
                child: Container(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.clientID == globals.user.token ?
                        "${appointment.userName}" :
                        appointment.clientID == 0 ?
                        "${appointment.manualClientName}${appointment.manualClientPhone != null ? appointment.manualClientPhone : ''}":
                        "${appointment.clientName}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600
                        )
                      ),
                      buildServicesColumn(appointment.services),
                      Padding(padding: EdgeInsets.all(2)),
                      _buildStatusLabel(appointment.status, appointment.appointmentFullTime)
                    ]
                  ),
                )
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      DateFormat('MMM').format(DateTime.parse(appointment.appointmentFullTime)).toUpperCase(),
                      style: TextStyle(
                        fontSize: 13.0
                      ),
                    ),
                    Text(
                      DateFormat('d').format(DateTime.parse(appointment.appointmentFullTime)),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime)),
                      style: TextStyle(
                        fontSize: 13.0
                      )
                    ),
                  ],
                ),
              ),
            ]
          ),
        )
      ]
    );
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
      desc = "Are you sure you want to cancel your appointment with ${globals.user.userType == 2 ? appointment.clientName : appointment.userName} for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime))} at ${DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime))}";
      buttonColor = Colors.red;
    }else if(status == 4) {
      title = "Mark No-Show Appointment";
      desc = "Are you sure you want to mark your appointment with ${appointment.clientName} for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime))} at ${DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime))} as no-show";
      buttonColor = Colors.purple[300];
    }else if(status == 0) {
      title = "Accept Appointment Request";
      desc = "Are you sure you want to accept your appointment with ${appointment.clientName} for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime))} at ${DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime))}";
      buttonColor = Colors.blue;
    }else if(status == 99) {
      title = "Decline Appointment Request";
      desc = "Are you sure you want to decline your appointment with ${appointment.clientName} for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime))} at ${DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime))}";
      buttonColor = Colors.red;
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

  handleAppointmentStatus(int appointmentId, int status) async {
    if(status != 98) {
      bool result = await confirmationPopup(appointment, status);
      if(result == null || !result) {
        return;
      }
    }
    progressHUD();
    var results = await appointmentHandler(context, globals.user.token, appointmentId, status);

    if(results != null) {
      setState(() {
        appointment.status = results.status;
      });
      if(globals.user.userType == 2) {
        globals.userControllerState.refreshList();
      }else {
        globals.clientAppointmentsControllerState.refreshList();
      }
    }
    progressHUD();
  }

  buildActionButtons(int status) {
    List<Widget> _children = [];
    Widget acceptButton = new Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child:  RaisedButton(
                                            color: Colors.blue,
                                            onPressed: () => handleAppointmentStatus(appointment.id, 0),
                                            child: Text(
                                              "Accept",
                                              style: TextStyle(
                                                color: Colors.white
                                              )
                                            ),
                                          )
                                        )
                                      );
    Widget declineButton = new Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: RaisedButton(
                                        color: Colors.red,
                                        onPressed: () => handleAppointmentStatus(appointment.id, 99),
                                        child: Text(
                                          "Decline",
                                          style: TextStyle(
                                            color: Colors.white
                                          )
                                        ),
                                      )
                                    )
                                  );                                  
    Widget dismissButton = new Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: RaisedButton(
                                        color: Colors.blue,
                                        onPressed: () => handleAppointmentStatus(appointment.id, 98),
                                        child: Text(
                                          "Dismiss",
                                          style: TextStyle(
                                            color: Colors.white
                                          )
                                        ),
                                      )
                                    )
                                  );
    Widget completeButton = new Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: RaisedButton(
                                        color: Colors.blue,
                                        onPressed: () => handleAppointmentStatus(appointment.id, 1),
                                        child: Text(
                                          "Complete",
                                          style: TextStyle(
                                            color: Colors.white
                                          )
                                        ),
                                      )
                                    )
                                  );
    Widget cancelButton = new Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: RaisedButton(
                                        color: Colors.red,
                                        onPressed: () => handleAppointmentStatus(appointment.id, 2),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.white
                                          )
                                        ),
                                      )
                                    )
                                  );
    Widget noShowButton = new Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: RaisedButton(
                                        color: Colors.purple[300],
                                        onPressed: () => handleAppointmentStatus(appointment.id, 4),
                                        child: Text(
                                          "No Show",
                                          style: TextStyle(
                                            color: Colors.white
                                          )
                                        ),
                                      )
                                    )
                                  );
    if(appointment.clientID == globals.user.token) {
      switch(status) {
        case 0: {
          if(!DateTime.now().isAfter(DateTime.parse(appointment.appointmentFullTime))) {
            _children.add(cancelButton);
          }
          break;
        }
        case 3: {
          if(!DateTime.now().isAfter(DateTime.parse(appointment.appointmentFullTime))) {
            _children.add(cancelButton);
          }
          break;
        }
        default: {
          break;
        }
      }
    }else {
      switch(status) {
        case 0: {
          if(DateTime.now().isAfter(DateTime.parse(appointment.appointmentFullTime))) {
            _children.add(completeButton);
            _children.add(noShowButton);
            _children.add(cancelButton);
          }else {
            _children.add(cancelButton);
          }
          break;
        }
        case 3: {
          if(DateTime.now().isAfter(DateTime.parse(appointment.appointmentFullTime))) {
            _children.add(dismissButton);
          }else {
            _children.add(acceptButton);
            _children.add(declineButton);
          }
          break;
        }
        default: {
          break;
        }
      }
    }

    return _children;
  }

  _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buildActionButtons(appointment.status)
            )
          )
        )
      ]
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SUMMARY",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(Icons.access_time_rounded),
                  ),
                  // Padding(padding: EdgeInsets.all(8.0)),
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(appointment.appointmentFullTime)),
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime)) +  " - " + DateFormat('h:mm a').format(DateTime.parse(appointment.appointmentFullTime).add(Duration(minutes: appointment.duration))),
                          style: TextStyle(
                            color: Colors.grey
                          )
                        )
                      ],
                    ),
                  )
                ],
              ),
              Divider(),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(LineIcons.hand_stop_o),
                  ),
                  // Padding(padding: EdgeInsets.all(8.0)),
                  Expanded(
                    flex: 9,
                    child: buildServicesColumn2(appointment.services)
                  )
                ]
              )
            ],
          )
        )
      ]
    );
  }

  String formatCurrency(num amount) {
    String finalString;
    if(amount == amount.truncate()) {
      amount = amount.toInt();
      finalString = amount.toInt().toString();
    }else {
      amount = amount;
      final oCcy = new NumberFormat("#,##0.00", "en_US");
      finalString = oCcy.format(double.parse(amount.toStringAsFixed(2)));
    }
    return "\$$finalString";
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PAYMENT METHOD",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appointment.cashPayment ?
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(LineIcons.money),
                  ),
                  Expanded(
                    flex: 9,
                    child: Text("In Shop")
                  )
                ],
              ):
              PMCard(appointment.stripePaymentID),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container()
                  ),
                  Expanded(
                    flex: 9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount",
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                        Text(
                          formatCurrency(appointment.subTotal),
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        )
                      ]
                    ),
                  )
                ]
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container()
                  ),
                  Expanded(
                    flex: 9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tip",
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                        Text(
                          formatCurrency(appointment.tip),
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        )
                      ]
                    ),
                  )
                ]
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container()
                  ),
                  Expanded(
                    flex: 9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Processing Fee",
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                        Text(
                          formatCurrency(appointment.processingFee),
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        )
                      ]
                    ),
                  )
                ]
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container()
                  ),
                  Expanded(
                    flex: 9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0
                          ),
                        ),
                        Text(
                          formatCurrency((appointment.processingFee + appointment.subTotal + appointment.tip)),
                          style: TextStyle(
                            color: Colors.grey
                          ),
                        )
                      ]
                    ),
                  )
                ]
              )
            ]
          )
        )
      ]
    );
  }

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.all(10),
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildOverview(),
            Padding(padding: EdgeInsets.all(8)),
            _buildActions(),
            Padding(padding: EdgeInsets.all(8)),
            _buildSummary(),
            Padding(padding: EdgeInsets.all(8)),
            _buildPaymentMethod()
          ]
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Appointment",
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
                  _progressHUD,
                ]
              )
            )
          )
        )
      )
    );
  }
}

class PMCard extends StatelessWidget {
  final String paymentId;
  PMCard(this.paymentId);

  Widget _buildLast4() {
    List<Widget> _cardDots = List<Widget>.generate(12, (index) => 
      Container(
        margin: EdgeInsets.all(1.5),
        width: 3.5,
        height: 3.5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: globals.darkModeEnabled ? Colors.white : Colors.black
        ),
      )
    );

    return Container(
      child: Row(children: _cardDots)
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getAppointmentPaymentMethod(context, paymentId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: snapshot.data.brandIcon,
              ),
              Expanded(
                flex: 9,
                child: Row(
                  children: [
                    _buildLast4(),
                    Padding(padding: EdgeInsets.all(2)),
                    Text(
                      snapshot.data.last4
                    )
                  ]
                ),
              )
            ],
          );
        } else {
          return CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation(Colors.blue)
          );
        }
      }
    );
  }
}