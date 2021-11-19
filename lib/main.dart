import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trimmz/Globals.dart' as globals;
import 'package:trimmz/Screens/DashboardScreen/DashboardScreen.dart';
import 'package:trimmz/Screens/LoginScreen/LoginScreen.dart';
import 'package:trimmz/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:trimmz/Model/User.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String jsonString = prefs.getString('user');
  print(jsonString);
  if(jsonString != null){
    Map<String, dynamic> userMap = json.decode(jsonString);
    User().userKey = userMap['id'] == null ? 0 : userMap['id'];
    User().name = userMap['name'] == null ? "" : userMap['name'];
    User().username = userMap['username'] == null ? "" : userMap['username'];
    User().email = userMap['email'] == null ? "" : userMap['email'];
    User().photoUrl = userMap['profile_picture'] == null ? "" : userMap['profile_picture'];
  }

  runZonedGuarded(() {
    runApp(
      App()
    );
  }, (Object error, StackTrace stackTrace) async {

  });
}

class App extends StatefulWidget {
  
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Future<bool> future;

  @override
  void initState() {
    super.initState();

    _initializeAsyncDependencies();
  }

  _initializeAsyncDependencies() async {
    globals.auth = auth.FirebaseAuth.instance;
    await getKeys();

    setState(() {
      future = Future.value(true);
    });
  }

  Future<void> getKeys() async {
    RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: Duration(hours: 12));
    await remoteConfig.activateFetched();

    globals.baseUrl = remoteConfig.getString('api_base_url');
    globals.baseImageUrl = remoteConfig.getString('api_base_image_url');
    
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          return new MaterialApp(
            title: 'Trimmz',
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings) {
              if(User().userKey == null) {
                return MaterialWithModalsPageRoute(
                  builder: (_) => LoginScreen(),
                  settings: settings
                );
              }else {
                return MaterialWithModalsPageRoute(
                  builder: (_) => DashboardScreen(),
                  settings: settings
                );
              }
            },
            theme: theme()
          );
        }else {
          return Container();
        }
      }
    );
  }
}