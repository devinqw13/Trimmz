import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/helpers.dart';
import 'package:intl/intl.dart';

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

  acceptAppointment(int appointmentId) async {
    progressHUD();

    progressHUD();
  }

  declineAppointment(int appointmentId) async {
    progressHUD();

    progressHUD();
  }

  viewAppointment(Appointment appointment) async {
    progressHUD();

    progressHUD();
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
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey
                              ),
                              children: [
                                TextSpan(
                                  text: df.format(DateTime.parse(requests[index].appointmentFullTime.toString())),
                                ),
                                TextSpan(
                                  text: "\n${requests[index].packageName}\n",
                                ),
                                TextSpan(
                                  text: requests[index].cashPayment ? 'In Shop' : 'Mobile Pay',
                                ),
                              ]
                            ),
                          )
                        ]
                      ),
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: RaisedButton(
                                  color: Colors.blue,
                                  onPressed: () => acceptAppointment(requests[index].id),
                                  child: Text("Accept"),
                                )
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Expanded(
                                child: RaisedButton(
                                  color: Colors.red,
                                  onPressed: () => declineAppointment(requests[index].id),
                                  child: Text("Decline"),
                                )
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Expanded(
                                child: RaisedButton(
                                  color: Color(0xFFF7F7F7),
                                  onPressed: () => viewAppointment(requests[index]),
                                  child: Text(
                                    "View",
                                    style: TextStyle(
                                      color: Colors.black
                                    ),
                                  ),
                                )
                              )
                            ]
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