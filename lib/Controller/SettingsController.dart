import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/CustomCupertinoSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginController.dart';

class SettingsController extends StatefulWidget {
  SettingsController({Key key}) : super (key: key);

  @override
  SettingsControllerState createState() => new SettingsControllerState();
}

class SettingsControllerState extends State<SettingsController> with TickerProviderStateMixin {
  CupertinoSettings settings;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  @override
  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      color: globals.darkModeEnabled ? lightBackgroundGrey : darkGrey,
      containerColor: globals.darkModeEnabled ? darkGrey : lightBackgroundGrey,
      borderRadius: 8.0,
      text: "Loading...",
      loading: false,
    );
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
    settings = new CupertinoSettings(<Widget>[
      new CSHeader(globals.user.username),
      new CSLink(
        'Name',
        () {},
        subText: globals.user.name,
        style: CSWidgetStyle(
          icon: Icon(Icons.person_outline_rounded, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Phone',
        () {},
        subText: globals.user.phone == null ? "Add" : globals.user.phone,
        style: CSWidgetStyle(
          icon: Icon(Icons.phone_iphone, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Username',
        () {},
        subText: globals.user.username,
        style: CSWidgetStyle(
          icon: Icon(Icons.person, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Email',
        () {},
        subText: globals.user.userEmail,
        style: CSWidgetStyle(
          icon: Icon(Icons.email, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Password',
        () {},
        style: CSWidgetStyle(
          icon: Icon(Icons.lock, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSHeader("General"),
      new CSLink(
        'Advanced Options',
        () {},
        style: CSWidgetStyle(
          icon: Icon(Icons.settings_applications_sharp, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Mobile Pay',
        () {},
        style: CSWidgetStyle(
          icon: Icon(Icons.payments_outlined, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Payment Method',
        () {},
        style: CSWidgetStyle(
          icon: Icon(Icons.payment, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'About Trimmz',
        () {},
        style: CSWidgetStyle(
          icon: Icon(Icons.info, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      Padding(padding: EdgeInsets.all(10)),
      new CSButton(
        CSButtonType.DESTRUCTIVE,
        "Log out",
        () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();

          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new LoginController()));
        }
      )
    ]);

    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        backgroundColor: globals.darkModeEnabled ? richBlack : Color(0xFFFAFAFA),
        appBar: new AppBar(
          brightness: globals.userBrightness,
          centerTitle: true,
          title: new Text(
            "Settings",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new Stack(
                children: [
                  settings,
                  _progressHUD,
                ]
              )
            )
          )
        )
      )
    );
  }
}