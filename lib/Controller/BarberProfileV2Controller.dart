import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trimmz/Controller/BookingController.dart';
import '../Model/BarberPolicies.dart';
import '../globals.dart' as globals;
import '../View/Widgets.dart';
import '../Model/availability.dart';
import '../calls.dart';
import 'package:line_icons/line_icons.dart';
import '../Model/ClientBarbers.dart';
import 'package:flushbar/flushbar.dart';
import 'dart:ui';
import '../Model/Packages.dart';
import 'ReviewController.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../Model/FeedItems.dart';

class BarberProfileV2Screen extends StatefulWidget {
  final token;
  final ClientBarbers userInfo;
  final BarberPolicies barberPolicies;
  BarberProfileV2Screen({Key key, this.token, this.userInfo, this.barberPolicies}) : super (key: key);

  @override
  BarberProfileV2ScreenState createState() => new BarberProfileV2ScreenState();
}

class BarberProfileV2ScreenState extends State<BarberProfileV2Screen> {
  BarberPolicies policies = new BarberPolicies();
  ClientBarbers user;
  List<Availability> availability = [];
  List<Packages> packages = [];
  List<FeedItem> feedItems = [];
  bool hasAdded = false;

  void initState() {
    super.initState();
    user = widget.userInfo;
    policies = widget.barberPolicies ?? new BarberPolicies();
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

    var res3 = await getPosts(context, widget.token, 2);
    setState(() {
      feedItems = res3;
    });
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
          int.parse(user.id) != globals.token ? Container(
            padding: EdgeInsets.all(5),
            color: Color.fromRGBO(0, 0, 0, 0.2),
            child: Column(
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
                      onTap: () async {
                        if(!hasAdded){
                          var res = await addBarber(context, globals.token, int.parse(user.id));
                          if(res) {
                            setState(() {
                              hasAdded = true;
                            });
                          }
                        }
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
                            Icon(Icons.chat_bubble_outline, size: 18),
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
                      onTap: () async {
                        final separator = Platform.isIOS ? '&' : '?';
                        String message = '${separator}body=Check%20out%20this%20barber,%20${user.username}.%20You%20can%20view%20their%20cuts%20and%20book%20an%20appointment%20using%20the%20Trimmz%20app.%20Download%20the%20app%20at%20https://trimmz.app/';

                        if (await canLaunch("sms:$message")) {
                          await launch("sms:$message");
                        } else {
                          throw 'Could not launch';
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.share, size: 17),
                            Padding(padding: EdgeInsets.all(2)),
                            Text('Share')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ]
            )
          ): Container(),
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
              buildProfilePictures(context, user.profilePicture, user.username, 25)
            ]
          ),
          Padding(padding: EdgeInsets.all(5)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              user.name.length > 12 ? Container(
                width: MediaQuery.of(context).size.width * .33,
                height: 20,
                child: Marquee(
                  text: user.name + ' ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                  scrollAxis: Axis.horizontal,
                  pauseAfterRound: Duration(seconds: 2),
                  accelerationDuration: Duration(seconds: 5),
                  decelerationDuration: Duration(milliseconds: 5),
                  accelerationCurve: Curves.linear,
                  velocity: 50.0,
                )
              ): 
              Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Padding(padding: EdgeInsets.all(2)),
              user.shopName != null && user.shopName != '' ? user.shopName.length > 16 ? Container(
                width: MediaQuery.of(context).size.width * .33,
                height: 20,
                child: Marquee(
                  text: user.shopName + ' ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey
                  ),
                  scrollAxis: Axis.horizontal,
                  pauseAfterRound: Duration(seconds: 2),
                  accelerationDuration: Duration(seconds: 5),
                  decelerationDuration: Duration(milliseconds: 5),
                  accelerationCurve: Curves.linear,
                  velocity: 50.0,
                )
              ):
              Text(user.shopName, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)) : Container(),
              Padding(padding: EdgeInsets.all(2)),
              GestureDetector(
                onTap: () async {

                },
                child: Row(
                  children: <Widget> [
                    Icon(LineIcons.map_marker, size: 17),
                    Padding(padding: EdgeInsets.all(2)),
                    Container(
                      width: MediaQuery.of(context).size.width * .28,
                      height: 16,
                      child: Marquee(
                        text: user.shopAddress + ', ' + user.city + ', ' + user.state + ' ' + user.zipcode + ' ',
                        scrollAxis: Axis.horizontal,
                        pauseAfterRound: Duration(seconds: 2),
                        accelerationDuration: Duration(seconds: 5),
                        decelerationDuration: Duration(milliseconds: 5),
                        accelerationCurve: Curves.linear,
                        velocity: 50.0,
                      )
                    )
                  ]
                )
              ),
              Padding(padding: EdgeInsets.all(2)),
              returnDistanceFutureBuilder('${user.shopAddress}, ${user.city}, ${user.state} ${user.zipcode}', Colors.white),
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

  services() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
          ) : Container(child: Center(child: Text('Barber has no services', textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic)))),
        ]
      )
    );
  }

  policiesWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
          children: <Widget>[
            Icon(LineIcons.times, color: Colors.white),
            Padding(padding: EdgeInsets.all(5)),
            policies.cancelEnabled ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Cancellation Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                Text('Fee Amount: ${policies.cancelFee}'),
                Text('Within: ${policies.cancelWithinTime} Hour')
              ]
            ) :
            Text('No Cancellation Policy', style: TextStyle(fontWeight: FontWeight.bold))
          ]
        ),
        Padding(
          padding: EdgeInsets.all(5)
        ),
        Row(
          children: <Widget>[
            Icon(LineIcons.minus, color: Colors.white),
            Padding(padding: EdgeInsets.all(5)),
            policies.noShowEnabled ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No-Show Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                Text('Fee Amount: ${policies.noShowFee}'),
              ]
            ) :
            Text('No No-Show Policy', style: TextStyle(fontWeight: FontWeight.bold))
          ]
        ),
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
          services(),
          Divider(
            color: Colors.grey
          ),
          policiesWidget(),
          Divider(
            color: Colors.grey
          )
        ]
      )
    );
  }

  _buildGridTile(var item) {
    return new GestureDetector(
      onTap: () {},
      child: Container(
        child: new Column(
          children: <Widget>[
            new Expanded(
              flex: 5,
              child: new Container(
                child: Image.network(item.imageUrl, fit: BoxFit.fill,),
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(2.0))
                ),
              ),
            ),
          ],
        ),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        )
      )
    );
  }

  postBody() {
    if(feedItems.length > 0) {
      return new GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: feedItems.length,
        padding: EdgeInsets.all(2),
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: 0.9
        ),
        itemBuilder: (context, index) {
          return new Card(
            child: _buildGridTile(feedItems[index]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))
            ),
          );
        },
      );
    }else {
      return new Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
            Text(
              'Barber has no posts yet.',
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
  }

  buildProfileBody() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
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
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new Text('@'+user.username)
        ),
        body: new SingleChildScrollView(
          physics: ClampingScrollPhysics(),
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