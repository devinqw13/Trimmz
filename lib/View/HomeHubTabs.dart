import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import '../globals.dart' as globals;
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
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          collapsed: Container(
           padding: EdgeInsets.only(left: 15.0),
            child: Row( //TODO: ADD RichTEXT
              children: <Widget>[
                Text(
                  'Upcoming Appointment: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * .017
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
            child: buildFeed(context) 
          )
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