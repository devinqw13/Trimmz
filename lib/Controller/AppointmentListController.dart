import 'package:flutter/material.dart';
import 'package:trimmz/View/Widgets.dart';
import '../globals.dart' as globals;
import 'package:line_icons/line_icons.dart';
import '../Calls/GeneralCalls.dart';
import 'package:intl/intl.dart';
import '../View/BarberAppointmentOptions.dart';

class AppointmentList extends StatefulWidget {
  AppointmentList({Key key}) : super (key: key);

  @override
  AppointmentListState createState() => new AppointmentListState();
}

class AppointmentListState extends State<AppointmentList> {
  Map<DateTime, List> appointments = {};
  List past = [];
  List upcoming = [];
  List pending = [];
  final df = new DateFormat('MMM d, yyyy');

  void initState() {
    super.initState();
    initChecks();
  }

  initChecks([var apt]) async {
    var res;
    if(apt == null){
      res = await getUserAppointments(context, globals.token);
    }else {
      setState(() {
        past = [];
        upcoming = [];
        pending = [];
      });
      res = apt;
    }

    res.forEach((key, value) {
      for(var item in value) {
        if(item['status'] == 3 || (item['status'] == 0 && DateTime.now().isAfter(DateTime.parse(item['full_time'])))){
          pending.add(item);
        }else if(item['status'] == 0 && DateTime.now().isBefore(DateTime.parse(item['full_time']))) {
          upcoming.add(item);
        }else {
          past.add(item);
        }
      }
    });

    setState(() {
      appointments = res;
    });
  }

  showAppointmentDetails(var appointment) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return AppointmentOptionsBottomSheet(
        appointment: appointment,
        showCancel: (val) async {},
        updateAppointments: (value) {
          setState(() {
            appointments = value;
          });
          initChecks(value);
        }
      );
    });
  }

  buildConfirmList() {
    if(upcoming.length > 0){
      return Container(
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Text(
              'Upcoming Appointments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              )
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: upcoming.length,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                return new GestureDetector(
                  onTap: () {
                    showAppointmentDetails(upcoming[i]);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 1),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(1.0, .5),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[300], Colors.grey[100]]
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget> [
                            buildProfilePictures(context, upcoming[i]['profile_picture'], upcoming[i]['barber_name'], 25),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  upcoming[i]['barber_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(upcoming[i]['package']),
                                Text('\$'+(upcoming[i]['price'] + upcoming[i]['tip']).toString())
                              ]
                            ),
                          ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              df.format(DateTime.parse(upcoming[i]['full_time'])).toString(),
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                            Text(upcoming[i]['time']),
                            Text(
                              'Upcoming',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue
                              )
                            )
                          ]
                        )
                      ]
                    )
                  )
                );
              },
            )
          ]
        )
      );
    }else {
      return Container();
    }
  }

  buildPendingList() {
    if(pending.length > 0){
      return Container(
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Text(
              'Pending Appointments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              )
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: pending.length,
              reverse: true,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                Color statusColor;
                if(pending[i]['status'] == 0){
                  var time = pending[i]['full_time'];
                  if(DateTime.now().isAfter(DateTime.parse(time))) {
                    statusColor = Colors.grey;
                  }else {
                    statusColor = Colors.blue;
                  }
                }else if(pending[i]['status'] == 1){
                  statusColor = Colors.green;
                }else if(pending[i]['status'] == 2){
                  statusColor = Colors.red;
                }else {
                  statusColor = Colors.grey;
                }
                return new GestureDetector(
                  onTap: () {
                    showAppointmentDetails(pending[i]);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 1),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(1.0, .5),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[300], Colors.grey[100]]
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget> [
                            buildProfilePictures(context, pending[i]['profile_picture'], pending[i]['barber_name'], 25),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  pending[i]['barber_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(pending[i]['package']),
                                Text('\$'+(pending[i]['price'] + pending[i]['tip']).toString())
                              ]
                            ),
                          ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              df.format(DateTime.parse(pending[i]['full_time'])).toString(),
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                            Text(pending[i]['time']),
                            Text(
                              statusColor == Colors.grey ? 'Pending' : statusColor == Colors.blue ? 'Upcoming' : statusColor == Colors.green ? 'Completed' : 'Cancelled',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor == Colors.grey ? Colors.grey : statusColor == Colors.blue ? Colors.blue : statusColor == Colors.green ? Colors.green : Colors.red
                              )
                            )
                          ]
                        )
                      ]
                    )
                  )
                );
              },
            )
          ]
        )
      );
    }else {
      return Container();
    }
  }

  buildPastList() {
    if(past.length > 0){
      return Container(
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Text(
              'Past Appointments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              )
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: past.length,
              reverse: true,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                Color statusColor;
                if(past[i]['status'] == 0){
                  var time = past[i]['full_time'];
                  if(DateTime.now().isAfter(DateTime.parse(time))) {
                    statusColor = Colors.grey;
                  }else {
                    statusColor = Colors.blue;
                  }
                }else if(past[i]['status'] == 1){
                  statusColor = Colors.green;
                }else if(past[i]['status'] == 2){
                  statusColor = Colors.red;
                }
                return new GestureDetector(
                  onTap: () {
                    showAppointmentDetails(past[i]);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 1),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(1.0, .5),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[300], Colors.grey[100]]
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget> [
                            buildProfilePictures(context, past[i]['profile_picture'], past[i]['barber_name'], 25),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  past[i]['barber_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(past[i]['package']),
                                Text('\$'+(past[i]['price'] + past[i]['tip']).toString())
                              ]
                            ),
                          ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              df.format(DateTime.parse(past[i]['full_time'])).toString(),
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                            Text(past[i]['time']),
                            Text(
                              statusColor == Colors.grey ? 'Pending' : statusColor == Colors.blue ? 'Upcoming' : statusColor == Colors.green ? 'Completed' : 'Cancelled',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor == Colors.grey ? Colors.grey : statusColor == Colors.blue ? Colors.blue : statusColor == Colors.green ? Colors.green : Colors.red
                              )
                            )
                          ]
                        )
                      ]
                    )
                  )
                );
              },
            )
          ]
        )
      );
    }else {
      return Container();
    }
  }

  buildBody() {
    if(appointments.length > 0) {
      return new Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    buildConfirmList(),
                    buildPendingList(),
                    buildPastList()
                  ],
                ),
              )
            ),
          ]
        )
      );
    }else {
      return Container(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
                    Text(
                      'You don\'t have any appointment history',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * .018,
                        color: Colors.grey[600]
                      )
                    ),
                  ]
                )
              )
            ),
          ]
        )
      );
    }
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
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          title: new Text('Appointments'),
        ),
        body: new Stack(
          children: <Widget> [
            buildBody()
          ]
        )
      )
    );
  }
}