import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/helpers.dart';
import 'package:expandable/expandable.dart';
import 'package:trimmz/userAppointmentControlButtons.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'dart:convert';
import 'package:trimmz/Model/Service.dart';

class ScheduleController extends StatefulWidget {
  final Map<DateTime, List<dynamic>> calendarAppointments;
  ScheduleController({Key key, this.calendarAppointments}) : super (key: key);

  @override
  ScheduleControllerState createState() => new ScheduleControllerState();
}

class ScheduleControllerState extends State<ScheduleController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  CalendarController _calendarController = new CalendarController();
  Map<DateTime, List> _calendarAppointments;
  DateTime _calendarSelectedDay = DateTime.now();
  List _selectedAppointments = [];
  AnimationController animation;

  @override
  void initState() {
    _calendarAppointments = widget.calendarAppointments;
    _selectedAppointments = _calendarAppointments[DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())))] ?? [];

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    animation = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    super.initState();
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

  void _onDaySelected(DateTime day, List appointments, List _) {
    setState(() {
      _calendarSelectedDay = day;
      _selectedAppointments = appointments;
    });
  }

  Widget _buildMarkers(int amount) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: globals.darkModeEnabled ? richBlack : Colors.white,
        border: Border.all(color: globals.darkModeEnabled ? Colors.white : richBlack)
      ),
      width: 23.0,
      height: 23.0,
      child: Center(
        child: Text(
          '$amount',
          style: TextStyle().copyWith(
            color: globals.darkModeEnabled ? Colors.white : richBlack,
            fontSize: 13.0,
          ),
        ),
      ),
    );
  }

  buildCalendar() {
    return new TableCalendar(
      events: _calendarAppointments,
      onDaySelected: _onDaySelected,
      calendarController: _calendarController,
      initialSelectedDay: _calendarSelectedDay,
      initialCalendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      headerVisible: true,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black),
        weekendStyle: TextStyle(color: globals.darkModeEnabled ?  Color(0xFFf2f2f2) : Colors.black)
      ),
      calendarStyle: CalendarStyle(
        weekendStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
        outsideWeekendStyle: TextStyle(color: Color(0xFF9E9E9E))
      ),
      builders: CalendarBuilders(
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          int amount = events.where((element) => element['status'] != 2 && element['status'] != 3).length;

          if (events.isNotEmpty && amount > 0) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildMarkers(amount)
              ),
            );
          }
          return children;
        },
        selectedDayBuilder: (context, date, _) {
          animation.forward();
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(32, 111, 152, 0.5)
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            )
          );
        }
      )
    );
  }

  buildServicesColumn(String servicesMap) {
    List<Service> services = [];
    Map servicesJson = json.decode(servicesMap);
    servicesJson.forEach((key, value) {
      services.add(new Service(value));
    });

    Map servicesMap2 = {};
    List<Widget> _children = [];

    for(var service in services) {
      if(!servicesMap2.containsKey(service.id)) {
        servicesMap2[service.id] = [Map.from(service.toMap())];
      }else {
        servicesMap2[service.id].add(Map.from(service.toMap()));
      }
    }

    servicesMap2.forEach((appointmentId, s) {
      _children.add(
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: s[0]['name'],
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.0, 
                )
              ),
              s.length > 1 ? TextSpan(
                text: " (${s.length})",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0
                )
              ): TextSpan()
            ]
          ),
        )
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children
    );
  }

  buildCalendarList() {
    if(_selectedAppointments.length > 0) {
      return Container(
        child: new ListView.builder(
          shrinkWrap: true,
          itemCount: _selectedAppointments.length,
          itemBuilder: (context, index) {
            final startTime = new DateFormat('h:mma').format(DateTime.parse(_selectedAppointments[index]['date'])).toLowerCase();
            final endTime = new DateFormat('h:mma').format(DateTime.parse(_selectedAppointments[index]['date']).add(Duration(minutes: _selectedAppointments[index]['duration']))).toLowerCase();
            Color statusBar = getStatusBar(_selectedAppointments[index]['status'], _selectedAppointments[index]['date']);

            return Container(
              padding: EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0, right: 10.0),
              child: ExpandablePanel(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                header: IntrinsicHeight(
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: startTime,
                              style: TextStyle(
                                color: globals.darkModeEnabled ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.0
                              )
                            ),
                            TextSpan(
                              text: '\n'+endTime,
                              style: TextStyle(
                                color: textGrey,
                                fontWeight: FontWeight.normal,
                                fontSize: 12.0
                              )
                            )
                          ]
                        ),
                      ),
                      new Container(
                        width: 4.0,
                        color: statusBar,
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _selectedAppointments[index]['client_id'] == 0 ? _selectedAppointments[index]['manual_client_name'] : _selectedAppointments[index]['client_name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(1)),
                                _selectedAppointments[index]['client_id'] == 0 ? Icon(LineIcons.pencil, size: 17, color: textGrey) : Container()
                              ]
                            ),
                            buildServicesColumn(_selectedAppointments[index]['services']),
                            Row(
                              children: [
                                Icon(_selectedAppointments[index]['cash_payment'] == 1 ? LineIcons.money : Icons.credit_card, size: 18, color: Color(0xFFD4AF37))
                              ]
                            )
                          ]
                        )
                      ),
                    ],
                  ),
                ),
                expanded: UserAppointmentControlButtons(
                  appointment: Appointment(_selectedAppointments[index]),
                  controllerState: this,
                  onUpdate: (Appointment value) {
                    setState(() {
                      _selectedAppointments[index]['status'] = value.status;
                    });
                    globals.userControllerState.refreshList();
                  },
                ),
              )
            );
          },
        )
      );
    }else {
      return Container(
        padding: EdgeInsets.all(10),
        child: Text('No Appointments')
      );
    }
  }

  _buildScreen() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          buildCalendar(),
          Expanded(
            child: buildCalendarList()
          )
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Schedule",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new Stack(
                children: [
                  _buildScreen(),
                  _progressHUD,
                ]
              )
            )
          )
        )
      )
    );
  }
}