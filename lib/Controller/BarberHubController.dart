import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/Model/AppointmentRequests.dart';
import 'package:trimmz/Model/availability.dart';
import '../Model/SuggestedBarbers.dart';
import '../globals.dart' as globals;
import '../View/BarberHubTabs.dart';
import 'package:line_icons/line_icons.dart';
import 'NotificationController.dart';
import 'package:badges/badges.dart';
import '../calls.dart';
import 'package:flushbar/flushbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'SelectBarberController.dart';
import '../Model/Packages.dart';
import 'package:intl/intl.dart';
import '../View/ModalSheets.dart';
import '../Model/availability.dart';
import '../View/SetAvailabilityModal.dart';
import 'BarberProfileV2Controller.dart';
import '../Model/ClientBarbers.dart';
import '../functions.dart';
import '../View/FullPackagesListModalSheet.dart';
import '../View/BarberAppointmentOptions.dart';
import '../View/Widgets.dart';
import '../View/FullCalendarModal.dart';
import '../View/AppointmentCancelOptions.dart';
import 'MarketplaceCartController.dart';
import '../View/PackageOptionsModal.dart';
import '../Model/BarberPolicies.dart';
import '../View/BarberPoliciesModal.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';

class BarberHubScreen extends StatefulWidget {
  BarberHubScreen({Key key}) : super (key: key);

  @override
  BarberHubScreenState createState() => new BarberHubScreenState();
}

class BarberHubScreenState extends State<BarberHubScreen> with TickerProviderStateMixin {
  final TextEditingController _search = new TextEditingController();
  StreamController<String> searchStreamController = StreamController();
  FocusNode _searchFocus = new FocusNode();
  int _currentIndex = 0;
  String _tabTitle = 'Home';
  List<Widget> _children = [
    BarberHubTabWidget(0),
    BarberHubTabWidget(1),
    BarberHubTabWidget(2),
    BarberHubTabWidget(3)
  ];
  int badgeCart = 0;
  int badgeNotifications = 0;
  List<SuggestedBarbers> suggestedBarbers = [];
  List<SuggestedBarbers> searchedBarbers = [];
  bool isSearching = false;
  int searchTabIndex = 0;
  CalendarController _calendarController;
  List<Packages> packages = [];
  List<Availability> availability = [];
  BarberPolicies policies;
  AnimationController _animationController;
  Map<DateTime, List> _events;
  List _selectedEvents = [];
  final df = new DateFormat('MM/dd/yyyy hh:mm a');
  final df2 = new DateFormat('yyyy-MM-dd');
  Colors status;
  List<AppointmentRequest> appointmentReq = [];
  DateTime _calendarSelectDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();

    searchStreamController.stream
    .debounce(Duration(milliseconds: 500))
    .listen((s) => _searchValue(s, searchTabIndex));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    initSuggestedBarbers();
    initBarberInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  _searchValue(String string, int type) async {
    if(type == 0) {
      if(_search.text.length > 2) {
        var res = await getSearchUsers(context, _search.text);
        setState(() {
          searchedBarbers = res;
          isSearching = true;
        });
      }
      if(_search.text.length <= 2) {
        setState(() {
          isSearching = false;
        });
      }
    }else {

    }
  }

  void initSuggestedBarbers() async {
    var res2 = await getCurrentLocation();
    setState(() {
      globals.currentLocation = res2;
    });
    var res1 = await getUserLocation();
    var res = await getSuggestions(context, globals.token, 1, res1);
    setState(() {
      suggestedBarbers = res;
    });
  }

  initBarberInfo() async {
    var res = await getBarberPkgs(context, globals.token);
    setState(() {
      packages = res;
    });

    final _selectedDay = DateTime.parse(df2.format(DateTime.parse(DateTime.now().toString())));
    var res1 = await getBarberAppointments(context, globals.token);
    setState(() {
      _events = res1;
      _selectedEvents = _events[_selectedDay] ?? [];
    });

    var res2 = await getBarberAvailability(context, globals.token);
    setState(() {
      availability = res2;
    });

    var res3 = await getBarberAppointmentRequests(context, globals.token);
    setState(() {
      appointmentReq = res3;
    });
    //TODO: FINISH THIS CALL
    // var res4 = await getBarberPolicies(context, globals.token);
    // setState(() {
    //   policies = res4;
    // });
  }

