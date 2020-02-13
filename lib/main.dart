import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/functions.dart';
import 'Controller/LoginController.dart';
import 'Controller/HomeHubController.dart';
import 'Controller/BarberHubController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'package:intl/intl.dart';
import 'Model/BarberPolicies.dart';
import 'Model/Packages.dart';
import 'Model/availability.dart';
import 'Model/AppointmentRequests.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  globals.baseUrl = "https://trimmz.app/dev_api/";
  globals.stripeURL = "https://api.stripe.com/v1/";
  globals.stripeSecretKey = "sk_test_5h8VY4cc8ZUKHpIHO0TQWNkN00KJNxvrgY";
  globals.stripePublishablekey = "pk_test_X7T99aRCpPlsEHCjm7TOHnuO00JlKLGdal";
  globals.stripeMerchantId = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  BuildContext context;
  List selectedEvents = [];
  List<Packages> packages = [];
  Map<DateTime, List> events;
  List<Availability> availability = [];
  List<AppointmentRequest> appointmentReq = [];
  BarberPolicies policies = new BarberPolicies();

  var token = prefs.getInt('userToken');
  if(token != null){
    var res = await loginPostV2(token);
    setGlobals(res);

    if(globals.userType == 2) {
      packages = await getBarberPkgs(context, globals.token);
      final _selectedDay = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())));
      events = await getBarberAppointments(context, globals.token);
      selectedEvents = events[_selectedDay] ?? [];
      availability = await getBarberAvailability(context, globals.token);
      appointmentReq = await getBarberAppointmentRequests(context, globals.token);
      policies = await getBarberPolicies(context, globals.token) ?? new BarberPolicies();
    }
  }

  runApp(
    new MaterialApp(
      title: 'Trimmz',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => token == null ? new LoginScreen() : globals.userType == 2 ? BarberHubScreen(packages: packages, events: events, selectedEvents: selectedEvents, availability: availability, appointmentReq: appointmentReq, policies: policies) : HomeHubScreen(),
      },
      theme: new ThemeData(
        primaryColor: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black87
      )
    )
  );
}