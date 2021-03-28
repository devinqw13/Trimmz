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
import 'package:trimmz/Model/WidgetStatus.dart';
import 'dart:ui' as ui;
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/Controller/BookAppointmentController.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:trimmz/Model/Availability.dart';
import 'package:trimmz/calls.dart';

class ScheduleController extends StatefulWidget {
  final Map<DateTime, List<dynamic>> calendarAppointments;
  final List<Service> services;
  final List<Availability> availability;
  final screenHeight;
  ScheduleController({Key key, this.calendarAppointments, this.screenHeight, this.services, this.availability}) : super (key: key);

  @override
  ScheduleControllerState createState() => new ScheduleControllerState();
}

class ScheduleControllerState extends State<ScheduleController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  CalendarController _calendarController = new CalendarController();
  CalendarController _manualCalendarController = new CalendarController();
  Map<DateTime, List> _calendarAppointments;
  DateTime _calendarSelectedDay = DateTime.now();
  List _selectedAppointments = [];
  AnimationController animation, addAnimationController, opacityAnimationController;
  WidgetStatus _addWidgetStatus = WidgetStatus.HIDDEN;
  Animation addPositionAnimation, addOpacityAnimation;
  final duration = new Duration(milliseconds: 200);
  bool addActive = true;
  ManualAppointment manual = new ManualAppointment();
  List<ServiceOption> services = [];
  List<ExpandableController> servicesExpandableController = [];
  List<RadioModel> _availableTimes = new List<RadioModel>();
  Map<DateTime, List<RadioModel>> times;
  final TextEditingController clientNameTFController = new TextEditingController();
  final TextEditingController clientPhoneTFController = new TextEditingController();

  @override
  void initState() {
    _calendarAppointments = widget.calendarAppointments;
    _selectedAppointments = _calendarAppointments[DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())))] ?? [];

    for(var item in widget.services) {
      services.add(new ServiceOption(item));
      services.sort((a,b) => a.price.compareTo(b.price));
      servicesExpandableController.add(new ExpandableController());
    }

    clientNameTFController.addListener(() {
      setState(() {
        manual.clientName = clientNameTFController.text;
      });
    });

    clientPhoneTFController.addListener(() {
      setState(() {
        manual.clientPhone = clientPhoneTFController.text;
      });
    });

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

    addAnimationController = new AnimationController(duration: duration, vsync: this);
    opacityAnimationController = new AnimationController(duration: duration, vsync: this);
    addPositionAnimation = new Tween(begin: 0.0, end: widget.screenHeight).animate(
      new CurvedAnimation(parent: addAnimationController, curve: Curves.easeInOut)
    );
    addOpacityAnimation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: opacityAnimationController, curve: Curves.easeInOut)
    );
    addPositionAnimation.addListener(() {
      setState(() {});
    });
    addOpacityAnimation.addListener(() {
      setState(() {});
    });
    addAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (addActive) {
          _addWidgetStatus = WidgetStatus.VISIBLE;
        } else {
          _addWidgetStatus = WidgetStatus.HIDDEN;
        }
      }
    });

    _onManualDaySelected(DateTime.now(), null, null);
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

  void onTapDown() {
    FocusScope.of(context).unfocus();
    if (_addWidgetStatus == WidgetStatus.HIDDEN) {
      addAnimationController.forward(from: 0.0);
      opacityAnimationController.forward(from: 0.0);
      _addWidgetStatus = WidgetStatus.VISIBLE;
    }
    else if (_addWidgetStatus == WidgetStatus.VISIBLE) {
      addAnimationController.reverse(from: 400.0);
      opacityAnimationController.reverse(from: 1.0);
      _addWidgetStatus = WidgetStatus.HIDDEN;
    }
  }

  void _onDaySelected(DateTime day, List appointments, List _) {
    setState(() {
      _calendarSelectedDay = day;
      _selectedAppointments = appointments;
    });
  }

  void _onManualDaySelected(DateTime day, List _, List __) {
    DateTime daySelected = DateTime.parse(DateFormat('yyyy-MM-dd').format(day));
    DateTime currentDay = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    if(daySelected.isAfter(currentDay) || daySelected.isAtSameMomentAs(currentDay)) {
      var result = calculateAvailability(widget.availability, _calendarAppointments, day);
      setState(() {
        manual.dateTime = null;
        _availableTimes = result;
      });
    }else {
      setState(() {
        manual.dateTime = null;
        _availableTimes = [];
      });
    }
  }

  calculateAvailability(List<Availability> list, Map<DateTime, List<dynamic>> existingAppointments, DateTime day) {
    final df = new DateFormat('hh:mm a');
    var weekday = DateFormat('yyyy-MM-dd').format(day);
    List<RadioModel> timesList = [];

    for(var item in list) {
      if(DateFormat('yyyy-MM-dd').format(item.date) == weekday) {
        if(!item.closed){
          var start = DateTime.parse(DateFormat('Hms', 'en_US').parse(item.start).toString());
          var end = DateTime.parse(DateFormat('Hms', 'en_US').parse(item.end).toString());
          var startDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(day.toString()));
          var startTime = DateFormat('Hms').format(DateTime.parse(start.toString()));
          var newStart = DateTime.parse(startDate + ' ' + startTime);
          var newTime = newStart;

          if(existingAppointments.containsKey(DateTime.parse(DateFormat('yyyy-MM-dd').format(day)))) {
            existingAppointments.forEach((key, value){
              if(DateFormat('yyyy-MM-dd').format(key) == DateFormat('yyyy-MM-dd').format(day)) {
                Map<String, String> appointmentTimes = {};
                for(var appointment in value) {
                  var amPMTimeFormat = DateFormat('hh:mm a').format(DateTime.parse(appointment['date']));
                  var time = DateFormat('Hms').format(DateTime.parse(DateFormat('hh:mm a', 'en_US').parse(amPMTimeFormat).toString()));
                  appointmentTimes[time] = appointment['duration'].toString();
                }

                // if(!appointmentTimes.containsKey(DateFormat('Hms').format(newTime).toString())) {
                //   if(newTime.isAfter(DateTime.now())){
                //     timesList.add(new RadioModel(false, df.format(DateTime.parse(newTime.toString()))));
                //   }
                // }

                int iterate = end.difference(start).inMinutes - 15;
                DateTime startingTime = newTime;

                for (int i = 0; i <= end.difference(start).inMinutes; i+=15) {
                  if(newTime.isAfter(DateTime.now()) && newTime.isBefore(startingTime.add(Duration(minutes: iterate)))){
                    if(appointmentTimes.containsKey(DateFormat('Hms').format(newTime).toString())) {
                      appointmentTimes.forEach((k,v){
                        if(k == DateFormat('Hms').format(newTime).toString()) {
                          timesList.removeWhere((element) => element.buttonText == df.format(DateTime.parse(newTime.toString())));
                          newTime = newTime.add(Duration(minutes: int.parse(v)));
                        }
                      });
                    }else {
                      bool shouldAdd = true;
                      DateTime mmm;
                      int val;

                      appointmentTimes.forEach((k, v){
                        var eDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(newTime.toString()));
                        DateTime eTime = DateTime.parse(eDate + ' ' + k);

                        if(newTime.add(Duration(minutes: manual.duration)).isAfter(eTime) && newTime.add(Duration(minutes: manual.duration)).isBefore(eTime.add(Duration(minutes: int.parse(v))))) {
                          shouldAdd = false;
                          mmm = eTime;
                          val = int.parse(v);
                        }
                      });

                      if(shouldAdd) {
                        var convertTime = df.format(DateTime.parse(newTime.toString()));
                        timesList.add(new RadioModel(false, convertTime));
                        newTime = newTime.add(Duration(minutes: 15));
                      }else {
                        newTime = mmm.add(Duration(minutes: val));
                      }
                    }
                  }else {
                    newTime = newTime.add(Duration(minutes: 15));
                  }
                }
              }
            });
          }else {
            if(newTime.isAfter(DateTime.now())){
              timesList.add(new RadioModel(false, df.format(DateTime.parse(newTime.toString()))));
            }

            for (int i = 0; i <= end.difference(start.add(Duration(minutes: 45))).inMinutes; i+=15) {
              newTime = newTime.add(Duration(minutes: 15));
              if(newTime.isAfter(DateTime.now())){
                var convertTime = df.format(DateTime.parse(newTime.toString()));
                timesList.add(new RadioModel(false, convertTime));
              }
            }
          }
          return timesList;    
        }else {
          return timesList = [];
        }
      }
    }
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
                      Expanded(
                        flex: 1,
                        child: RichText(
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
                        )
                      ),
                      new Container(
                        width: 4.0,
                        color: statusBar,
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      Expanded(
                        flex: 4,
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

  Widget _buildClientNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Client Name',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color.fromARGB(110, 0, 0, 0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: clientNameTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
              hintText: 'Enter client\'s name',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientPhoneTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Client Phone',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color.fromARGB(110, 0, 0, 0),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: clientPhoneTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
              hintText: 'Enter client\'s phone',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildClientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CLIENT INFORMATION",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Column(
            children: [
              _buildClientNameTF(),
              _buildClientPhoneTF()
            ]
          )
        )
      ]
    );
  }

  void selectService(ServiceOption service, int index) {
    setState(() {
      service.selected = !service.selected;
      servicesExpandableController[index].expanded = !servicesExpandableController[index].expanded;

      if(service.selected) {
        manual.services.add(service.service.toMap());
        manual.subTotal += double.parse(service.price.toString());
        manual.duration += service.duration;
      }else {
        var osList = manual.services.where((e) => e['id'] == service.serviceId);
        for(var i=0; i < osList.length; i++) {
          manual.subTotal -= double.parse(service.price.toString());
          manual.duration -= service.duration;
        }

        manual.services.removeWhere((e) => e['id'] == service.serviceId);
      }
    });
    _onManualDaySelected(_manualCalendarController.selectedDay, null, null);
  }

  _buildServiceSubtractButton(int quantity, ServiceOption service) {
    return Container(
      height: 17.0,
      child: RawMaterialButton(
        constraints: BoxConstraints(
          minWidth: 20
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Text(
          "-",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: quantity == 1 ? Colors.grey : Colors.blue
          )
        ),
        shape: CircleBorder(side: BorderSide(color: quantity == 1 ? Colors.grey : Colors.blue)),
        onPressed: quantity == 1 ? null : () {
          FocusScope.of(context).unfocus();
          setState(() {
            manual.services.removeAt(
              manual.services.lastIndexWhere((e) => e['id'] == service.serviceId)
            );
            manual.duration -= service.duration;
            manual.subTotal -= double.parse(service.price.toString());
          });
          _onManualDaySelected(_manualCalendarController.selectedDay, null, null);
        },
      )
    );
  }

  _buildServiceAddButton(int quantity, ServiceOption service) {
    return Container(
      height: 17.0,
      child: RawMaterialButton(
        constraints: BoxConstraints(
          minWidth: 20
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Center(
            child: Text(
            "+",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blue
            ),
          )
        ),
        shape: CircleBorder(side: BorderSide(color: Colors.blue)),
        onPressed: () {
          FocusScope.of(context).unfocus();
          setState(() {
            manual.services.add(service.service.toMap());
            manual.subTotal += double.parse(service.price.toString());
            manual.duration += service.duration;
          });
          _onManualDaySelected(_manualCalendarController.selectedDay, null, null);
        },
      )
    );
  }

  _buildServiceItem(ServiceOption service, int index) {
    return ExpandablePanel(
      controller: servicesExpandableController[index],
      tapHeaderToExpand: false,
      tapBodyToCollapse: false,
      hasIcon: false,
      header: GestureDetector(
        onTap: () => selectService(service, index),
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Expanded(
                child: Row(
                  children: [
                    new CircularCheckBox(
                      activeColor: Colors.blue,
                      value: service.selected,
                      onChanged: (bool value) => selectService(service, index)
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.serviceName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            "${service.duration} Minutes",
                            style: TextStyle(
                              color: Colors.grey
                            )
                          )
                        ]
                      )
                    )
                  ]
                )
              ),
              Text(
                "\$${service.price}",
                style: TextStyle(
                  fontWeight: FontWeight.w600
                )
              )
            ]
          )
        )
      ),
      expanded: Container(
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(manual.services.where((e) => e['id'] == service.serviceId).length.toString())
            ),
            Padding(padding: EdgeInsets.all(10)),
            _buildServiceSubtractButton(manual.services.where((e) => e['id'] == service.serviceId).length, service),
            Padding(padding: EdgeInsets.all(10)),
            _buildServiceAddButton(manual.services.where((e) => e['id'] == service.serviceId).length, service)
          ],
        ),
      ),
    );
  }

  _buildServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT SERVICES",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0.0),
            itemCount: services.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _buildServiceItem(services[index], index);
            },
          )
        )
      ]
    );
  }

  _buildCalendar() {
    return TableCalendar(
      locale: 'en_US',
      events: times,
      onDaySelected: _onManualDaySelected,
      availableGestures: AvailableGestures.horizontalSwipe,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black),
        weekendStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black)
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        centerHeaderTitle: true
      ),
      calendarStyle: CalendarStyle(
        weekendStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
        outsideWeekendStyle: TextStyle(color: Color(0xFF9E9E9E))
      ),
      headerVisible: true,
      calendarController: _manualCalendarController,
      initialCalendarFormat: CalendarFormat.week,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[500]
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0),
                ),
              )
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[350]
              ),
              child: Center(
                child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
              )
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          return children;
        }
      ),
    );
  }

  _buildTimeList() {
    if(_availableTimes != null && _availableTimes.length > 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: new ListView.builder(
          itemCount: _availableTimes.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            return Container(
              child: new GestureDetector(
                onTap: () {
                  var date = DateFormat('yyyy-MM-dd').format(DateTime.parse(_manualCalendarController.selectedDay.toString()));
                  var time = DateFormat('HH:mm:ss').format(DateFormat('hh:mm a').parse(_availableTimes[i].buttonText));
                  setState(() {
                    _availableTimes.forEach((element) => element.isSelected = false);
                    _availableTimes[i].isSelected = true;
                    manual.dateTime = DateTime.parse(date + ' ' + time);
                  });
                },
                child: new RadioItem(_availableTimes[i]),
              )
            );
          }
        )
      );
    }else {
      return Container(
        padding: EdgeInsets.all(10),
        child: Center(child: Text('No Available Times'))
      );
    }
  }

  _buildSelectDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT DATE & TIME",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Column(
            children: [
              _buildCalendar(),
              Divider(),
              _buildTimeList()
            ]
          )
        )
      ],
    );
  }

  _handleBookAppointment() async {
    onTapDown();

    Map<dynamic, dynamic> manualUser = {
      "name": manual.clientName,
      "phone": manual.clientPhone
    };

    progressHUD();
    var result = await bookAppointment(
      context,
      0, // client token
      globals.user.token, // user token
      manual.subTotal,
      manual.tip,
      manual.processingFee,
      manual.services,
      manual.dateTime,
      manual: manualUser
    );
    progressHUD();

    final df = new DateFormat('yyyy-MM-dd');
    var dateString = result.map['date'];
    DateTime date = DateTime.parse(df.format(DateTime.parse(dateString)));

    if(!_calendarAppointments.containsKey(date)) {
      setState(() {
        _calendarAppointments[date] = [Map.from(result.map)];
      });
    }else {
      setState(() {
        _calendarAppointments[date].add(Map.from(result.map));
      });
    }

    var a = _calendarAppointments[DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(_calendarSelectedDay.toString())))] ?? [];

    _onDaySelected(_calendarSelectedDay, a, null);

    manual = new ManualAppointment();
    clientPhoneTFController.clear();
    clientNameTFController.clear();
    _onManualDaySelected(DateTime.now(), null, null);
    servicesExpandableController.forEach((element) {
      setState(() {
        element.expanded = false;
      });
    });
    services.forEach((element) {
      setState(() {
        element.selected = false;
      });
    });
  }

  buildAddAppointmentManual() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.all(8.0)),
                  _buildClientInfo(),
                  Padding(padding: EdgeInsets.all(8.0)),
                  _buildServices(),
                  Padding(padding: EdgeInsets.all(8.0)),
                  _buildSelectDateTime(),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(8)),
          !manual.containsNulls() ?
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    border: Border.all(
                      color: CustomColors1.mystic.withAlpha(100)
                    )
                  ),
                  child: RippleButton(
                    splashColor: CustomColors1.mystic.withAlpha(100),
                    onPressed: () async {
                      _handleBookAppointment();
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: Center(
                        child: Text(
                          "Book Appointment",
                          style: TextStyle(
                            color: Colors.white
                          )
                        ),
                      )
                    )
                  )
                ),
              )
            ]
          ): Container()
        ]
      )
    );
  }

  Widget getAddAppointmentOverlay() {
    var searchHeight = 0.0;
    var searchOpacity = 0.0;
    switch(_addWidgetStatus) {
      case WidgetStatus.HIDDEN:
        searchHeight = addPositionAnimation.value;
        searchOpacity = addOpacityAnimation.value;
        addActive = false;
        break;
      case WidgetStatus.VISIBLE:
        searchHeight = addPositionAnimation.value;
        searchOpacity = addOpacityAnimation.value;
        addActive = true;
        break;
    }
    return new BackdropFilter(
      filter: new ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Container(
        padding: EdgeInsets.only(bottom: 25, left: 10, right: 10),
        width: MediaQuery.of(context).size.width,
        height: searchHeight,
        child: new Opacity(
          opacity: searchOpacity,
          child: buildAddAppointmentManual(),
          // child: Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     Expanded(
          //       child: buildAddAppointmentManual()
          //     ),
          //   ],
          // )
        ),
        color: const Color.fromARGB(120, 0, 0, 0),
      )
    );
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
          actions: [
            _addWidgetStatus != WidgetStatus.VISIBLE ? IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: Icon(Icons.add),
              onPressed: () {
                onTapDown();
              },
            ):
            FlatButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onPressed: () {
                onTapDown();
              },
              child: Text("Cancel")
            )
          ],
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
                  getAddAppointmentOverlay(),
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

class ManualAppointment {
  String clientName;
  String clientPhone;
  List<Map> services = [];
  double subTotal = 0;
  double tip = 0;
  double processingFee = globals.processingFee;
  int duration = 0;
  DateTime dateTime;

  bool containsNulls() {
    if(
      (clientName == null || clientName == "") ||
      services.length == 0 ||
      subTotal == null ||
      dateTime == null) {
        return true;
      }else {
        return false;
      }
  }
}