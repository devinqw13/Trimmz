import 'package:flutter/material.dart';
import '../globals.dart' as globals;

class AppointmentList extends StatefulWidget {
  AppointmentList({Key key}) : super (key: key);

  @override
  AppointmentListState createState() => new AppointmentListState();
}

class AppointmentListState extends State<AppointmentList> {


  

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: new AppBar(
            title: new Text('Appointments'),
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(text: "Upcoming"),
                Tab(text: "Past")
              ],
            ),
          ),
          body: new Stack(
            children: <Widget> [
              new TabBarView(
                children: <Widget>[
                  
                ],
              )
            ]
          )
        )
      )
    );
  }
}