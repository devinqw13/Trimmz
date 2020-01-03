import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

setGlobals(Map results) async {
  globals.LoginUser user = new globals.LoginUser();
  user.token = results['user']['id'];
  user.username = results['user']['username'];
  user.name = results['user']['name'];
  user.userEmail = results['user']['email'];
  user.userAdmin = results['user']['type'] == 3 ? true : false;
  user.userType = results['user']['type'];

  globals.user = user;
  globals.token = user.token;
  globals.username = user.username;
  globals.name = user.name;
  globals.userAdmin = user.userAdmin;
  globals.userType = user.userType;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? true : prefs.getBool('darkModeEnabled');
  if (globals.darkModeEnabled) {
    globals.userBrightness = Brightness.dark;
    globals.userColor = Color.fromARGB(255, 20, 20, 20); //31
  }
  else {
    globals.userBrightness = Brightness.light;
    globals.userColor = Color.fromARGB(255, 255, 255, 255);
  }

  prefs.setInt('userToken', globals.user.token);
  prefs.setString('userUsername', globals.user.username);
  prefs.setString('userName', globals.user.name);
  prefs.setString('userUserEmail', globals.user.userEmail);
  prefs.setBool('userIsAdmin', globals.user.userAdmin);
  prefs.setInt('userType', globals.user.userType);
}