import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import '../CustomCupertinoSettings.dart';

class AppearanceSettings extends StatefulWidget {
  final CupertinoSettings settings;
  AppearanceSettings({Key key, this.settings}) : super (key: key);

  @override
  AppearanceSettingsState createState() => new AppearanceSettingsState();
}

class AppearanceSettingsState extends State<AppearanceSettings> {
  CupertinoSettings settings;

  void initState() {
    super.initState();
  }

  _darkModeChanged(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkModeEnabled', value);
    setState(() {
      if (value == true) {
        globals.userBrightness = Brightness.dark;
        globals.darkModeEnabled = true;
        globals.userColor = Colors.black;
        widget.settings.setDarkMode();
      }
      else {
        globals.userBrightness = Brightness.light;
        globals.darkModeEnabled = false;
        globals.userColor = Colors.white;
        widget.settings.setLightMode();
      }
    });
  }

  buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    contentPadding: EdgeInsets.all(10),
                    activeColor: Colors.blue,
                    title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    subtitle: Text('Enable to set app to dark mode', style: TextStyle(fontStyle: FontStyle.italic)),
                    value: globals.darkModeEnabled,
                    onChanged: (value) {
                      _darkModeChanged(value);
                    },
                  ),
                ]
              )
            )
          )
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          title: new Text('Appearance')
        ),
        body: new Stack(
          children: <Widget> [
            buildBody(),
          ]
        )
      )
    );
  }
}