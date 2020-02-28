import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Controller/MobileTransactionSetup.dart';
import 'package:trimmz/Controller/ReviewController.dart';
import '../CustomCupertinoSettings.dart';
import '../Controller/AboutController.dart';
import '../Controller/PaymentMethodController.dart';
import '../Controller/LoginController.dart';
import '../Calls/GeneralCalls.dart';
import '../functions.dart';
import '../globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/BarberProfileV2Controller.dart';
import '../Model/availability.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../Controller/AccountSettingsController.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';
import '../Controller/MobileTransactionsController.dart';

logout(BuildContext context) async {
  final loginScreen = new LoginScreen();
  Navigator.push(context, new MaterialPageRoute(builder: (context) => loginScreen));
  var _ = await removeFirebaseToken(context);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

settingsWidget(BuildContext context) {
  CupertinoSettings settings = new CupertinoSettings(<Widget>[
    new CSHeader('Account'),
    new CSLink('Account Settings', () async {
      final accountSettingsScreen = new AccountSettings();
      Navigator.push(context, new MaterialPageRoute(builder: (context) => accountSettingsScreen));
    }, style: CSWidgetStyle(icon: Icon(LineIcons.cog))),
    globals.userType == 2 ? CSLink('View Profile', () async {var res = await getUserDetailsPost(globals.token, context); var res2 = await getBarberPolicies(context, globals.token); final profileScreen = new BarberProfileV2Screen(token: globals.token, userInfo: res, barberPolicies: res2); Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));}, style: CSWidgetStyle(icon: Icon(LineIcons.user))) : Container(),
    globals.userType == 2 ? CSLink('Reviews', () {final reviewController = new ReviewController(userId: globals.token, username: globals.username); Navigator.push(context, new MaterialPageRoute(builder: (context) => reviewController));}, style: CSWidgetStyle(icon: Icon(Icons.chat_bubble_outline))) : Container(),

    globals.userType == 2 ? new CSHeader('Barber Settings') : Container(),
    //globals.userType == 2 ? CSLink('Client Book', () {}, style: CSWidgetStyle(icon: Icon(LineIcons.book))) : Container(),
    globals.userType == 2 ? CSLink('Mobile Pay', () {
      final mobileTransaction = globals.spPayoutMethod == null || globals.spPayoutId == null || globals.spAccountId == null ? new MobileTransactionSetup() : new MobileTransactionScreen();
      Navigator.push(context, new MaterialPageRoute(builder: (context) => mobileTransaction));
      }, style: CSWidgetStyle(icon: Icon(LineIcons.money))) : Container(),

    new CSHeader('Payment'),
    new CSLink('Payment Method', () {final paymentMethodScreen = new PaymentMethodScreen(signup: false); Navigator.push(context, new MaterialPageRoute(builder: (context) => paymentMethodScreen));}, style: CSWidgetStyle(icon: Icon(Icons.credit_card))),

    new CSHeader('Share'),
    new CSLink('Recommend Trimmz', () async {
      final separator = Platform.isIOS ? '&' : '?';
      String message = '${separator}body=Check%20out%20this%20app,%20Trimmz.%20You%20can%20book%20appointment,%20view%20cuts,%20and%20more.%20Download%20the%20app%20at%20https://trimmz.app/';
      if (await canLaunch("sms:$message")) {
        await launch("sms:$message");
      } else {
        throw 'Could not launch';
      }
    }, style: CSWidgetStyle(icon: Icon(LineIcons.lightbulb_o))),
    new CSLink('Invite Barber', () async {
      final separator = Platform.isIOS ? '&' : '?';
      String message = '${separator}body=Check%20this%20app%20for%20barbers,%20Trimmz.%20Download%20the%20app%20at%20https://trimmz.app/';
      if (await canLaunch("sms:$message")) {
        await launch("sms:$message");
      } else {
        throw 'Could not launch';
      }
    }, style: CSWidgetStyle(icon: Icon(LineIcons.share))),

    new CSHeader('Contact Us'),
    new CSLink('Feedback', () async {
      String email = 'trimmzapp@gmail.com';
      if (await canLaunch("mailto:$email")) {
        await launch("mailto:$email?subject=Feedback");
      } else {
        throw 'Could not launch';
      }
    }, style: CSWidgetStyle(icon: Icon(LineIcons.envelope))),
    new CSLink('Support', () async {
      String email = 'trimmz@gmail.com';
      if (await canLaunch("mailto:$email")) {
        await launch("mailto:$email?subject=Support");
      } else {
        throw 'Could not launch';
      }
    }, style: CSWidgetStyle(icon: Icon(Icons.help_outline))),

    new CSHeader('General'),
    new CSLink('About', () {final aboutScreen = new AboutController(); Navigator.push(context, new MaterialPageRoute(builder: (context) => aboutScreen));}, style: CSWidgetStyle(icon: Icon(Icons.brightness_auto))),
    new CSLink('Privacy Policy', () async {
      String url = 'https://trimmz.app/privacy/';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch';
      }
    }, style: CSWidgetStyle(icon: Icon(Icons.lock_outline))),
    new CSLink('Logout', () {logout(context);}, style: CSWidgetStyle(icon: Icon(Icons.exit_to_app))),
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
      final df = new DateFormat('ha');
      if(availability[i].start != null && availability[i].end != null) {
        if(availability[i].start == '0:00:00' && availability[i].end == '0:00:00') {
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

  getRatingWidget(BuildContext context, double rating) {
    return new Row(
      children: <Widget>[
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: Color(0xFFD2AC47),
            fontSize: 14
          )
        ),
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Color(0xFFD2AC47),
          ),
          itemCount: 5,
          itemSize: 17.0,
          direction: Axis.horizontal,
          unratedColor: Colors.white70,
        ),
      ],
    );
  }

  returnDistanceFutureBuilder(String shopLocation, Color iconColor) {
    return FutureBuilder(
      future: getDistanceFromBarber(shopLocation),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) return Text('${snapshot.error}');
        if (snapshot.hasData)
          return Row(
            children: <Widget> [
              Icon(Icons.directions, color: iconColor, size: 17),
              Padding(padding: EdgeInsets.all(2)),
              Text('${snapshot.data} mi')
            ]
          );
        return Row(
          children: <Widget>[
            Icon(Icons.directions, color: Colors.grey, size: 19),
            Padding(padding: EdgeInsets.all(5)),
            Container(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey)
              )
            )
          ]
        );
      },
    );
  }

  buildProfilePictures(BuildContext context, String profilePicture, String name, double radius) {
    if(profilePicture != null && profilePicture != '') {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage('${globals.baseUrlImage}$profilePicture'),
      );
    }else {
      return Container(
        child: CircleAvatar(
          child: Center(child:Text(name.substring(0,1), style: TextStyle(color: Colors.white, fontSize: (radius-5.0)))),
          radius: radius,
          backgroundColor: Colors.transparent,
        ),
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.purple,
          gradient: new LinearGradient(
            colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
          )
        ),
      );
    }
  }

  buildProfileHeader(BuildContext context, String headerPicture) {
    if(headerPicture != null && headerPicture != '') {
      return Container(
        height: MediaQuery.of(context).size.width * .6,
        width: MediaQuery.of(context).size.width,
        child: Image.network(
          '${globals.baseUrlImage}$headerPicture',
          fit: BoxFit.cover,
        ),
      );
    }else {
      return new Container(
        height: MediaQuery.of(context).size.width * .6,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
          )
        ),
      );
    }
  }