import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../CustomCupertinoSettings.dart';
import '../Controller/AboutController.dart';
import '../Controller/PaymentMethod.dart';
import '../Controller/LoginController.dart';
import '../globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/BarberProfileController.dart';
import '../calls.dart';
import '../Model/availability.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

logout(BuildContext context) async {
  final loginScreen = new LoginScreen();
  Navigator.push(context, new MaterialPageRoute(builder: (context) => loginScreen));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

settingsWidget(BuildContext context) {
  CupertinoSettings settings = new CupertinoSettings(<Widget>[
    new CSHeader('Account'),
    new CSLink('Account Settings', () {}),
    new CSLink('Password', () {}),

    globals.userType == 2 ? new CSHeader('Barber Settings') : Container(),
    globals.userType == 2 ? CSLink('View Profile', () async {var res = await getUserDetailsPost(globals.token, context); final profileScreen = new BarberProfileScreen(token: globals.token, userInfo: res); Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));}) : Container(),
    globals.userType == 2 ? CSLink('Mobile Transactions', () {final paymentMethodScreen = new PaymentMethod(); Navigator.push(context, new MaterialPageRoute(builder: (context) => paymentMethodScreen));}) : Container(),

    new CSHeader('Payment'),
    new CSLink('Payment Method', () {final paymentMethodScreen = new PaymentMethod(signup: false); Navigator.push(context, new MaterialPageRoute(builder: (context) => paymentMethodScreen));}),
    new CSHeader('General'),
    new CSLink('About', () {final aboutScreen = new AboutController(); Navigator.push(context, new MaterialPageRoute(builder: (context) => aboutScreen));}),
    new CSLink('Licensing', () {}),
    new CSLink('Logout', () {logout(context);}),
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

  return settings;
}

availabilityWidget(BuildContext context, List<Availability> availability) {
  return ListView.builder(
    padding: EdgeInsets.all(0),
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: availability.length,
    itemBuilder: (context, i){
      bool isNull = false;
      String start;
      String end;
      final df = new DateFormat('hh:mm');
      if(availability[i].start != null && availability[i].end != null) {
        if(availability[i].start == '00:00:00' && availability[i].end == '00:00:00') {
          isNull = true;
        }else {
          start = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].start).toString()));
          end = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].end).toString()));
        }
      }else {
        isNull = true;
      }

      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AutoSizeText.rich(
              TextSpan(
                text: availability[i].day,
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              maxLines: 1,
              maxFontSize: 13,
            ),
            AutoSizeText.rich(
              TextSpan(
                text: isNull ? 'Closed' : start + "-" + end,
              ),
              maxLines: 1,
              maxFontSize: 16,
            )
          ],
        )
      );
      },
    );
  }