import 'package:flutter/material.dart';
import '../CustomCupertinoSettings.dart';
import '../globals.dart' as globals;
import 'package:line_icons/line_icons.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../Controller/MobileTransactionsController.dart';
import '../Controller/AccountSettingsController.dart';
import '../Controller/MobileTransactionSetup.dart';
import 'package:trimmz/Controller/ReviewController.dart';
import '../Controller/AboutController.dart';
import '../Controller/PaymentMethodController.dart';
import '../Calls/GeneralCalls.dart';
import '../Controller/BarberProfileV2Controller.dart';
import '../Controller/LoginController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Controller/AppearanceSettings.dart';
import '../Controller/AdminPortalController.dart';
import '../Controller/AdvancedSettingsController.dart';

class SettingsTab extends StatefulWidget {
  SettingsTab();

  @override
  SettingsTabState createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab> {
  CupertinoSettings settings;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  void initState() {
    super.initState();
    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
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

  logout(BuildContext context) async {
    final loginScreen = new LoginScreen();
    Navigator.push(context, new MaterialPageRoute(builder: (context) => loginScreen));
    var _ = await removeFirebaseToken(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  goToAppearance() {
    final appearance = new AppearanceSettings(settings: settings);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => appearance));
  }

  // _darkModeChanged(bool value) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('darkModeEnabled', value);
  //   setState(() {
  //     if (value == true) {
  //       globals.userBrightness = Brightness.dark;
  //       globals.darkModeEnabled = true;
  //       globals.userColor = Color.fromARGB(255, 0, 0, 0);
  //       settings.setDarkMode();
  //     }
  //     else {
  //       globals.userBrightness = Brightness.light;
  //       globals.darkModeEnabled = false;
  //       globals.userColor = Color.fromARGB(255, 255, 255, 255);
  //       settings.setLightMode();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    settings = new CupertinoSettings(<Widget>[
      globals.userType == 3 ? new CSHeader('Admin Settings') : Container(),
      globals.userType == 3 ? new CSLink('Admin Portal', () async {
        final adminPortal = new AdminPortal();
        Navigator.push(context, new MaterialPageRoute(builder: (context) => adminPortal));
      }, style: CSWidgetStyle(icon: Icon(LineIcons.cog, color: globals.darkModeEnabled ? Colors.white : Colors.black54))) : Container(),
      new CSHeader('Appearance'),
      // new CSControl(
      //   'Dark Mode',
      //   Switch(
      //     activeColor: Colors.blue,
      //     value: globals.darkModeEnabled,
      //     onChanged: (value) {
      //       _darkModeChanged(value);
      //     },
      //   ),
      //   style: CSWidgetStyle(icon: Icon(Icons.settings_brightness, color: globals.darkModeEnabled ? Colors.white : Colors.black54))
      // ),
      new CSLink('Appearance', () async {
        goToAppearance();
      }, style: CSWidgetStyle(icon: Icon(Icons.settings_brightness, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),
      new CSHeader('Account'),
      new CSLink('Account Settings', () async {
        final accountSettingsScreen = new AccountSettings();
        Navigator.push(context, new MaterialPageRoute(builder: (context) => accountSettingsScreen));
      }, style: CSWidgetStyle(icon: Icon(LineIcons.cog, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),
      globals.userType == 2 ? CSLink('View Profile', () async {progressHUD(); var res = await getUserDetailsPost(globals.token, context); var res2 = await getBarberPolicies(context, globals.token); progressHUD(); final profileScreen = new BarberProfileV2Screen(token: globals.token, userInfo: res, barberPolicies: res2); Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));}, style: CSWidgetStyle(icon: Icon(LineIcons.user, color: globals.darkModeEnabled ? Colors.white : Colors.black54))) : Container(),
      globals.userType == 2 ? CSLink('Reviews', () {final reviewController = new ReviewController(userId: globals.token, username: globals.username); Navigator.push(context, new MaterialPageRoute(builder: (context) => reviewController));}, style: CSWidgetStyle(icon: Icon(Icons.chat_bubble_outline, color: globals.darkModeEnabled ? Colors.white : Colors.black54))) : Container(),

      globals.userType == 2 ? new CSHeader('Barber Settings') : Container(),
      globals.userType == 2 ? CSLink('Advanced Settings', () {final advSettingsController = new AdvancedSettingsController(); Navigator.push(context, new MaterialPageRoute(builder: (context) => advSettingsController));}, style: CSWidgetStyle(icon: Icon(LineIcons.cogs))) : Container(),
      //globals.userType == 2 ? CSLink('Client Book', () {}, style: CSWidgetStyle(icon: Icon(LineIcons.book))) : Container(),
      globals.userType == 2 ? CSLink('Mobile Pay', () {
        final mobileTransaction = globals.spPayoutMethod == null || globals.spPayoutId == null || globals.spAccountId == null ? new MobileTransactionSetup() : new MobileTransactionScreen();
        Navigator.push(context, new MaterialPageRoute(builder: (context) => mobileTransaction));
        }, style: CSWidgetStyle(icon: Icon(LineIcons.money, color: globals.darkModeEnabled ? Colors.white : Colors.black54))) : Container(),

      new CSHeader('Payment'),
      new CSLink('Payment Method', () {final paymentMethodScreen = new PaymentMethodScreen(signup: false); Navigator.push(context, new MaterialPageRoute(builder: (context) => paymentMethodScreen));}, style: CSWidgetStyle(icon: Icon(Icons.credit_card, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),

      new CSHeader('Share'),
      new CSLink('Recommend Trimmz', () async {
        final separator = Platform.isIOS ? '&' : '?';
        String message = '${separator}body=Check%20out%20this%20app,%20Trimmz.%20You%20can%20book%20appointment,%20view%20cuts,%20and%20more.%20Download%20the%20app%20at%20https://trimmz.app/';
        if (await canLaunch("sms:$message")) {
          await launch("sms:$message");
        } else {
          throw 'Could not launch';
        }
      }, style: CSWidgetStyle(icon: Icon(LineIcons.lightbulb_o, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),
      new CSLink('Invite Barber', () async {
        final separator = Platform.isIOS ? '&' : '?';
        String message = '${separator}body=Check%20this%20app%20for%20barbers,%20Trimmz.%20Download%20the%20app%20at%20https://trimmz.app/';
        if (await canLaunch("sms:$message")) {
          await launch("sms:$message");
        } else {
          throw 'Could not launch';
        }
      }, style: CSWidgetStyle(icon: Icon(LineIcons.share, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),

      new CSHeader('Contact Us'),
      new CSLink('Feedback', () async {
        String email = 'trimmzapp@gmail.com';
        if (await canLaunch("mailto:$email")) {
          await launch("mailto:$email?subject=Feedback");
        } else {
          throw 'Could not launch';
        }
      }, style: CSWidgetStyle(icon: Icon(LineIcons.envelope, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),
      new CSLink('Support', () async {
        String email = 'trimmz@gmail.com';
        if (await canLaunch("mailto:$email")) {
          await launch("mailto:$email?subject=Support");
        } else {
          throw 'Could not launch';
        }
      }, style: CSWidgetStyle(icon: Icon(Icons.help_outline, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),

      new CSHeader('General'),
      new CSLink('About', () {final aboutScreen = new AboutController(); Navigator.push(context, new MaterialPageRoute(builder: (context) => aboutScreen));}, style: CSWidgetStyle(icon: Icon(Icons.brightness_auto, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),
      new CSLink('Privacy Policy', () async {
        String url = 'https://trimmz.app/privacy/';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch';
        }
      }, style: CSWidgetStyle(icon: Icon(Icons.lock_outline, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),
      new CSLink('Logout', () {logout(context);}, style: CSWidgetStyle(icon: Icon(Icons.exit_to_app, color: globals.darkModeEnabled ? Colors.white : Colors.black54))),
      new Container(
        margin: EdgeInsets.all(10),
        child: Center(
          child: Text(
            'Logged in as: '+globals.username,
            style: TextStyle(color: Colors.grey[500])
          )
        )
      )
    ]);

    return Stack(
      children: <Widget>[
        settings,
        _progressHUD
      ]
    );
  }
}