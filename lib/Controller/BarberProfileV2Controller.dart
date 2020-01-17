import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trimmz/Controller/BookingController.dart';
import '../globals.dart' as globals;
import '../View/Widgets.dart';
import '../Model/availability.dart';
import '../calls.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:line_icons/line_icons.dart';
import '../Model/ClientBarbers.dart';
import 'package:flushbar/flushbar.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../Model/Packages.dart';
import 'ReviewController.dart';

class BarberProfileV2Screen extends StatefulWidget {
  final token;
  final ClientBarbers userInfo;
  BarberProfileV2Screen({Key key, this.token, this.userInfo}) : super (key: key);

  @override
  BarberProfileV2ScreenState createState() => new BarberProfileV2ScreenState();
}

class BarberProfileV2ScreenState extends State<BarberProfileV2Screen> {
  ClientBarbers user;
  List<Availability> availability = [];
  List<Packages> packages = [];
  bool hasAdded = false;

  void initState() {
    super.initState();
    user = widget.userInfo;
    setUserInfo();
  }

  setUserInfo() async {
    var res1 = await getBarberAvailability(context, int.parse(user.id));

    setState(() {
      availability = res1;
      user = widget.userInfo;
    });

    var res2 = await getBarberPkgs(context, int.parse(user.id));

    setState(() {
      packages = res2;
    });

    var clientBarbers = await getUserBarbers(context, globals.token);
    for(var item2 in clientBarbers) {
      if(item2.id.contains(user.id)){
        setState(() {
          hasAdded = true;
        });
      }
    }
  }

  header() {
    return new Container(
      child: Stack(
        children: <Widget>[
          new Container(
            height: MediaQuery.of(context).size.width * .6,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
              )
            ),
          ),
          new Center(
            child: new ClipRect(
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                child: new Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * .6,
                  decoration: new BoxDecoration(
                    color: Colors.black.withOpacity(0.4)
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () async  {
                if (await canLaunch("sms:")) {
                  await launch("sms:");
                } else {
                  throw 'Could not launch';
                }
              },
              child: Container(
                margin: EdgeInsets.all(15),
                child: Icon(Icons.share, size: 25)
              )
            )
          )
        ],
      )
    );
  }

  profileSummary() {
    return Container(
      width: MediaQuery.of(context).size.width * .95,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 21, 21, 21),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(bottom: 5),
                child: Center(child:Text(user.name.substring(0,1), textAlign: TextAlign.center, style: TextStyle(fontSize: 30))),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: new LinearGradient(
                    colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                  )
                ),
              ),
            ]
          ),
          Padding(padding: EdgeInsets.all(5)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(2)),
              user.shopName != null && user.shopName != '' ? Container(width: MediaQuery.of(context).size.width * .33, child: AutoSizeText.rich(TextSpan(text: user.shopName, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)), maxFontSize:16, minFontSize: 13, maxLines: 1, overflow: TextOverflow.ellipsis)) : Container(),
              Padding(padding: EdgeInsets.all(2)),
              Row(
                children: <Widget> [
                  Icon(LineIcons.map_marker, size: 17),
                  Padding(padding: EdgeInsets.all(2)),
                  Container(width: MediaQuery.of(context).size.width * .33, child: AutoSizeText.rich(TextSpan(text: user.shopAddress + ', ' + user.city + ', ' + user.state + ' ' + user.zipcode), maxFontSize:16, minFontSize: 13, maxLines: 1, overflow: TextOverflow.ellipsis))
                ]
              ),
              Padding(padding: EdgeInsets.all(2)),
              returnDistanceFutureBuilder('${user.shopAddress}, ${user.city}, ${user.state} ${user.zipcode}'),
              Padding(padding: EdgeInsets.all(2)),
              getRatingWidget(context, double.parse(user.rating))
            ]
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                availabilityWidget(context, availability)
              ]
            )
          )
        ]
      )
    );
  }

  subBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .15, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          int.parse(user.id) != globals.token ? Column(
            children: <Widget> [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      if(!hasAdded){
                        bool res = await addBarber(context, globals.token, int.parse(user.id));
                        if(res) {
                          Flushbar(
                            flushbarPosition: FlushbarPosition.BOTTOM,
                            title: "Barber Added",
                            message: "You can now book an appointment with this barber",
                            duration: Duration(seconds: 2),
                          )..show(context);
                          setState(() {
                            hasAdded = true;
                          });
                        }
                      }else {
                        bool res = await removeBarber(context, globals.token, int.parse(user.id));
                        if(res) {
                          Flushbar(
                            flushbarPosition: FlushbarPosition.BOTTOM,
                            title: "Barber Removed",
                            message: "This barber has been removed from your list",
                            duration: Duration(seconds: 2),
                          )..show(context);
                          setState(() {
                            hasAdded = false;
                          });
                        }
                      }
                    },
                    child: Container( 
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          !hasAdded ? Icon(Icons.add, size: 18) : Icon(LineIcons.minus, size: 18),
                          !hasAdded ? Text('Add') : Text('Remove')
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Container( 
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.person_add, size: 18),
                          Padding(padding: EdgeInsets.all(2)),
                          Text('Follow')
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  GestureDetector(
                    onTap: () {
                      final reviewScreen = new ReviewController(userId: int.parse(user.id), username: user.username); 
                      Navigator.push(context, new MaterialPageRoute(builder: (context) => reviewScreen));
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.rate_review, size: 18),
                          Padding(padding: EdgeInsets.all(2)),
                          Text('Reviews')
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  GestureDetector(
                    onTap: () {
                      final bookingScreen = new BookingController(barberInfo: user); 
                      Navigator.push(context, new MaterialPageRoute(builder: (context) => bookingScreen));
                    },
                    child: Container( 
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.calendar_today, size: 18),
                          Padding(padding: EdgeInsets.all(2)),
                          Text('Book')
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey,
              )
            ]
          ): Container(),
          Text('Services', style: TextStyle(fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.all(5)),
          packages.length > 0 ? Container(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: packages.length,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                return Container(
                  padding: EdgeInsets.all(5),
                  //color: Colors.grey[900],
                  //margin: EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text('\$'+packages[i].price),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 21, 21, 21)
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5)),
                      Text(packages[i].name)
                    ]
                  )
                );
              },
            )
          ) : Container(child: Center(child: Text('Barber has no Packages', textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic)))),
          Divider(
            color: Colors.grey
          )
        ]
      )
    );
  }

  postBody() {
    return new Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
          Text(
            'Barber has no posts.\nPosts disabled',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * .018,
              color: Colors.grey[600]
            )
          ),
        ],
      ),
    );
  }

  buildProfileBody() {
    return Container(
      child: Column(
        children: <Widget>[
          header(),
          subBody(),
          postBody()
        ]
      )
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
        backgroundColor: Colors.black87,
        appBar: new AppBar(
          title: new Text('@'+user.username)
        ),
        body: new SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget> [
              buildProfileBody(),
              Positioned(
                top: MediaQuery.of(context).size.height * .25,
                child: profileSummary()
              ),
            ]
          )
        )
      )
    );
  }
}