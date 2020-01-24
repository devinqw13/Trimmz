import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:line_icons/line_icons.dart';
import '../calls.dart';
import 'package:intl/intl.dart';
import '../View/AppointmentCancelOptions.dart';
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
      res = apt;
    }

    res.forEach((key, value) {
      for(var item in value) {
        if(item['status'] == '3' || (item['status'] == '0' && DateTime.now().isAfter(DateTime.parse(item['full_time'])))){
          pending.add(item);
        }else if(item['status'] == '0' && DateTime.now().isBefore(DateTime.parse(item['full_time']))) {
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
      //TODO: Make sure customer doesnt see appointment options to change status
      return AppointmentOptionsBottomSheet(
        appointment: appointment,
        showCancel: (val) async {
          if(val){
            showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
              return CancelOptionsBottomSheet(
                appointment: appointment,
                setAppointmentList: (value) {
                  setState(() {
                    initChecks(value);
                  });
                },
                showAppointmentDetails: (value) {
                  showAppointmentDetails(value);
                },
              );
            });
          }
        },
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
                        colors: [Colors.black, Colors.grey[900]]
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              upcoming[i]['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(upcoming[i]['package']),
                            Text('\$'+(int.parse(upcoming[i]['price']) + int.parse(upcoming[i]['tip'])).toString())
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
              shrinkWrap: true,
              itemBuilder: (context, i) {
                Color statusColor;
                if(pending[i]['status'] == '0'){
                  var time = pending[i]['full_time'];
                  if(DateTime.now().isAfter(DateTime.parse(time))) {
                    statusColor = Colors.grey;
                  }else {
                    statusColor = Colors.blue;
                  }
                }else if(pending[i]['status'] == '1'){
                  statusColor = Colors.green;
                }else if(pending[i]['status'] == '2'){
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
                        colors: [Colors.black, Colors.grey[900]]
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              pending[i]['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(pending[i]['package']),
                            Text('\$'+(int.parse(pending[i]['price']) + int.parse(pending[i]['tip'])).toString())
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
              shrinkWrap: true,
              itemBuilder: (context, i) {
                Color statusColor;
                if(past[i]['status'] == '0'){
                  var time = past[i]['full_time'];
                  if(DateTime.now().isAfter(DateTime.parse(time))) {
                    statusColor = Colors.grey;
                  }else {
                    statusColor = Colors.blue;
                  }
                }else if(past[i]['status'] == '1'){
                  statusColor = Colors.green;
                }else if(past[i]['status'] == '2'){
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
                        colors: [Colors.black, Colors.grey[900]]
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              past[i]['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ),
                            Text(past[i]['package']),
                            Text('\$'+(int.parse(past[i]['price']) + int.parse(past[i]['tip'])).toString())
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
        backgroundColor: Colors.black,
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