  void onNavTapTapped(int index) {
   setState(() {
     _currentIndex = index;
     if(_currentIndex == 0){
       _tabTitle = 'Home';
     }else if(_currentIndex == 1){
       _tabTitle = 'Marketplace';
     }else if(_currentIndex == 2){
       _tabTitle = 'Search';
     }else if(_currentIndex == 3){
       _tabTitle = 'Settings';
     }
   });
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.blue[700]
      ),
      width: 20.0,
      height: 20.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 13.0,
          ),
        ),
      ),
    );
  }

  showAppointmentOptions(var appointment) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return AppointmentOptionsBottomSheet(
        appointment: appointment,
        showCancel: (val) async {
          if(val){
            showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
              return CancelOptionsBottomSheet(
                appointment: appointment,
                setAppointmentList: (value) {
                  DateTime date = DateTime.parse(df2.format(DateTime.parse(_calendarSelectDay.toString())));
                  setState(() {
                    _events = value;
                    _selectedEvents = _events[date];
                  });
                },
                showAppointmentDetails: (value) {
                  showAppointmentOptions(value);
                },
              );
            });
          }
        },
      );
    });
  }

  buildAppointmentList() {
    if(_selectedEvents.length > 0) {
      return Container(
        height: _selectedEvents.length > 3 ? 300 : null,
        child: new ListView.builder(
          physics: _selectedEvents.length > 3 ? null : NeverScrollableScrollPhysics(),
          shrinkWrap: _selectedEvents.length > 3 ? false : true,
          itemCount: _selectedEvents.length * 2,
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return new Divider();
            }else {
              final i = index ~/ 2;
              Color statusColor;
              if(_selectedEvents[i]['status'] == '0'){
                var time = _selectedEvents[i]['full_time'];
                if(DateTime.now().isAfter(DateTime.parse(time))) {
                  statusColor = Colors.grey;
                }else {
                  statusColor = Colors.blue;
                }
              }else if(_selectedEvents[i]['status'] == '1'){
                statusColor = Colors.green;
              }else if(_selectedEvents[i]['status'] == '2'){
                statusColor = Colors.red;
              }
              return GestureDetector(
                onTap: () {
                  showAppointmentOptions(_selectedEvents[i]);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: <Widget>[
                      new Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple,
                          gradient: new LinearGradient(
                            colors: [Color(0xFFF9F295), Color(0xFFB88A44)],
                          )
                        ),
                        child: Center(child: Text(_selectedEvents[i]['name'].substring(0,1), style: TextStyle(fontSize: 20)))
                      ),
                      Padding(padding: EdgeInsets.all(5)),
                      Container(
                        width: MediaQuery.of(context).size.width * .8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(_selectedEvents[i]['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                    Padding(padding: EdgeInsets.all(5)),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 1, top: 1, right: 6, left: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                      child: Text(
                                        statusColor == Colors.grey ? 'Pending' : statusColor == Colors.blue ? 'Upcoming' : statusColor == Colors.green ? 'Completed' : 'Cancelled',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        )
                                      )
                                    )
                                  ]
                                ),
                                Text(_selectedEvents[i]['package']),
                                Text('\$' + _selectedEvents[i]['price']),
                              ]
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                              child: Text(_selectedEvents[i]['time'], style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500))
                            )
                          ]
                        )
                      )
                    ]
                  )
                )
              );
            }
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

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _calendarSelectDay = day;
      _selectedEvents = events;
    });
  }

  showSetAvailableTime(BuildContext context, Availability aDay) async {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      bool isClosedChecked;
      if(aDay.start == null && aDay.end == null){
        isClosedChecked = true;
      }else {
        if(aDay.start == '00:00:00' && aDay.end == '00:00:00'){
          isClosedChecked = true;
        }else {
          isClosedChecked = false;
        }
      }
      return AvailabilityBottomSheet(
        switchValue: isClosedChecked,
        avail: aDay,
        valueChanged: (value) {
          setState(() {
            isClosedChecked = value;
          });
        },
        getAvailability: (avail) {
          setState(() {
            availability = avail;
          });
        },
      );
    });
  }

  barberDBAvailability(BuildContext context) {
    return new Column(
      children: <Widget>[
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: availability.length,
          itemBuilder: (context, i){
            final todayDay = DateFormat.EEEE().format(DateTime.now());
            bool isNull = false;
            String start;
            String end;
            final df = new DateFormat('hh:mm a');
            if(availability[i].start != null && availability[i].end != null) {
              if(availability[i].start == '00:00:00' && availability[i].end == '00:00:00') {
                isNull = true;
              }else {
                start = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].start).toString()));
                end = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].end).toString()));
              }
            }else {
              isNull = true;
            }
            return Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      todayDay == availability[i].day ? Container(height: 5.0, width: 5.0, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),) : Container(height: 5.0, width: 5.0),
                      Padding(padding: EdgeInsets.all(5.0),),
                      Text(availability[i].day, style: TextStyle(fontSize: 18.0)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showSetAvailableTime(context, availability[i]);
                        },
                        child: Text(
                          isNull ? 'Closed' : start + " to " + end,
                          style: TextStyle(
                            fontSize: 17.0
                          ),
                        )
                      ),
                    ],
                  )
                ],
              )
            );
          },
        )
      ],
    );
  }

  barberPolicies() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(LineIcons.times, color: Colors.blue),
            Padding(padding: EdgeInsets.all(5)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Cancellation Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                Text('Fee Amount: 50%'),
                Text('Within: 1 Hour')
              ]
            )
          ]
        ),
        Divider(
          color: Colors.grey
        ),
        Row(
          children: <Widget>[
            Icon(LineIcons.minus, color: Colors.blue),
            Padding(padding: EdgeInsets.all(5)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No-Show Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                Text('Fee Amount: 100%'),
              ]
            )
          ]
        ),
      ]
    );
  }

  showFullPackageList(var packagesList) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return FullPackagesBottomSheet(
        packages: packagesList,
        showPackageOptions: (value) {
          if(value != null){
            showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
              return PackageOptionsBottomSheet(
                package: value,
                updatePackages: (value) {
                  setState(() {
                    packages = value;
                  });
                  showFullCalendar();
                },
                showPackagesList: (value) {
                  if(value){
                    showFullPackageList(packages);
                  }
                }
              );
            });
          }
        },
      );
    });
  }

  showFullCalendarAptOptions(var appointment) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return AppointmentOptionsBottomSheet(
        appointment: appointment,
        showCancel: (val) async {
          if(val){
            showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
              return CancelOptionsBottomSheet(
                appointment: appointment,
                setAppointmentList: (value) {
                  setState(() {
                    _events = value;
                  });
                },
                showAppointmentDetails: (value) {
                  showFullCalendarAptOptions(value);
                },
              );
            });
          }
        },
        showFull: true,
        showFullCalendar: (value) {
          showFullCalendar(value);
        }
      );
    });
  }

  showFullCalendar([DateTime selectDate]) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return FullCalendarModal(
        appointments: _events,
        selectDate: selectDate,
        showAppointmentOptions: (value) {
          showFullCalendarAptOptions(value);
        },
      );
    });
  }

  Widget dashboardTab() {
    return Container(
      child: SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            appointmentReq.length > 0 ? 
            GestureDetector(
              onTap: () async {
                var res = await showAptRequestsModalSheet(context, appointmentReq);
                if(res == 1) {
                  var res = await getBarberAppointmentRequests(context, globals.token);
                  setState(() {
                    appointmentReq = res;
                  });
                  var res2 = await getBarberAppointments(context, globals.token);
                  setState(() {
                    _events = res2;
                  });
                }else {
                  var res = await getBarberAppointmentRequests(context, globals.token);
                  setState(() {
                    appointmentReq = res;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.only(left: 5, right: 20, bottom: 5, top: 5),
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                    begin: Alignment(0.0, -2.0),
                    colors: [Colors.black, Colors.grey[900]]
                  )
                ),
                margin: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Appointment Requests', style: TextStyle(fontWeight: FontWeight.w400)),
                    Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[900],
                      ),
                      child: Center(child:Text(appointmentReq.length.toString(), textAlign: TextAlign.center))
                    )
                  ],
                )
              )
            ): Container(),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: Alignment(0.0, -2.0),
                  colors: [Colors.black, Colors.grey[900]]
                )
              ),
              margin: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget> [
                  Stack(
                    children: <Widget> [
                      TableCalendar(
                        locale: 'en_US',
                        events: _events,
                        onDaySelected: _onDaySelected,
                        initialSelectedDay: _calendarSelectDay,
                        availableGestures: AvailableGestures.horizontalSwipe,
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: const TextStyle(color: const Color(0xFFf2f2f2)),
                          weekendStyle: const TextStyle(color: const Color(0xFFf2f2f2))
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.blue),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.blue)
                        ),
                        calendarStyle: CalendarStyle(
                          weekendStyle: const TextStyle(color: Colors.white),
                          outsideWeekendStyle: TextStyle(color: Color(0xFF9E9E9E))
                        ),
                        headerVisible: true,
                        calendarController: _calendarController,
                        initialCalendarFormat: CalendarFormat.week,
                        builders: CalendarBuilders(
                          selectedDayBuilder: (context, date, _) {
                            return FadeTransition(
                              opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
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
                              opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                              child: Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[800]
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

                            if (events.isNotEmpty) {
                              children.add(
                                Positioned(
                                  right: 1,
                                  bottom: 1,
                                  child: _buildEventsMarker(date, events),
                                ),
                              );
                            }
                            return children;
                          },
                        ),
                      ),
                      Positioned(
                        right: MediaQuery.of(context).size.width * .15,
                        top: MediaQuery.of(context).size.width * .043,
                        child: GestureDetector(
                          onTap: () {
                            showFullCalendar();
                          },
                          child: Icon(Icons.menu, color: Colors.blue)
                        )
                      ),
                    ]
                  ),
                  buildAppointmentList()
                ]
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: Alignment(0.0, -2.0),
                  colors: [Colors.black, Colors.grey[900]]
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Packages',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(2),),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            padding: EdgeInsets.all(5),
                            child: Center(child: Text(packages.length.toString(), textAlign: TextAlign.center)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[800]
                            ),
                          )
                        ]
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 5, right: 10.0),
                            child: GestureDetector(
                              onTap: () async {
                                showFullPackageList(packages);
                              },
                              child: Icon(Icons.menu, color: Colors.blue)
                            )
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 5, right: 10.0),
                            child: GestureDetector(
                              onTap: () async {
                                var res = await showAddPackageModalSheet(context);
                                if(res != null) {
                                  setState(() {
                                    packages = res;
                                  });
                                }else {
                                  return;
                                }
                              },
                              child: Icon(LineIcons.plus, color: Colors.blue)
                            )
                          )
                        ]
                      )
                    ],
                  ),
                  packages.length == 0 ?
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        'You don\'t have any packages',
                        style: TextStyle(
                          fontSize: 17.0
                        )
                      )
                    )
                  ): Container(
                    child: ListView.builder(
                      reverse: true,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: packages.length > 3 ? 5 * 1 : packages.length * 2,
                      padding: const EdgeInsets.all(5.0),
                      itemBuilder: (context, index) {
                        if (index.isOdd) {
                          return new Divider();
                        }
                        else {
                          final i = index ~/ 2;
                          return new ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget> [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget> [
                                    Text(packages[i].name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500
                                      )
                                    ),
                                    Text(packages[i].duration + (int.parse(packages[i].duration) > 1 ? ' Mins' : ' Min'),
                                      style: TextStyle(
                                        color: Colors.grey
                                      )
                                    )
                                  ]
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      child: Text('\$' + packages[i].price, style: TextStyle(fontSize: 17.0)),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        shape: BoxShape.circle
                                      ),
                                    )
                                  ],
                                )
                              ]
                            )
                          );
                        }
                      }
                    )
                  )
                ],
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: Alignment(0.0, -2.0),
                  colors: [Colors.black, Colors.grey[900]]
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget> [
                      Text(
                        'Policies',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                        )
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5, right: 10.0),
                        child: GestureDetector(
                          onTap: () async {
                            showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                              return BarberPoliciesModal(
                                policies: policies
                              );
                            });
                          },
                          child: Icon(LineIcons.pencil, color: Colors.blue)
                        )
                      ),
                    ]
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10.0, right: 20.0),
                    child: barberPolicies()
                  )
                ],
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: Alignment(0.0, -2.0),
                  colors: [Colors.black, Colors.grey[900]]
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10.0, right: 20.0),
                    child: barberDBAvailability(context)
                  )
                ],
              )
            )
          ]
        )
      )
    );
  }

  Widget feedTab() {
    return new Container(
      child: Column(
        children: <Widget>[
          new Container(
            margin: EdgeInsets.all(5),
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
        ]
      )
    );
  }

  barberTab() {
    if(isSearching){
      return searchBarbers();
    }else {
      return suggestBarbers();
    }
  }

  Widget searchBarbers() {
    if(searchedBarbers.length > 0){
      return Scrollbar(
        child: new ListView.builder(
          itemCount: searchedBarbers.length * 2,
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return new Divider();
            }
            else {
              final i = index ~/ 2;
              return new GestureDetector(
                onTap: () {
                  ClientBarbers barber = new ClientBarbers();
                  barber.id = searchedBarbers[i].id;
                  barber.name = searchedBarbers[i].name;
                  barber.username = searchedBarbers[i].username;
                  barber.phone = searchedBarbers[i].phone;
                  barber.email = searchedBarbers[i].email;
                  barber.rating = searchedBarbers[i].rating;
                  barber.shopAddress = searchedBarbers[i].shopAddress;
                  barber.shopName = searchedBarbers[i].shopName;
                  barber.city = searchedBarbers[i].city;
                  barber.state = searchedBarbers[i].state;
                  barber.zipcode = searchedBarbers[i].zipcode;
                  // barber.created = suggestedBarbers[i].created;
                  final profileScreen = new BarberProfileV2Screen(token: globals.token, userInfo: barber);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));
                },
                child: Column(
                  children: <Widget> [ 
                    Container(
                      color: Colors.black87,
                      child: ListTile(
                        leading: new Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple,
                            gradient: new LinearGradient(
                              colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                            )
                          ),
                          child: Center(child:Text(searchedBarbers[i].name.substring(0,1), style: TextStyle(fontSize: 20),))
                        ),
                        subtitle: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            searchedBarbers[i].shopName != null ?
                            Text(
                              searchedBarbers[i].shopName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ) : Container(),
                            Text(searchedBarbers[i].shopAddress + ', ' + searchedBarbers[i].city+', '+searchedBarbers[i].state),
                            returnDistanceFutureBuilder('${searchedBarbers[i].shopAddress}, ${searchedBarbers[i].city}, ${searchedBarbers[i].state} ${searchedBarbers[i].zipcode}', Colors.grey),
                            getRatingWidget(context, double.parse(searchedBarbers[i].rating)),
                          ],
                        ),
                        title: new Row(
                          children: <Widget> [
                            Flexible(
                              child: Container(
                                child: Row(
                                  children: <Widget> [
                                    Container(
                                      constraints: BoxConstraints(maxWidth: 200),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              searchedBarbers[i].name+' '
                                            ),
                                            Text(
                                              '@'+searchedBarbers[i].username,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                              )
                                            )
                                          ]
                                        )
                                      ),
                                    ),
                                  ]
                                )
                              )
                            ),
                          ]
                        ),
                        trailing: !searchedBarbers[i].hasAdded ? IconButton(
                          onPressed: () async {
                            bool res = await addBarber(context, globals.token, int.parse(searchedBarbers[i].id));
                            if(res) {
                              Flushbar(
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                title: "Barber Added",
                                message: "You can now book an appointment with this barber",
                                duration: Duration(seconds: 2),
                              )..show(context);
                              setState(() {
                                searchedBarbers[i].hasAdded = true;
                              });
                            }
                          },
                          color: Colors.green,
                          icon: Icon(LineIcons.plus),
                        ) : 
                        IconButton(
                          onPressed: () async {
                            bool res = await removeBarber(context, globals.token, int.parse(searchedBarbers[i].id));
                            if(res) {
                              Flushbar(
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                title: "Barber Removed",
                                message: "This babrber has been removed from your list",
                                duration: Duration(seconds: 2),
                              )..show(context);
                              setState(() {
                                searchedBarbers[i].hasAdded = false;
                              });
                            }
                          },
                          color: Colors.red,
                          icon: Icon(LineIcons.minus),
                        ),
                      )
                    ),
                  ]
                )
              );
            }
          },
        ),
      );
    }else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          )
        ],
      );
    }
  }

  Widget suggestBarbers() {
    if(suggestedBarbers.length > 0){
      return Scrollbar(
        child: new ListView.builder(
          itemCount: suggestedBarbers.length * 2,
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return new Divider();
            }
            else {
              final i = index ~/ 2;
              return new GestureDetector(
                onTap: () {
                  ClientBarbers barber = new ClientBarbers();
                  barber.id = suggestedBarbers[i].id;
                  barber.name = suggestedBarbers[i].name;
                  barber.username = suggestedBarbers[i].username;
                  barber.phone = suggestedBarbers[i].phone;
                  barber.email = suggestedBarbers[i].email;
                  barber.rating = suggestedBarbers[i].rating;
                  barber.shopAddress = suggestedBarbers[i].shopAddress;
                  barber.shopName = suggestedBarbers[i].shopName;
                  barber.city = suggestedBarbers[i].city;
                  barber.state = suggestedBarbers[i].state;
                  barber.zipcode = suggestedBarbers[i].zipcode;
                  // barber.created = suggestedBarbers[i].created;
                  final profileScreen = new BarberProfileV2Screen(token: globals.token, userInfo: barber);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));
                },
                child: Column(
                  children: <Widget> [ 
                    Container(
                      color: Colors.black87,
                      child: ListTile(
                        leading: new Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple,
                            gradient: new LinearGradient(
                              colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                            )
                          ),
                          child: Center(child:Text(suggestedBarbers[i].name.substring(0,1), style: TextStyle(fontSize: 20),))
                        ),
                        subtitle: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            suggestedBarbers[i].shopName != null ?
                            Text(
                              suggestedBarbers[i].shopName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              )
                            ) : Container(),
                            Text(suggestedBarbers[i].shopAddress + ', ' + suggestedBarbers[i].city+', '+suggestedBarbers[i].state),
                            returnDistanceFutureBuilder('${suggestedBarbers[i].shopAddress}, ${suggestedBarbers[i].city}, ${suggestedBarbers[i].state} ${suggestedBarbers[i].zipcode}', Colors.grey),
                            getRatingWidget(context, double.parse(suggestedBarbers[i].rating)),
                          ],
                        ),
                        title: new Row(
                          children: <Widget> [
                            Flexible(
                              child: Container(
                                child: Row(
                                  children: <Widget> [
                                    Container(
                                      constraints: BoxConstraints(maxWidth: 200),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              suggestedBarbers[i].name+' '
                                            ),
                                            Text(
                                              '@'+suggestedBarbers[i].username,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                              )
                                            )
                                          ]
                                        )
                                      ),
                                    ),
                                  ]
                                )
                              )
                            ),
                          ]
                        ),
                        trailing: !suggestedBarbers[i].hasAdded ? IconButton(
                          onPressed: () async {
                            bool res = await addBarber(context, globals.token, int.parse(suggestedBarbers[i].id));
                            if(res) {
                              Flushbar(
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                title: "Barber Added",
                                message: "You can now book an appointment with this barber",
                                duration: Duration(seconds: 2),
                              )..show(context);
                              setState(() {
                                suggestedBarbers[i].hasAdded = true;
                              });
                            }
                          },
                          color: Colors.green,
                          icon: Icon(LineIcons.plus),
                        ) : 
                        IconButton(
                          onPressed: () async {
                            bool res = await removeBarber(context, globals.token, int.parse(suggestedBarbers[i].id));
                            if(res) {
                              Flushbar(
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                title: "Barber Removed",
                                message: "This babrber has been removed from your list",
                                duration: Duration(seconds: 2),
                              )..show(context);
                              setState(() {
                                suggestedBarbers[i].hasAdded = false;
                              });
                            }
                          },
                          color: Colors.red,
                          icon: Icon(LineIcons.minus),
                        ),
                      )
                    ),
                  ]
                )
              );
            }
          },
        ),
      );
    }else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          )
        ],
      );
    }
  }

  marketplaceTab() {
    if(isSearching){
      return searchMarketplace();
    }else {
      return suggestMarketplace();
    }
  }

  Widget searchMarketplace() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
          Text(
            'Searching marketplace is currently unavailable.',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * .018,
              color: Colors.grey[600]
            )
          ),
        ]
      )
    );
  }

  Widget suggestMarketplace() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
          Text(
            'Marketplace is currently unavailable.',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * .018,
              color: Colors.grey[600]
            )
          ),
        ]
      )
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
        child: new Scaffold(
          backgroundColor: Colors.black,
          appBar: new AppBar(
            backgroundColor: globals.userColor,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: _tabTitle == 'Search' ? TextField(
              focusNode: _searchFocus,
              controller: _search,
              onChanged: (val) {
                searchStreamController.add(val);
              },
              textInputAction: TextInputAction.search, 
              decoration: new InputDecoration(
                contentPadding: EdgeInsets.all(8.0),
                hintText: searchTabIndex == 0 ? 'Search by username' : 'Search by name',
                fillColor: globals.darkModeEnabled ? Colors.grey[900] : Colors.grey[100],
                filled: true,
                hintStyle: TextStyle(
                  color: globals.darkModeEnabled ? Colors.white : Colors.black
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none
                ),
              ),
            ) : new Text(_tabTitle,
              style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            elevation: 0.0,
            bottom: _tabTitle == 'Search' ? TabBar(
              onTap: (index) async {
                if(index == 0) {
                  // var res1 = await getUserLocation();
                  // var res = await getSuggestions(context, globals.token, 1, res1);
                  // setState(() {
                  //   suggestedBarbers = res;
                  //   searchTabIndex = 0;
                  // });
                  setState(() {
                    searchTabIndex = 0;
                  });
                }else {
                  setState(() {
                    searchTabIndex = 1;
                  });
                }
              },
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(text: "Barbers"),
                Tab(text: "Marketplace")
              ],
            ) : _tabTitle == 'Home' ? 
            TabBar(
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(text: "Dashboard"),
                Tab(text: "Feed")
              ],
            ) : null,
            actions: <Widget>[
              _tabTitle == "Home" ?
              Badge(
                showBadge: badgeNotifications == 0 ? false : true,
                badgeContent: Text('1'),
                position: BadgePosition.topLeft(),
                animationType: BadgeAnimationType.scale,
                animationDuration: const Duration(milliseconds: 300),
                child: IconButton(
                  onPressed: () {
                    final notificationScreen = new NotificationScreen();
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => notificationScreen));
                  },
                  icon: Icon(LineIcons.bell, size: 25.0),
                ) 
              ): Text(''),
              _tabTitle == "Marketplace" ?
              Badge(
                showBadge: badgeCart == 0 ? false : true,
                badgeContent: Text('1'),
                position: BadgePosition.topLeft(),
                animationType: BadgeAnimationType.scale,
                animationDuration: const Duration(milliseconds: 300),
                child: IconButton(
                  onPressed: () {
                    final marketplaceCartScreen = new MarketplaceCart();
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => marketplaceCartScreen));
                  },
                  icon: Icon(LineIcons.shopping_cart, size: 30.0),
                )
              ) : Text(''),
            ]
          ),
          body: Container(
            child: new WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: new Stack(
                children: <Widget>[
                  _tabTitle == 'Search' ?
                  new TabBarView(
                    children: <Widget>[
                      barberTab(),
                      marketplaceTab()
                    ],
                  ) : _tabTitle == 'Home' ?
                  new TabBarView(
                    children: <Widget>[
                      dashboardTab(),
                      feedTab()
                    ],
                  ) :
                  new Column(
                    children: <Widget>[
                      new Expanded(
                        child: new Container(
                          child: _children[_currentIndex],
                          padding: const EdgeInsets.only(bottom: 4.0),
                        )
                      )
                    ]
                  ),
                  //_progressHUD,
                ]
              )
            )
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: globals.userColor,
            type: BottomNavigationBarType.fixed,
            onTap: onNavTapTapped,
            currentIndex: _currentIndex,
            unselectedItemColor: globals.darkModeEnabled ? Colors.white : Colors.black,
            selectedItemColor: Colors.blue,
            items: [
              new BottomNavigationBarItem(
                icon: Icon(LineIcons.home, size: 29),
                title: Container(height: 0.0),
              ),
              new BottomNavigationBarItem(
                icon: Icon(LineIcons.shopping_cart, size: 35),
                title: Container(height: 0.0),
              ),
              new BottomNavigationBarItem(
                icon: Icon(LineIcons.search, size: 30),
                title: Container(height: 0.0),
              ),
              new BottomNavigationBarItem(
                icon: Icon(LineIcons.cog, size: 30),
                title: Container(height: 0.0),
              )
            ],
          )
        )
      )
    );
  }
}