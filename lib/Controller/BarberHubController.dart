import 'package:flutter/material.dart';
import 'package:trimmz/Model/AppointmentRequests.dart';
import 'package:trimmz/Model/availability.dart';
import 'package:trimmz/dialogs.dart';
import '../Model/SuggestedBarbers.dart';
import '../globals.dart' as globals;
import '../palette.dart';
import '../View/BarberHubTabs.dart';
import 'package:line_icons/line_icons.dart';
import 'NotificationController.dart';
import 'package:badges/badges.dart';
import '../calls.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'SelectBarberController.dart';
import '../Model/Packages.dart';
import 'package:intl/intl.dart';
import '../View/ModalSheets.dart';
import '../Model/availability.dart';
import '../View/SetAvailabilityModal.dart';
import 'BarberProfileController.dart';
import '../Model/ClientBarbers.dart';
import '../functions.dart';

class BarberHubScreen extends StatefulWidget {
  BarberHubScreen({Key key}) : super (key: key);

  @override
  BarberHubScreenState createState() => new BarberHubScreenState();
}

class BarberHubScreenState extends State<BarberHubScreen> with TickerProviderStateMixin {
  final TextEditingController _search = new TextEditingController();
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
  bool isSearching = false;
  int searchTabIndex = 0;
  CalendarController _calendarController;
  List<Packages> packages = [];
  List<Availability> availability = [];
  AnimationController _animationController;
  Map<DateTime, List> _events;
  List _selectedEvents = [];
  final df = new DateFormat('MM/dd/yyyy hh:mm a');
  final df2 = new DateFormat('yyyy-MM-dd');
  Colors status;
  List<AppointmentRequest> appointmentReq = [];

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();

    _search.addListener(() {
      if(_search.text.length > 0) {
        setState(() {
          isSearching = true;
        });
      }else {
        isSearching = false;
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    initBarberInfo();
    initSuggestedBarbers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void initSuggestedBarbers() async {
    var res1 = await getUserLocation();
    print(res1);
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

  addBarberPackage(String name, double price, int duration) async {
    if(name == "" || price.toString() == "" || duration.toString() == "") {
      showErrorDialog(context, "Field Left Empty", "A field was left empty. Please enter all fields required.");
      return false;
    }else {
      var res = await addPackage(context, globals.token, name, duration, price);
      return res;
    }
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
              return  Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: ListTile(
                  leading: new Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple,
                      gradient: new LinearGradient(
                        colors: [Colors.red, Colors.blue],
                      )
                    ),
                    child: Center(child: Text(_selectedEvents[i]['name'].substring(0,1), style: TextStyle(fontSize: 20)))
                  ),
                  title: Container(margin: EdgeInsets.only(bottom: 10.0), color: statusColor, width: MediaQuery.of(context).size.width, height: 2),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget> [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          Text(_selectedEvents[i]['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          Text(_selectedEvents[i]['package']),
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
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      showAptOptionModalSheet(context, _selectedEvents[i]);
                    },
                    child: Icon(Icons.more_vert)
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
      _selectedEvents = events;
    });
  }

  showSetAvailableTime(BuildContext context, Availability aDay) async {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: false, builder: (builder) {
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
                      Padding(padding: EdgeInsets.all(5.0),),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Icon(Icons.more_vert)
                      )
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

  Widget dashboardTab() {
    return SingleChildScrollView(
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
                  begin: Alignment(0.0, -2.0),//Alignment.center,
                  colors: [Colors.black, Colors.grey[850]]
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
                colors: [Colors.black, Colors.grey[850]]
              )
            ),
            margin: EdgeInsets.all(5.0),
            child: Column(
              children: <Widget> [
                TableCalendar(
                  locale: 'en_US',
                  events: _events,
                  onDaySelected: _onDaySelected,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(color: const Color(0xFFf2f2f2)),
                    weekendStyle: const TextStyle(color: const Color(0xFFf2f2f2))
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white)
                  ),
                  calendarStyle: CalendarStyle(
                    weekendStyle: const TextStyle(color: Colors.white)
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
                colors: [Colors.black, Colors.grey[850]]
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
                              showFullPkgsListModalSheet(context, packages);
                              // var res = await showAddPackageModalSheet(context);
                              // if(res != null) {
                              //   setState(() {
                              //     packages = res;
                              //   });
                              // }else {
                              //   return;
                              // }
                            },
                            child: Icon(LineIcons.th_list, color: Colors.blue)
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
                    itemCount: 5 * 1,
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
                                  // Padding(padding: EdgeInsets.all(5),),
                                  // GestureDetector(
                                  //   onTap: () async {
                                  //     var res = await showPackageOptionsModalSheet(context, packages[i].name, packages[i].price, packages[i].duration, packages[i].id);
                                  //     if(res != null) {
                                  //       setState(() {
                                  //         packages = res;
                                  //       });
                                  //     }else {
                                  //       return;
                                  //     }
                                  //   },
                                  //   child: Icon(Icons.more_vert)
                                  // )
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
                colors: [Colors.black, Colors.grey[850]]
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
    );
  }

  Widget feedTab() {
    return new Column(
      children: <Widget>[
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
      ]
    );
  }

  barberTab() {
    //initSuggestedBarbers();
    if(isSearching){
      return searchBarbers();
    }else {
      return suggestBarbers();
    }
  }

  Widget searchBarbers() {
    return Container(child: Text('IS SEARCHING'));
  }

  Widget suggestBarbers() {
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
                final profileScreen = new BarberProfileScreen(token: globals.token, userInfo: barber);
                Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));
              },
              child: Column(
                children: <Widget> [ 
                  ListTile(
                    leading: new Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple,
                        gradient: new LinearGradient(
                          colors: [Colors.red, Colors.blue]
                        )
                      ),
                      child: Center(child:Text(suggestedBarbers[i].name.substring(0,1), style: TextStyle(fontSize: 20),))
                    ),
                    subtitle: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RatingBarIndicator(
                          rating: double.parse(suggestedBarbers[i].rating),
                          itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                        Row(
                          children: <Widget>[
                            Text(suggestedBarbers[i].city+', '+suggestedBarbers[i].state)
                          ],
                        )
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
                  ),
                ]
              )
            );
          }
        },
      ),
    );
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
          appBar: new AppBar(
            backgroundColor: globals.userColor,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: _tabTitle == 'Search' ? TextField(
              focusNode: _searchFocus,
              controller: _search,
              textInputAction: TextInputAction.search, 
              decoration: new InputDecoration(
                contentPadding: EdgeInsets.all(8.0),
                hintText: searchTabIndex == 0 ? 'Search by username...' : 'Search by name...',
                fillColor: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[100],
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
                  var res1 = await getUserLocation();
                  var res = await getSuggestions(context, globals.token, 1, res1);
                  setState(() {
                    suggestedBarbers = res;
                    searchTabIndex = 0;
                  });
                }else {
                  //getSuggestions(context, globals.token, 2);
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
                  onPressed: () {},
                  icon: Icon(LineIcons.shopping_cart, size: 30.0),
                )
              ) : Text(''),
            ]
          ),
          body: Container(
            color: globals.userBrightness == Brightness.light ? lightBackgroundGrey : darkBackgroundGrey,
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
            selectedItemColor: Colors.blue,//Color(0xFF66BB6A), - Green
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