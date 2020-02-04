import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import '../globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:expandable/expandable.dart';
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