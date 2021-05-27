import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/FloatingNavBar.dart';
import 'package:trimmz/Controller/FeedController.dart';
import 'package:trimmz/Controller/SearchController.dart';
import 'package:trimmz/Controller/SettingsController.dart';
import 'package:trimmz/Controller/ClientAppointmentsController.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/Model/Appointment.dart';

class ClientController extends StatefulWidget {
  final List<DashboardItem> dashboardItems;
  final Appointments appointments;
  ClientController({Key key, this.dashboardItems, this.appointments}) : super (key: key);

  @override
  ClientControllerState createState() => new ClientControllerState();
}

class ClientControllerState extends State<ClientController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  int _index = 0;
  List<Widget> i = [];
  Appointments appointments;

  @override
  void initState() {
    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    appointments = widget.appointments;

    i = [
      FeedController(
        dashboardItems: widget.dashboardItems,
        onAction: (value) => _performFeedControllerAction(value)),
      SearchController(),
      ClientAppointmentsController(appointments: appointments),
      SettingsController()
    ];

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

  _performFeedControllerAction(String action) {
    switch(action) {
      case "GoToSearchNavTab": {
        setState(() {
          _index = 1;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
      ),
      child: new Scaffold(
        extendBody: true,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: IndexedStack(
                  index: _index,
                  children: i,
                ),
              )
            )
          )
        ),
        // floatingActionButton: _index == 0 || _index == 2 ? new FloatingActionButton(
        //   onPressed: () {
        //     final selectUserController = new SelectUserBookAppointmentController(token: globals.user.token);
        //     Navigator.push(context, new MaterialPageRoute(builder: (context) => selectUserController));
        //   },
        //   child: new Icon(Icons.add),
        //   tooltip: "Book Appointment",
        //   backgroundColor: Colors.blue,
        //   foregroundColor: Colors.white,
        //   heroTag: null,
        // ) : null,
        bottomNavigationBar: FloatingNavbar(
          onTap: (int val) => setState(() => _index = val),
          currentIndex: _index,
          borderRadius: 50,
          selectedItemColor: globals.darkModeEnabled ? Colors.white : Colors.black,
          backgroundColor: globals.darkModeEnabled ? Colors.black.withAlpha(200) : Colors.grey.withAlpha(150),
          unselectedItemColor: globals.darkModeEnabled ? Colors.white : Colors.black,
          selectedBackgroundColor: Colors.blue,
          items: [
            FloatingNavbarItem(icon: Icons.home),
            FloatingNavbarItem(icon: Icons.search),
            FloatingNavbarItem(icon: Icons.calendar_today),
            FloatingNavbarItem(icon: Icons.settings_rounded),
          ],
        ),
      )
    );
  }
}