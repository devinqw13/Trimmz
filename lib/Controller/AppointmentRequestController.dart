import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/helpers.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/Controller/AppointmentDetailsController.dart';

class AppointmentRequestController extends StatefulWidget {
  final List<Appointment> requests;
  AppointmentRequestController({Key key, this.requests}) : super (key: key);

  @override
  AppointmentRequestControllerState createState() => new AppointmentRequestControllerState();
}

class AppointmentRequestControllerState extends State<AppointmentRequestController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<Appointment> requests = [];

  @override
  void initState() {
    requests = widget.requests;

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

  handleAppointmentStatus(int appointmentId, int status) async {
    progressHUD();
    var results = await appointmentHandler(context, globals.user.token, appointmentId, status);

    if(results != null) {
      Appointment appointment = requests.where((element) => element.id == results.id).first;

      setState(() {
        requests.removeWhere((element) => element.id == appointment.id);
      });
      globals.userControllerState.refreshList();
    }
    progressHUD();
  }

  viewAppointment(Appointment appointment) {
    final appointmentDetailsController = new AppointmentDetailsController(appointment: appointment);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentDetailsController));
  }

  List<Widget> buildExpandedButtons(Appointment request) {
    List<Widget> _children = [];

    Widget acceptButton = new Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child:  RaisedButton(
                                            color: Colors.blue,
                                            onPressed: () => handleAppointmentStatus(request.id, 0),
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
                                        onPressed: () => handleAppointmentStatus(request.id, 99),
                                        child: Text(
                                          "Decline",
                                          style: TextStyle(
                                            color: Colors.white
                                          )
                                        ),
                                      )
                                    )
                                  );
    Widget viewButton = new Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        child:  RaisedButton(
                                          color: Color(0xFFF7F7F7),
                                          onPressed: () => viewAppointment(request),
                                          child: Text(
                                            "View",
                                            style: TextStyle(
                                              color: Colors.black
                                            ),
                                          ),
                                        )
                                        )
                                      );
    Widget dismissButton = new Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      child: RaisedButton(
                                        color: Colors.blue,
                                        onPressed: () => handleAppointmentStatus(request.id, 98),
                                        child: Text(
                                          "Dismiss",
                                          style: TextStyle(
                                            color: Colors.white
                                          )
                                        ),
                                      )
                                    )
                                  );

    if(DateTime.now().isAfter(DateTime.parse(request.appointmentFullTime))) {
      _children.add(dismissButton);
      _children.add(viewButton);
    }else {
      _children.add(acceptButton);
      _children.add(declineButton);
      _children.add(viewButton);
    }
    return _children;                     
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
                  color: globals.darkModeEnabled ? Colors.white : Colors.black,
                  fontSize: 13.0
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

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.all(10),
      height: double.infinity,
      child: requests.length > 0 ? SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final df = new DateFormat('EEE, MMM d h:mm a');

                return Container(
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: ExpansionTile(
                    leading: buildUserProfilePicture(context, requests[index].clientProfilePicture, requests[index].clientName),
                    title: Text(
                      requests[index].clientName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              df.format(DateTime.parse(requests[index].appointmentFullTime.toString())),
                              style: TextStyle(
                                fontWeight: FontWeight.w600
                              )
                            ),
                            buildServicesColumn(requests[index].services),
                            Text(
                              requests[index].cashPayment ? 'In Shop' : 'Mobile Pay',
                            ),
                          ],
                        )
                      ]
                    ),
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buildExpandedButtons(requests[index])
                        )
                      )
                    ],
                  ),
                );
              },
            ),
          ]
        )
      ): Center(
        child: Text(
          "No Appointment Requests",
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
        dividerColor: Colors.transparent
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Appointment Requests",
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