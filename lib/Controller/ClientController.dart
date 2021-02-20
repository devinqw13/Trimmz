import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:trimmz/palette.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:trimmz/FloatingNavBar.dart';
import 'package:trimmz/Controller/FeedController.dart';
import 'package:trimmz/Controller/SearchController.dart';
import 'package:trimmz/Controller/SettingsController.dart';
import 'package:trimmz/Controller/ClientAppointmentsController.dart';
import 'package:trimmz/Controller/SelectUserBookAppointment.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:trimmz/calls.dart';

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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int _index = 0;
  List<Widget> i = [];

  @override
  void initState() {
    firebaseCloudMessagingListeners();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    i = [
      FeedController(dashboardItems: widget.dashboardItems),
      SearchController(),
      ClientAppointmentsController(appointments: widget.appointments),
      SettingsController()
    ];

    super.initState();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token) async {
      print("CLOUD MESSAGING TOKEN: " + token);
      await setFirebaseToken(context, token, globals.user.token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        
      },
      onResume: (Map<String, dynamic> message) async {
        
      },
      onLaunch: (Map<String, dynamic> message) async {
        
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings){

    });
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
        floatingActionButton: _index == 0 ? new FloatingActionButton(
          onPressed: () {
            final selectUserController = new SelectUserBookAppointmentController(token: globals.user.token);
            Navigator.push(context, new MaterialPageRoute(builder: (context) => selectUserController));
          },
          child: new Icon(Icons.add),
          tooltip: "Book Appointment",
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          heroTag: null,
        ) : null,
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