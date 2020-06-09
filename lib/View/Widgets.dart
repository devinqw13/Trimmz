import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Controller/LoginController.dart';
import '../Calls/GeneralCalls.dart';
import '../functions.dart';
import '../globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/availability.dart';
import 'package:trimmz/Model/AvailabilityV2.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

logout(BuildContext context) async {
  final loginScreen = new LoginScreen();
  Navigator.push(context, new MaterialPageRoute(builder: (context) => loginScreen));
  var _ = await removeFirebaseToken(context);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

availabilityV2Widget(BuildContext context, List<AvailabilityV2> availabilityV2) {
  List<AvailabilityV2> currentWeek = [];
  List<DateTime> weekList = [];
  DateTime now = DateTime.now();
  for(int i=0 ; i<7;i++){
    weekList.add(DateTime.parse(DateFormat('yyyy-MM-dd 12:00:00').format(now.add(new Duration(days: i)))));
  }
  for(var item in weekList) {
    var availability = new AvailabilityV2();
    var currentDate = availabilityV2.where((element) => element.date == item);
    if(currentDate.length == 1) {
      availability.date = currentDate.first.date;
      availability.closed = currentDate.first.closed;
      availability.start = currentDate.first.start;
      availability.end = currentDate.first.end;
      currentWeek.add(availability);
    }else {
      availability.closed = 1;
      availability.date = item;
      availability.start = '09:00:00';
      availability.end = '17:00:00';
      currentWeek.add(availability);
    }
  }

  return ListView.builder(
    padding: EdgeInsets.all(0),
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: currentWeek.length,
    itemBuilder: (context, i){
      bool isClosed = false;
      final df = new DateFormat('ha');
      String start = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(currentWeek[i].start).toString()));
      String end = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(currentWeek[i].end).toString()));
      if(currentWeek[i].closed == 1) {
        isClosed = true;
      }
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AutoSizeText.rich(
              TextSpan(
                text: DateFormat.EEEE().format(currentWeek[i].date),
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              maxLines: 1,
              maxFontSize: 13,
            ),
            AutoSizeText.rich(
              TextSpan(
                text: isClosed ? 'Closed' : start + "-" + end,
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
        backgroundColor: globals.darkModeEnabled ? Colors.black : Colors.white,
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
          color: globals.darkModeEnabled ? Colors.black : Colors.white,
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