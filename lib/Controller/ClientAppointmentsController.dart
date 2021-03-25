import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/helpers.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:trimmz/Controller/AppointmentDetailsController.dart';
import 'package:trimmz/calls.dart';

class ClientAppointmentsController extends StatefulWidget {
  final Appointments appointments;
  ClientAppointmentsController({Key key, this.appointments}) : super (key: key);

  @override
  ClientAppointmentsControllerState createState() => ClientAppointmentsControllerState();
}

class ClientAppointmentsControllerState extends State<ClientAppointmentsController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  int currentTab = 0;
  List<Appointment> upcoming = [];
  List<Appointment> past = [];

  @override
  void initState() {
    globals.clientAppointmentsControllerState = this;

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    for(var item in widget.appointments.list) {
      if(DateTime.now().isAfter(DateTime.parse(item.appointmentFullTime))) {
        past.add(item);
      }else {
        upcoming.add(item);
      }
    }

    past.sort((a,b) => DateTime.parse(b.appointmentFullTime).compareTo(DateTime.parse(a.appointmentFullTime)));

    upcoming.sort((a,b) => DateTime.parse(b.appointmentFullTime).compareTo(DateTime.parse(a.appointmentFullTime)));
    
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

  refreshList() async {
    List<Appointment> newPast = [];
    List<Appointment> newUpcoming = [];
    var results = await getAppointments(context, globals.user.token, globals.user.userType);

    for(var item in results.list) {
      if(DateTime.now().isAfter(DateTime.parse(item.appointmentFullTime))) {
        newPast.add(item);
      }else {
        newUpcoming.add(item);
      }
    }

    setState(() {
      past = newPast;
      upcoming = newUpcoming;
    });

    past.sort((a,b) => DateTime.parse(b.appointmentFullTime).compareTo(DateTime.parse(a.appointmentFullTime)));

    upcoming.sort((a,b) => DateTime.parse(b.appointmentFullTime).compareTo(DateTime.parse(a.appointmentFullTime)));
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

  viewAppointment(Appointment appointment) {
    final appointmentDetailsController = new AppointmentDetailsController(appointment: appointment);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentDetailsController));
  }

  handleAppointmentStatus(int appointmentId, int status) async {
    progressHUD();
    var results = await appointmentHandler(context, globals.user.token, appointmentId, status);
    if(results != null) {
      Appointment appointment = upcoming.where((element) => element.id == results.id).first;

      setState(() {
        appointment.status = results.status;
      });
    }
    progressHUD();
  }

  _buildActionButtons(int status, Appointment appointment) {
    List<Widget> children = [];
    Widget viewButton = new Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5, top: 5),
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

    Widget cancelButton = new Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5, top: 5),
        child:  RaisedButton(
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

    if(DateTime.now().isBefore(DateTime.parse(appointment.appointmentFullTime)) && (appointment.status == 0 || appointment.status == 3)) {
      children.add(cancelButton);
    }

    children.add(viewButton);

    return children;
  }

  buildUpcomingTab() {
    if(upcoming.length > 0) {
      return ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: upcoming.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final df = new DateFormat('EEE, MMM d h:mm a');
          Color statusBar = getStatusBar(upcoming[index].status, upcoming[index].appointmentFullTime);
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
              leading: buildUserProfilePicture(context, upcoming[index].userProfilePicture, upcoming[index].userName),
              title: Text(
                upcoming[index].userName,
                style: TextStyle(
                  fontWeight: FontWeight.w600
                ),
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          df.format(DateTime.parse(upcoming[index].appointmentFullTime.toString())),
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        buildServicesColumn(upcoming[index].services),
                        Row(
                          children: [
                            Icon(upcoming[index].cashPayment ? LineIcons.money : Icons.credit_card, size: 18, color: Color(0xFFD4AF37)),
                            Padding(padding: EdgeInsets.all(2)),
                            Text(
                              upcoming[index].cashPayment ? 'In Shop' : 'Mobile Pay',
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
                  padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildActionButtons(upcoming[index].status, upcoming[index])
                  )
                )
              ],
            ),
          );
        },
      );
    }else {
      return Center(
        child: Text("No Upcoming Appointments")
      );
    }
  }

  buildPastTab() {
    if(past.length > 0) {
      return ListView.builder(
        padding: EdgeInsets.only(top: 10.0),
        itemCount: past.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final df = new DateFormat('EEE, MMM d h:mm a');
          Color statusBar = getStatusBar(past[index].status, past[index].appointmentFullTime);
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
              leading: buildUserProfilePicture(context, past[index].userProfilePicture, past[index].userName),
              title: Text(
                past[index].userName,
                style: TextStyle(
                  fontWeight: FontWeight.w600
                ),
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          df.format(DateTime.parse(past[index].appointmentFullTime.toString())),
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        buildServicesColumn(past[index].services),
                        Row(
                          children: [
                            Icon(past[index].cashPayment ? LineIcons.money : Icons.credit_card, size: 18, color: Color(0xFFD4AF37)),
                            Padding(padding: EdgeInsets.all(2)),
                            Text(
                              past[index].cashPayment ? 'In Shop' : 'Mobile Pay',
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
                  padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildActionButtons(past[index].status, past[index])
                  )
                )
              ],
            ),
          );
        },
      );
    }else {
      return Center(
        child: Text("No Past Appointments")
      );
    }
  }

  _buildScreen() {
    return TabBarView(
      children: <Widget>[
        buildUpcomingTab(),
        buildPastTab()
      ],
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      onTap: (index) {
        setState(() {
          currentTab = index;
        });
      },
      indicatorColor: Colors.white,
      tabs: <Widget>[
        Tab(text: "UPCOMING"),
        Tab(text: "PAST")
      ],
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
      child: DefaultTabController(
        length: 2, 
        child: Scaffold(
          appBar: new AppBar(
            brightness: globals.userBrightness,
            backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: new Text(
              "Appointments",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18.0
              ),
            ),
            bottom: _buildTabBar(),
            elevation: 0.0,
          ),
          body: Container(
            color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
            child: new WillPopScope(
              onWillPop: () async {
                return false;
              },
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