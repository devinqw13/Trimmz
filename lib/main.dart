import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/helpers.dart';
import 'package:trimmz/Controller/LoginController.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/Controller/ClientController.dart';
import 'package:trimmz/Controller/UserController.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/Model/Appointment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //================PRODUCTION APIS==============//
  globals.baseUrl = "https://api.trimmz.app/";
  globals.baseImageUrl = "https://trimmz.s3.us-east-2.amazonaws.com/";
  globals.stripeUrl = "https://api.stripe.com/v1/";
  globals.stripeSecretKey = "sk_live_W9HM81Ah3tqpz8GBKb9cA4my00eJMrVVLc";
  globals.stripePublishablekey = "pk_live_S9zlIINJ6Q5IjPOy4ew7rymX00cYd4jpaI";
  globals.stripeMerchantId = "";
  //============================================//
  SharedPreferences prefs = await SharedPreferences.getInstance();
  BuildContext context;
  List<DashboardItem> dashboardItems = [];
  Appointments appointments;

  globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? false : prefs.getBool('darkModeEnabled');
  if (globals.darkModeEnabled) {
    globals.userBrightness = Brightness.dark;
  }else {
    globals.userBrightness = Brightness.light;
  }

  var token = prefs.getInt('token');
  if(token != null){
    var res = await existingLogin(token);
    setGlobals(res);
    dashboardItems = await getDashboardItems(globals.user.token, context);
    appointments = await getAppointments(context, globals.user.token, globals.user.userType);
  }

  runApp(
    new MaterialApp(
      title: 'Trimmz',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => token == null ? new LoginController() : globals.user.userType == 2 ? UserController(dashboardItems: dashboardItems, appointments: appointments, screenHeight: MediaQuery.of(context).size.height) : ClientController(dashboardItems: dashboardItems, appointments: appointments),
      },
      theme: new ThemeData(
        primaryColor: Colors.blue,
        // accentColor: Colors.white,
        // unselectedWidgetColor: Colors.white,
        // brightness: Brightness.light,
        // primaryColorBrightness: Brightness.light,
        // accentColorBrightness: Brightness.light
      )
    )
  );
}