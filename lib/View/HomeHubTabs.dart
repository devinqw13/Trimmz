import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import '../globals.dart' as globals;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:expandable/expandable.dart';
import '../Model/FeedItems.dart';
import '../Controller/SelectBarberController.dart';
import 'package:line_icons/line_icons.dart';
import '../View/Widgets.dart';
import '../Model/Appointment.dart';
import 'package:intl/intl.dart';

class HomeHubTabWidget extends StatefulWidget{
  final int widgetItem;
  HomeHubTabWidget(this.widgetItem);

  @override
  HomeHubTabWidgetState  createState() => HomeHubTabWidgetState ();
}

class HomeHubTabWidgetState extends State<HomeHubTabWidget> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey = new GlobalKey<RefreshIndicatorState>();
  Radius cardEdgeRadius;
  List<Image> imageList = new List<Image>();
  List<FeedItem> feedItems = [];
  Appointment upcomingAppointment;

  void initState() {
    super.initState();
    initChecks();
  }

  initChecks() async {
    var res1 = await getUpcomingAppointment(context, globals.token);
    setState(() {
      upcomingAppointment = res1;
    });
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

  buildHomeFeed() {
    Orientation orientation = MediaQuery.of(context).orientation;
    double screenHeight =MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double textScale = 1.0;
    double listImageScale;

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
                "Add a barber to start viewing some cuts!",
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

  upcomingAlert() {
    if(upcomingAppointment != null){
      final df = new DateFormat('EEE, MMM d @ hh:mm a');
      String appointmentTime = df.format(DateTime.parse(upcomingAppointment.dateTime.toString()));
      return new Container(
        padding: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [
            new BoxShadow(
              color: Colors.black,
              blurRadius: 20.0
            )
          ]
        ),
        child: ExpandablePanel(
          collapsed: Container(
            padding: EdgeInsets.only(top: 10.0, left: 15.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Upcoming Appointment: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                Text(
                  appointmentTime,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            )
          ),
          expanded: Container(
            padding: EdgeInsets.only(top: 10.0, left: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Upcoming Appointment', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(appointmentTime)
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Barber: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(upcomingAppointment.barberName)
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Location: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${upcomingAppointment.locationAddress}\n${upcomingAppointment.geoAddress}')
                  ],
                )
              ],
            )
          ),
          tapHeaderToExpand: true,
          tapBodyToCollapse: true,
          hasIcon: true,
        )
      );
    }else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.widgetItem == 0){
      return new Column(
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
                var barberList = await getUserBarbers(context, globals.token);
                final selectBarberScreen = new SelectBarberScreen(clientBarbers: barberList); 
                Navigator.push(context, new MaterialPageRoute(builder: (context) => selectBarberScreen));
              },
            )
          ),
          Expanded(
            child: buildHomeFeed() 
          )
         // buildHomeFeed()
        ],
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