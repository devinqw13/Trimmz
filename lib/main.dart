import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/Globals.dart' as globals;
import 'package:trimmz/Screens/LoginScreen/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();


  //TODO: SET GLOBALS


  var token = prefs.getInt('token');
  if(token != null){
    
  }

  runApp(
    new MaterialApp(
      title: 'Trimmz',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => new LoginScreen()
      },
      theme: new ThemeData(
        primaryColor: Colors.blue,
      )
    )
  );
}