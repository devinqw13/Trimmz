import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/CustomCupertinoSettings.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginController.dart';
import 'package:trimmz/Controller/EditingAccountController.dart';
import 'dart:ui' as ui;
import 'package:trimmz/ProfilePictureWithUpdate.dart';
import 'package:trimmz/Controller/PaymentMethodController.dart';

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

  goToEditAccount(String screen) {
    final editingAccountController = new EditingAccountController(screen: screen);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => editingAccountController));
  }

  _handleDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkModeEnabled', !globals.darkModeEnabled);
    setState(() {
      if (globals.darkModeEnabled == true) {
        globals.userBrightness = Brightness.light;
        globals.darkModeEnabled = false;
      }
      else {
        globals.userBrightness = Brightness.dark;
        globals.darkModeEnabled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    settings = new CupertinoSettings(<Widget>[
      new Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: globals.user.headerPicture != null ?
              NetworkImage(
                "${globals.baseImageUrl}${globals.user.headerPicture}",
              ): AssetImage("images/trimmz_icon_t.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: globals.darkModeEnabled ? Colors.black.withAlpha(100) : Colors.white.withAlpha(100),
              child: Align(
                child: Stack(
                  children: [
                    ProfilePicture()
                  ]
                ),
              )
            )
          )
        ),
        height: 100
      ),
      new CSHeader(globals.user.username),
      new CSLink(
        'Name',
        () {goToEditAccount("name");},
        subText: globals.user.name,
        style: CSWidgetStyle(
          icon: Icon(Icons.person_outline_rounded, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Username',
        () {goToEditAccount("username");},
        subText: globals.user.username,
        style: CSWidgetStyle(
          icon: Icon(Icons.person, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Phone',
        () {goToEditAccount("phone");},
        subText: globals.user.phone == null ? "Add" : globals.user.phone,
        style: CSWidgetStyle(
          icon: Icon(Icons.phone_iphone, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Email',
        () {goToEditAccount("email");},
        subText: globals.user.userEmail,
        style: CSWidgetStyle(
          icon: Icon(Icons.email, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSLink(
        'Password',
        () {goToEditAccount("password");},
        style: CSWidgetStyle(
          icon: Icon(Icons.lock, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ),
      new CSHeader("General"),
      globals.user.userType == 2 ? CSLink(
        'Advanced Options',
        () {},
        style: CSWidgetStyle(
          icon: Icon(Icons.settings_applications_sharp, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ): Container(),
      globals.user.userType == 2 ? new CSLink(
        'Mobile Pay',
        () {},
        style: CSWidgetStyle(
          icon: Icon(Icons.payments_outlined, color: globals.darkModeEnabled ? Colors.white : Colors.black54)
        )
      ): Container(),
      new CSLink(
        'Payment Method',
        () {
          final paymentMethodController = new PaymentMethodController();
          Navigator.push(context, new MaterialPageRoute(builder: (context) => paymentMethodController));
        },
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
      // globals.user.userType == 1 ? new CSHeader("Appearance") : Container(),
      // globals.user.userType == 1 ?
      // new CSControl('Dark Mode', new CupertinoSwitch(value: globals.darkModeEnabled, onChanged: (value) {_handleDarkMode();}), style: CSWidgetStyle(icon: Icon(Icons.wb_sunny_outlined, color: globals.darkModeEnabled ? Colors.white : Colors.black54))) : Container(),
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
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: globals.user.userType == 1 ? false : true,
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