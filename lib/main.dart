import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Controller/LoginController.dart';
import 'Controller/HomeHubController.dart';
import 'Controller/BarberHubController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  globals.baseUrl = "http://trimmz.theemove.com/api/";
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var token = prefs.getInt('userToken');
  globals.LoginUser user;
  if(token != null){
    user = new globals.LoginUser();
    user.token = prefs.getInt('userToken');
    user.username = prefs.getString('userUsername');
    user.name = prefs.getString('userName');
    user.userEmail = prefs.getString('userUserEmail');
    user.userAdmin = prefs.getBool('userIsAdmin');
    user.userType = prefs.getInt('userType');
    globals.user = user;
    globals.token = user.token;
    globals.username = user.username;
    globals.name = user.name;
    globals.email = user.userEmail;
    globals.userAdmin = user.userAdmin == true ? true : false;
    globals.userType = user.userType;
    globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? true : prefs.getBool('darkModeEnabled');
    if (globals.darkModeEnabled) {
      globals.userBrightness = Brightness.dark;
      globals.userColor = Color.fromARGB(255, 0, 0, 0);
    }
    else {
      globals.userBrightness = Brightness.light;
      globals.userColor = lightBackgroundWhite;
    }
  }

  runApp(
    new MaterialApp(
      title: 'Trimmz',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => token == null ? new LoginScreen() : globals.userType == 2 ? BarberHubScreen() : HomeHubScreen(),
      },
      theme: new ThemeData(
        primaryColor: Colors.blue,
        //accentColor: Colors.white,
        //unselectedWidgetColor: Colors.white,
        brightness: Brightness.dark,
        //primaryColorBrightness: Brightness.dark,
        //accentColorBrightness: Brightness.light
      )
    )
  );
}