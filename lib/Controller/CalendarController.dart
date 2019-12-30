import 'package:flutter/material.dart';
import '../globals.dart' as globals;

class CalendarScreen extends StatefulWidget {
  CalendarScreen({Key key}) : super (key: key);

  @override
  CalendarScreenState createState() => new CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {

  upcomingTab() {
    return Container(
      child: Text('UPCOMING APPOINTMENTS')
    );
  }

  pastTab() {
    return Container(
      child: Text('PAST APPOINTMENTS')
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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: new AppBar(
            title: new Text('Appointments'),
            bottom: TabBar(
                onTap: (index) async {
                  // if(index == 0) {
                  //   var res = await getSuggestions(context, globals.token, 1);
                  //   setState(() {
                  //     suggestedBarbers = res;
                  //     searchTabIndex = 0;
                  //   });
                  // }else {
                  //   //getSuggestions(context, globals.token, 2);
                  //   setState(() {
                  //     searchTabIndex = 1;
                  //   });
                  // }
                },
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  Tab(text: "Upcoming"),
                  Tab(text: "Past")
                ],
              )
          ),
          body: new Stack(
            children: <Widget>[
              new TabBarView(
                children: <Widget>[
                  upcomingTab(),
                  pastTab()
                ],
              ) 
            ]
          )
        )
      )
    );
  }
}