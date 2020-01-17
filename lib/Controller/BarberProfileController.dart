import 'package:flutter/material.dart';
import '../Controller/BookingController.dart';
import '../globals.dart' as globals;
import '../View/Widgets.dart';
import '../Model/availability.dart';
import '../calls.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:line_icons/line_icons.dart';
import '../Model/ClientBarbers.dart';
import 'package:flushbar/flushbar.dart';

class BarberProfileScreen extends StatefulWidget {
  final token;
  final ClientBarbers userInfo;
  BarberProfileScreen({Key key, this.token, this.userInfo}) : super (key: key);

  @override
  BarberProfileScreenState createState() => new BarberProfileScreenState();
}

class BarberProfileScreenState extends State<BarberProfileScreen> {
  ClientBarbers user;
  List<Availability> availability = [];
  bool hasAdded = false;


  @override
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

    var clientBarbers = await getUserBarbers(context, globals.token);
    for(var item2 in clientBarbers) {
      if(item2.id.contains(user.id)){
        setState(() {
          hasAdded = true;
        });
      }
    }
  }

  buildProfileBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: Color.fromARGB(255, 21, 21, 21),
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget> [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      width: 70,
                      height: 70,
                      child: Center(child:Text(user.name.substring(0,1), textAlign: TextAlign.center, style: TextStyle(fontSize: 40))),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: new LinearGradient(
                          colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                        )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          user.shopName != null && user.shopName != '' ? Container(width: MediaQuery.of(context).size.width * .36, child: AutoSizeText.rich(TextSpan(text: user.shopName, style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)), maxFontSize:16, minFontSize: 12, maxLines: 2)) : Container(),
                          Container(width: MediaQuery.of(context).size.width * .36, child: AutoSizeText.rich(TextSpan(text: user.shopAddress), maxFontSize:16, minFontSize: 12, maxLines: 2)),
                          Container(width: MediaQuery.of(context).size.width * .36, child: AutoSizeText.rich(TextSpan(text: user.city + ', ' + user.state + ' ' + user.zipcode), maxFontSize:16, minFontSize: 12, maxLines: 2)),
                          getRatingWidget(context, double.parse(user.rating))
                        ]
                      )
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          availabilityWidget(context, availability)
                        ]
                      )
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                ),
                int.parse(user.id) != globals.token ? Row(
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

                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.rate_review, size: 18),
                            Padding(padding: EdgeInsets.all(2)),
                            Text('Review')
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
                ): Container()
              ]
            )
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
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
              )
            ),
          )
        ],
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
        body: new Stack(
          children: <Widget> [
            buildProfileBody()
          ]
        )
      )
    );
  }
}