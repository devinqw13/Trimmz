import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../CustomCupertinoSettings.dart';
import '../Controller/AboutController.dart';
import '../Controller/PaymentMethodController.dart';
import '../Controller/LoginController.dart';
import '../globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/BarberProfileV2Controller.dart';
import '../calls.dart';
import '../Model/availability.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../Controller/AccountSettingsController.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../functions.dart';
import '../Model/FeedItems.dart';
import 'package:line_icons/line_icons.dart';
import '../Controller/MobileTransactionsController.dart';

logout(BuildContext context) async {
  final loginScreen = new LoginScreen();
  Navigator.push(context, new MaterialPageRoute(builder: (context) => loginScreen));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

settingsWidget(BuildContext context) {
  CupertinoSettings settings = new CupertinoSettings(<Widget>[
    new CSHeader('Account'),
    new CSLink('Account Settings', () async {
      final accountSettingsScreen = new AccountSettings();
      var result = await Navigator.push(context, new MaterialPageRoute(builder: (context) => accountSettingsScreen));
      if(result != null) {
        if(result) {
          Flushbar(
            flushbarPosition: FlushbarPosition.BOTTOM,
            title: "Account Updated",
            message: "Your account has been updated.",
            duration: Duration(seconds: 5),
          )..show(context);
        }
      }
    }),

    globals.userType == 2 ? new CSHeader('Barber Settings') : Container(),
    globals.userType == 2 ? CSLink('View Profile', () async {var res = await getUserDetailsPost(globals.token, context); final profileScreen = new BarberProfileV2Screen(token: globals.token, userInfo: res); Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));}) : Container(),
    globals.userType == 2 ? CSLink('Mobile Transactions', () {final mobileTransaction = new MobileTransactionScreen(); Navigator.push(context, new MaterialPageRoute(builder: (context) => mobileTransaction));}) : Container(),

    new CSHeader('Payment'),
    new CSLink('Payment Method', () {final paymentMethodScreen = new PaymentMethodScreen(signup: false); Navigator.push(context, new MaterialPageRoute(builder: (context) => paymentMethodScreen));}),

    new CSHeader('Share'),
    new CSLink('Recommend Trimmz', () async {
      if (await canLaunch("sms:")) {
        await launch("sms:");
      } else {
        throw 'Could not launch';
      }
    }),
    new CSLink('Invite Barber', () async {
      if (await canLaunch("sms:")) {
        await launch("sms:");
      } else {
        throw 'Could not launch';
      }
    }),

    new CSHeader('Contact Us'),
    new CSLink('Feedback', () async {
      String email = 'trimmzapp@gmail.com';
      if (await canLaunch("mailto:$email")) {
        await launch("mailto:$email?subject=Trimmz Feedback");
      } else {
        throw 'Could not launch';
      }
    }),
    new CSLink('Support', () async {
      String email = 'trimmz@gmail.com';
      if (await canLaunch("mailto:$email")) {
        await launch("mailto:$email?subject=Trimmz Support");
      } else {
        throw 'Could not launch';
      }
    }),

    new CSHeader('General'),
    new CSLink('About', () {final aboutScreen = new AboutController(); Navigator.push(context, new MaterialPageRoute(builder: (context) => aboutScreen));}),
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
      final df = new DateFormat('ha');
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

  getRatingWidget(BuildContext context, double rating) {
    return new Row(
      children: <Widget>[
        Text(
          rating.toString(),
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
        ),
      ],
    );
  }

  returnDistanceFutureBuilder(String shopLocation) {
    return FutureBuilder(
      future: getDistanceFromBarber(shopLocation),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasError) return Text('${snapshot.error}');
        if (snapshot.hasData)
          return Row(
            children: <Widget> [
              Icon(Icons.directions, color: Colors.grey, size: 19),
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

  Future<Null> refreshHomeList() async {
  //  Completer<Null> completer = new Completer<Null>();
  //   refreshKey.currentState.show();
  //   //var results = await getTimeline(context);
  //   var results = await getUserMoves(context);
  //   completer.complete();
  //   setState(() {
  //     userMoves = results;    
  //   });
  //   _buildTabBarViewContainer();
  //   return completer.future;
  }

  List<Image> _buildImageList(List<FeedItem> timelineItems,double scale) {
    var imageList = new List<Image>();
    for (var item in timelineItems) {
      if (item.userId.toString().length > 0) {
        imageList.add(new Image.network("", 
          scale: scale)
        );
      } else {
        imageList.add(new Image.network("https://ocelli.erpsuites.com/ocelli/dist/icons/missing.png", 
          scale: scale)
        );
      }
    }
    return imageList;
  }

  buildFeed(BuildContext context, ) {
    List<FeedItem> feedItems = [];
    Radius cardEdgeRadius;
    List<Image> imageList = new List<Image>();
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenHeight =MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double textScale = 1.0;
    double listImageScale;
    final GlobalKey<RefreshIndicatorState> refreshKey = new GlobalKey<RefreshIndicatorState>();

    // iPad 9.7
    if (orientation == Orientation.portrait) {
      if (screenHeight >= 960 &&  screenHeight < 1366) {
        textScale = 1.2;
        listImageScale = 2.75;
        cardEdgeRadius = Radius.circular(8.0);
      }
      else if (screenHeight >= 1366) {
        textScale = 1.55;
        listImageScale = 2.75;
        cardEdgeRadius = Radius.circular(8.0);
      }
      // Phone
      else {
        textScale = 1.1;
        listImageScale = 3.0;
        cardEdgeRadius = Radius.circular(8.0);
      }
    }
    else if (orientation == Orientation.landscape) {
      if (screenWidth >= 812 &&  screenWidth < 1366) {
        textScale = 1.2;
        listImageScale = 2.75;
        cardEdgeRadius = Radius.circular(8.0);
      } 
      // iPad 12.9
      else if (screenWidth >= 1366) {
        textScale = 1.55;
        listImageScale = 2.75;
        cardEdgeRadius = Radius.circular(8.0);
      }
      // Phone
      else {
        textScale = 1.1;
        listImageScale = 3.0;
        cardEdgeRadius = Radius.circular(8.0);
      }
    }

    imageList = _buildImageList(feedItems, listImageScale);
    if (feedItems.length > 0) {
      return new RefreshIndicator(
        onRefresh: refreshHomeList,
        key: refreshKey,
        child: new ListView.builder(
          itemCount: feedItems.length * 2,
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return new Divider();
            }
            else {
              final i = index ~/ 2;
              return new ListTile(
                leading: imageList[i],
                title: new Text(feedItems[i].userId.toString(),
                  style: new TextStyle(
                    fontSize: 12.0 * textScale
                  ),
                ),
              );
            }
          },
        ),
      );
    }else {
      return new RefreshIndicator(
        color: globals.darkModeEnabled ? Colors.white : globals.userColor,
        onRefresh: refreshHomeList,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
            new Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: new Text(
                "Follow a barber to start viewing cuts",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * .018,
                  color: Colors.grey[600]
                )
              ),
            ),
          ],
        )
      );
    }
  }