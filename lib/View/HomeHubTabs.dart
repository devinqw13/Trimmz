import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Calls/GeneralCalls.dart';
import '../globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:expandable/expandable.dart';
import '../Controller/SelectBarberController.dart';
import 'package:line_icons/line_icons.dart';
import '../View/Widgets.dart';
import '../Model/Appointment.dart';
import 'package:intl/intl.dart';
import '../Model/FeedItems.dart';
import 'dart:async';
import '../functions.dart';
import '../Controller/BarberProfileV2Controller.dart';

class HomeHubTabWidget extends StatefulWidget{
  final int widgetItem;
  HomeHubTabWidget(this.widgetItem);

  @override
  HomeHubTabWidgetState  createState() => HomeHubTabWidgetState ();
}

class HomeHubTabWidgetState extends State<HomeHubTabWidget> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey = new GlobalKey<RefreshIndicatorState>();
  Appointment upcomingAppointment;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<FeedItem> feedItems = [];

  void initState() {
    super.initState();
    initChecks();

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

  initChecks() async {
    var res1 = await getUpcomingAppointment(context, globals.token);
    setState(() {
      upcomingAppointment = res1;
    });

    var res2 = await getPosts(context, globals.token, 1);
    setState(() {
      feedItems = res2;
    });
  }

  upcomingAlert() {
    if(upcomingAppointment != null){
      final df = new DateFormat('EEE, MMM d @ hh:mm a');
      String appointmentTime = df.format(DateTime.parse(upcomingAppointment.dateTime.toString()));
      return ExpandableNotifier(
        child: Card(
          child: Column(
            children: <Widget>[
              Expandable(
                collapsed: ExpandableButton(
                  child: Container(
                    padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0),
                    height: 40.0,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .85,
                          child: RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: new TextSpan(
                              children: <TextSpan> [
                                new TextSpan(text: 'Upcoming Appointment: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: appointmentTime),
                              ]
                            )
                          )
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ),
                expanded: Column(
                  children: <Widget>[
                    ExpandableButton(
                      child: Container(
                        padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0),
                        height: 40.0,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * .85,
                              child: RichText(
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                text: new TextSpan(
                                  children: <TextSpan> [
                                    new TextSpan(text: 'Upcoming Appointment', style: new TextStyle(fontWeight: FontWeight.bold)),
                                  ]
                                )
                              )
                            ),
                            Icon(Icons.arrow_drop_up)
                          ],
                        ),
                      ),
                    ),
                    new Container(
                      decoration: BoxDecoration(
                        color: globals.userBrightness == Brightness.light ? Color.fromARGB(255, 242, 242, 242) : Color.fromARGB(255, 42, 42, 42),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4.0),
                          bottomRight: Radius.circular(4.0)
                        )
                      ),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 12.0, top: 10.0, right: 12.0, bottom: 10),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: new TextSpan(
                              children: <TextSpan> [
                                new TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: appointmentTime)
                              ]
                            )
                          ),
                          RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: new TextSpan(
                              children: <TextSpan> [
                                new TextSpan(text: 'Barber: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: upcomingAppointment.barberName)
                              ]
                            )
                          ),
                          RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: new TextSpan(
                              children: <TextSpan> [
                                new TextSpan(text: 'Location: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '${upcomingAppointment.locationAddress}, ${upcomingAppointment.geoAddress}')
                              ]
                            )
                          )
                        ]
                      )
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }else {
      return Container();
    }
  }

  Future<Null> refreshFeedList() async {
   Completer<Null> completer = new Completer<Null>();
    refreshKey.currentState.show();
    var results = await getPosts(context, globals.token, 1);
    completer.complete();
    setState(() {
      feedItems = results;
    });
    return completer.future;
  }

  feedList() {
    if (feedItems.length > 0) {
      return new RefreshIndicator(
        color: Colors.blue,
        onRefresh: refreshFeedList,
        key: refreshKey,
        child: new ListView.builder(
          itemCount: feedItems.length,
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, i) {
            return Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          feedItems[i].imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        color: Color.fromRGBO(21, 21, 21, 0.6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                progressHUD();
                                var res = await getUserDetailsPost(feedItems[i].userId, context);
                                var res2 = await getBarberPolicies(context, feedItems[i].userId);
                                progressHUD();
                                final profileScreen = new BarberProfileV2Screen(token: feedItems[i].userId, userInfo: res, barberPolicies: res2);
                                Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));
                              },
                              child: Row(
                                children: <Widget>[
                                  buildProfilePictures(context, feedItems[i].profilePic, feedItems[i].username, 20),
                                  Padding(padding: EdgeInsets.all(5)),
                                  Text(
                                    feedItems[i].name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold
                                    )
                                  )
                                ]
                              )
                            ),
                            Row(
                              children: <Widget>[
                                buildTimeAgo(feedItems[i].created.toLocal().toString()),
                                // IconButton(
                                //   onPressed: () {

                                //   },
                                //   icon: Icon(Icons.more_horiz)
                                // )
                              ]
                            )
                          ]
                        )
                      ),
                    ]
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  feedItems[i].caption != null && feedItems[i].caption != '' ? Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: RichText(
                      softWrap: true,
                      text: new TextSpan(
                        children: <TextSpan> [
                          new TextSpan(text: feedItems[i].username+' ', style: TextStyle(fontWeight: FontWeight.bold)),
                          new TextSpan(text: feedItems[i].caption),
                        ]
                      )
                    )
                  ) : Container()
                ]
              )
            );
          },
        ),
      );
    }else {
      return new RefreshIndicator(
        color: globals.darkModeEnabled ? Colors.white : globals.userColor,
        onRefresh: refreshFeedList,
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

  @override
  Widget build(BuildContext context) {
    if(widget.widgetItem == 0){
      return new Stack(
        children: <Widget> [
          Column(
            children: <Widget>[
              upcomingAlert(),
              new Container(
                margin: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width,
                color: Colors.black45,
                child: new FlatButton(
                  padding: EdgeInsets.all(0),
                  textColor: Colors.blue,
                  child: Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                  onPressed: () async {
                    progressHUD();
                    var barberList = await getUserBarbers(context, globals.token);
                    progressHUD();
                    final selectBarberScreen = new SelectBarberScreen(clientBarbers: barberList); 
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => selectBarberScreen));
                  },
                )
              ),
              Expanded(
                child: feedList()
              )
            ],
          ),
          _progressHUD
        ]
      );
    }else if(widget.widgetItem == 1){
      return new Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
            Text(
              'Marketplace is currently unavailable.',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * .018,
                color: Colors.grey[600]
              )
            ),
          ],
        )
      );
    }else if(widget.widgetItem == 2){
      return new Container();
    }else {
      return settingsWidget(context);
    }
  }
}