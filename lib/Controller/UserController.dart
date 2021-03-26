import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'dart:async';
import 'package:trimmz/calls.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/CustomDrawerHeader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/Model/WidgetStatus.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:line_icons/line_icons.dart';
import 'dart:ui' as ui;
import 'package:trimmz/Model/User.dart';
import 'package:async/async.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trimmz/Controller/AppointmentsController.dart';
import 'package:trimmz/Controller/UserProfileController.dart';
import 'package:trimmz/Controller/NotificationCenterController.dart';
import 'package:trimmz/dialogs.dart';
import 'package:trimmz/FeedItemWidget.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:trimmz/Model/NotificationItem.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:trimmz/Badge.dart';
import 'package:trimmz/userAppointmentControlButtons.dart';
import 'package:expandable/expandable.dart';

class UserController extends StatefulWidget {
  final List<DashboardItem> dashboardItems;
  final screenHeight;
  final Appointments appointments;
  UserController({Key key, this.dashboardItems, this.screenHeight, this.appointments}) : super (key: key);

  @override
  UserControllerState createState() => new UserControllerState();
}

class UserControllerState extends State<UserController> with TickerProviderStateMixin {
  final TextEditingController searchTFController = new TextEditingController();
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  String filter;
  List<DashboardItem> _dashboardItems = [];
  List<DashboardItem> _drawerItems = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  CalendarController _calendarController = new CalendarController();
  WidgetStatus _calendarWidgetStatus = WidgetStatus.HIDDEN;
  WidgetStatus _searchWidgetStatus = WidgetStatus.HIDDEN;
  WidgetStatus _feedWidgetStatus = WidgetStatus.HIDDEN;
  AnimationController calendarAnimationController, searchAnimationController, feedAnimationController, opacityAnimationController, opacityAnimationController2, opacityAnimationController3;
  Animation calendarPositionAnimation, calendarOpacityAnimation, searchPositionAnimation, searchOpacityAnimation, feedPositionAnimation, feedOpacityAnimation;
  final duration = new Duration(milliseconds: 200);
  bool calendarActive = true;
  bool searchActive = true;
  bool feedActive = true;
  GlobalKey key = GlobalKey();
  List<Appointment> appointments = [];
  Map<DateTime, List> _calendarAppointments;
  DateTime _calendarSelectedDay = DateTime.now();
  List _selectedAppointments = [];
  List appointmentRequests = [];
  List<User> setLocatedUsers = [];
  AsyncMemoizer _memoizer;
  AsyncMemoizer _memoizer2;
  List<NotificationItem> notifications = [];
  List<User> clients = [];
  var refreshFeedKey = GlobalKey<RefreshIndicatorState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    firebaseCloudMessagingListeners();
    initGetNotifications();
    getClients();

    globals.userControllerState = this;

    _memoizer = AsyncMemoizer();
    _memoizer2 = AsyncMemoizer();

    _dashboardItems = widget.dashboardItems.where((element) => element.isDashboard).toList();
    _dashboardItems.sort((a,b) => a.sort.compareTo(b.sort));
    _drawerItems = widget.dashboardItems.where((element) => !element.isDashboard).toList();
    _drawerItems.sort((a,b) => a.sort.compareTo(b.sort));
    _calendarAppointments = widget.appointments.calendarFormat ?? {};
    appointments = widget.appointments.list;
    appointmentRequests = widget.appointments.requests;
    _selectedAppointments = _calendarAppointments[DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())))] ?? [];

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    // CALENDAR ANIMATIONS
    calendarAnimationController = new AnimationController(duration: duration, vsync: this);
    opacityAnimationController = new AnimationController(duration: duration, vsync: this);
    calendarPositionAnimation = new Tween(begin: 0.0, end: widget.screenHeight).animate(
      new CurvedAnimation(parent: calendarAnimationController, curve: Curves.easeInOut)
    );
    calendarOpacityAnimation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: opacityAnimationController, curve: Curves.easeInOut)
    );
    calendarPositionAnimation.addListener(() {
      setState(() {});
    });
    calendarOpacityAnimation.addListener(() {
      setState(() {});
    });
    calendarAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (calendarActive) {
          _calendarWidgetStatus = WidgetStatus.VISIBLE;
        } else {
          _calendarWidgetStatus = WidgetStatus.HIDDEN;
        }
      }
    });

    // SEARCH ANIMATIONS
    searchAnimationController = new AnimationController(duration: duration, vsync: this);
    opacityAnimationController2 = new AnimationController(duration: duration, vsync: this);
    searchPositionAnimation = new Tween(begin: 0.0, end: widget.screenHeight).animate(
      new CurvedAnimation(parent: searchAnimationController, curve: Curves.easeInOut)
    );
    searchOpacityAnimation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: opacityAnimationController2, curve: Curves.easeInOut)
    );
    searchPositionAnimation.addListener(() {
      setState(() {});
    });
    searchOpacityAnimation.addListener(() {
      setState(() {});
    });
    searchAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (searchActive) {
          _searchWidgetStatus = WidgetStatus.VISIBLE;
        } else {
          _searchWidgetStatus = WidgetStatus.HIDDEN;
        }
      }
    });

    // FEED ANIMATIONS
    feedAnimationController = new AnimationController(duration: duration, vsync: this);
    opacityAnimationController3 = new AnimationController(duration: duration, vsync: this);
    feedPositionAnimation = new Tween(begin: 0.0, end: widget.screenHeight).animate(
      new CurvedAnimation(parent: feedAnimationController, curve: Curves.easeInOut)
    );
    feedOpacityAnimation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: opacityAnimationController3, curve: Curves.easeInOut)
    );
    feedPositionAnimation.addListener(() {
      setState(() {});
    });
    feedOpacityAnimation.addListener(() {
      setState(() {});
    });
    feedAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (feedActive) {
          _feedWidgetStatus = WidgetStatus.VISIBLE;
        } else {
          _feedWidgetStatus = WidgetStatus.HIDDEN;
        }
      }
    });

    super.initState();
  }

  initGetNotifications() async {
    var result = await getNotifications(context, globals.user.token);
    handleNotificationData(result);
  }

  getClients() async {
    List<User> results = await getUserClients(context, globals.user.token);

    setState(() {
      clients = results;
    });
  }

  handleNotificationData(var data) {
    if(data is List<NotificationItem>) {
      setState(() {
        notifications = data;
      });
    }else {

    }
  }
  
  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token) async {
      print("CLOUD MESSAGING TOKEN: " + token);
      await setFirebaseToken(context, token, globals.user.token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        
      },
      onResume: (Map<String, dynamic> message) async {
        
      },
      onLaunch: (Map<String, dynamic> message) async {
        
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings){

    });
  }

  List<List<DashboardItem>> generateDrawerLists() {
    Map<int, List<DashboardItem>> mapOfDashboardList = {};
    List<List<DashboardItem>> listofLists = [];

    for(var item in _drawerItems) {
      if(mapOfDashboardList.containsKey(item.listNumber)) {
        mapOfDashboardList[item.listNumber].add(item);
      }else {
        List<DashboardItem> x = [];
        x.add(item);
        mapOfDashboardList[item.listNumber] = x;
      }
    }

    mapOfDashboardList.forEach((k, v) {
      listofLists.add(v);
    });

    return listofLists;
  }

  @override
  void dispose() {
    super.dispose();
    calendarAnimationController.dispose();
    opacityAnimationController.dispose();
    searchAnimationController.dispose();
    opacityAnimationController2.dispose();
    feedAnimationController.dispose();
    opacityAnimationController3.dispose();
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

  void onTapDownCalendar() {
    if (_calendarWidgetStatus == WidgetStatus.HIDDEN) {
      calendarAnimationController.forward(from: 0.0);
      opacityAnimationController.forward(from: 0.0);
      _calendarWidgetStatus = WidgetStatus.VISIBLE;
      _calendarController.setCalendarFormat(CalendarFormat.month);
      _calendarController.setSelectedDay(DateTime.now());
      _selectedAppointments = _calendarAppointments[DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())))] ?? [];
    }
    else if (_calendarWidgetStatus == WidgetStatus.VISIBLE) {
      calendarAnimationController.reverse(from: 400.0);
      opacityAnimationController.reverse(from: 1.0);
      _calendarWidgetStatus = WidgetStatus.HIDDEN;
      _calendarController.setCalendarFormat(CalendarFormat.week);
      _calendarController.setSelectedDay(DateTime.now());
      _selectedAppointments = _calendarAppointments[DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())))] ?? [];
    }
  }

  void onTapDownSearch() {
    if (_searchWidgetStatus == WidgetStatus.HIDDEN) {
      searchAnimationController.forward(from: 0.0);
      opacityAnimationController2.forward(from: 0.0);
      _searchWidgetStatus = WidgetStatus.VISIBLE;
    }
    else if (_searchWidgetStatus == WidgetStatus.VISIBLE) {
      searchAnimationController.reverse(from: 400.0);
      opacityAnimationController2.reverse(from: 1.0);
      _searchWidgetStatus = WidgetStatus.HIDDEN;
    }
  }

  void onTapDownFeed() {
    if (_feedWidgetStatus == WidgetStatus.HIDDEN) {
      feedAnimationController.forward(from: 0.0);
      opacityAnimationController3.forward(from: 0.0);
      _feedWidgetStatus = WidgetStatus.VISIBLE;
    }
    else if (_feedWidgetStatus == WidgetStatus.VISIBLE) {
      feedAnimationController.reverse(from: 400.0);
      opacityAnimationController3.reverse(from: 1.0);
      _feedWidgetStatus = WidgetStatus.HIDDEN;
    }
  }

  Future<Null> refreshList() async {
    Completer<Null> completer = new Completer<Null>();
    refreshKey.currentState.show();
    List<DashboardItem> dashItems = await getDashboardItems(globals.user.token, context);
    var results = await getAppointments(context, globals.user.token, globals.user.userType);

    completer.complete();
    setState(() {
      _dashboardItems = dashItems.where((element) => element.isDashboard).toList();
      _dashboardItems.sort((a,b) => a.sort.compareTo(b.sort));
      _drawerItems = dashItems.where((element) => !element.isDashboard).toList();
      _drawerItems.sort((a,b) => a.sort.compareTo(b.sort));
      _calendarAppointments = results.calendarFormat;
      appointmentRequests = results.requests;
      appointments = results.list;
    });
    return completer.future;
  }
  
  Widget buildHeader() {
    return new Stack(
      alignment: const Alignment(0.0, -0.5),
      children: <Widget>[
        _buildCalendar(),
        new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(36.0),
            ),
            new Container(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0, left: 8.0, top: 16.0),
            )
          ]
        ),
      ]
    );
  }

  _handleDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkModeEnabled', !globals.darkModeEnabled);
    setState(() {
      if (globals.darkModeEnabled == true) {
        globals.userBrightness = Brightness.light;
        globals.darkModeEnabled = false;
      }
      else {
        globals.userBrightness = Brightness.dark;
        globals.darkModeEnabled = true;
      }
    });
  }

  buildCmdWidget(BuildContext context, String cmdCode) {
    switch(cmdCode) {
      case "drawer_apt_requests": {
        Widget widget;
        if(appointmentRequests.length > 0) {
          widget = new Container(
            child: Text(
              appointmentRequests.length.toString(),
            ),
            padding: EdgeInsets.all(5.0),
          );
        }else {
          widget = new Container();
        }

        return widget;
      }
      default: {
        return new Container();
      }
    }
  }

  buildDrawerSubList(List<DashboardItem> items) {
    List<Widget> widgetList = [];
    for(DashboardItem item in items) {
      Widget widget = new FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
        onPressed: () async {
          progressHUD();
          var microAppController = await buildMicroAppController(context, item, data: await handleLocalMicroAppData(item));
          if (microAppController == null) {
            progressHUD();
            showErrorDialog(context, "An error has occurred", "Could not open '${item.name}'. Please try again.");
            return;
          }
          progressHUD();
          Navigator.push(context, new MaterialPageRoute(builder: (context) => microAppController));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400
              )
            ),
            buildCmdWidget(context, item.cmdCode)
          ]
        )
      );
      widgetList.add(widget);
    }
    return Column(children: widgetList);
  }
  
  _buildDrawerItemList() {
    List<List<DashboardItem>> drawerList = generateDrawerLists();
    return ListView.separated(
      padding: EdgeInsets.all(0.0),
      shrinkWrap: true,
      itemCount: drawerList.length,
      separatorBuilder: (context, index) {
        return new Divider();
      },
      itemBuilder: (context, index) {
        return buildDrawerSubList(drawerList[index]);
      },
    );
  }

  goToAppointments() {
    var userAppointments = appointments.where((element) => element.status != 3 || element.status != 2).toList();
    userAppointments.sort((a,b) => DateTime.parse(a.appointmentFullTime).compareTo(DateTime.parse(b.appointmentFullTime)));

    final appointmentsController = new AppointmentsController(appointments: userAppointments);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentsController));
  }

  goToClientList() {
    //TODO: Go to client list
  }

  Widget buildDrawer() {
    return new Drawer(
      child: new Container(
        color: globals.darkModeEnabled ? richBlack : Colors.white,
        child: Column(
          children: <Widget>[
            new CustomUserAccountsDrawerHeader(
              headerImage: globals.user.headerPicture != null ?
              NetworkImage(
                "${globals.baseImageUrl}${globals.user.headerPicture}",
              ): AssetImage("images/trimmz_icon_t.png"),
              accountName: new Text(
                globals.user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0
                ),
              ),
              accountUsername: new Text(
                "@" + globals.user.username,
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80)
                )
              ),
              currentAccountPicture: buildUserProfilePicture(context, globals.user.profilePic, globals.user.username),
              otherDetails: Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${clients.length} ",
                              style: TextStyle(
                                color: globals.darkModeEnabled ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0
                              )
                            ),
                            TextSpan(
                              text: "Clients",
                              style: TextStyle(
                                color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                                fontWeight: FontWeight.normal,
                                fontSize: 15.0
                              )
                            )
                          ]
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: GestureDetector(
                        onTap: () => goToAppointments(),
                        child:  RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${appointments.where((element) => element.status != 3 || element.status != 2).length.toString()} ",
                                style: TextStyle(
                                  color: globals.darkModeEnabled ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0
                                )
                              ),
                              TextSpan(
                                text: "Appointments",
                                style: TextStyle(
                                  color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15.0
                                )
                              )
                            ]
                          ),
                        ),
                      )
                    )
                  ]
                ),
              ),
            ),
            new Expanded(
              child: _buildDrawerItemList()
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              height: 100.0,
              padding: EdgeInsets.only(bottom: 15.0, top: 10.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(globals.darkModeEnabled ? Icons.wb_sunny_rounded : Icons.wb_sunny_outlined),
                    onPressed: () {
                      _handleDarkMode();
                    },
                  ),
                ],
              )
            ),
          ],
        )
      ),
    );
  }

  Future<dynamic> handleLocalMicroAppData(DashboardItem item) async {
    switch(item.cmdCode) {
      case "user_schedule": {
        return _calendarAppointments;
      }
      case "user_services": {
        return widget.screenHeight;
      }
      case "drawer_apt_requests": {
        return appointmentRequests;
      }
      default: {
        return null;
      }
    }
  }

  Widget _buildGridTile(DashboardItem dashboardItem, int index, double scale) {
    return new GestureDetector(
      onTap: () async {
        progressHUD();
        var microAppController = await buildMicroAppController(context, dashboardItem, data: await handleLocalMicroAppData(dashboardItem));
        if (microAppController == null) {
          progressHUD();
          showErrorDialog(context, "An error has occurred", "Could not open '${dashboardItem.name}'. Please try again.");
          return;
        }
        Navigator.push(context, new MaterialPageRoute(builder: (context) => microAppController));
        progressHUD();
      },
      child: Container(
        height: 100.0,
        child: new Column(
          children: <Widget>[
            new Expanded(
              flex: 7,
              child: new Container(
                child: new Center(
                  child: dashboardItem.icon,
                ),
                decoration: new BoxDecoration(
                  color: globals.darkModeEnabled ? darkBackgroundGrey : lightBackgroundGrey,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0))
                ),
              ),
            ),
            new Expanded(
              flex: 3,
              child: new Container(
                padding: const EdgeInsets.all(5.0),
                child: new Center(
                  child: new Text(dashboardItem.name,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    style: new TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0 * scale,
                    ),
                  ),
                ),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
                )
              )
            )
          ],
        ),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        )
      )
    );
  }


  buildDashboard() {
    var filterDashboardList = _dashboardItems;
    if (filterDashboardList != null) {
      if (filterDashboardList.length > 0) {
        return new RefreshIndicator(
          onRefresh: refreshList,
          key: refreshKey,
          color: globals.darkModeEnabled ? Colors.white : Colors.blue,
          child: new GridView.builder(
            shrinkWrap: true,
            itemCount: filterDashboardList.length,
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 15.0, top: 0.0),
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
              childAspectRatio: 0.9
            ),
            itemBuilder: (context, index) {
              return new Card(
                child: _buildGridTile(filterDashboardList[index], index, 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                ),
              );
            },
          ),
        );
      } 
      else {
        return new Stack(
          children: <Widget>[
            new RefreshIndicator(
              color: globals.darkModeEnabled ? Colors.white : Colors.blue,
              onRefresh: refreshList,
              key: refreshKey,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
            Container(
              child: new Center(
                child: filter == null || filter == "" ?
                new Text("You have not been assigned any apps.\nPlease contact support.",
                  textAlign: TextAlign.center,
                ) : 
                new Text("No apps match your search query.",
                  textAlign: TextAlign.center,
                )
              ),
            )
          ],
        );
      }
    }
    else {
      return new Container();
    }
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

  _buildCalendarList() {
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
                    print(value.status);
                    setState(() {
                      _selectedAppointments[index]['status'] = value.status;
                    });
                    refreshList();
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

  Widget _buildUserSearchCard(User user) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserProfilePicture(context, user.profilePicture, user.name),
            Padding(padding: EdgeInsets.all(4)),
            Expanded(
              flex: 9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${user.name} ",
                          style: TextStyle(
                            color: globals.darkModeEnabled ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0
                          )
                        ),
                        TextSpan(
                          text: "@${user.username}",
                          style: TextStyle(
                            color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                            fontWeight: FontWeight.normal,
                            fontSize: 15.0
                          )
                        )
                      ]
                    ),
                  ),
                  user.shopName != null && user.shopName != "" ?
                  Text(
                    user.shopName,
                    style: TextStyle(
                      color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0
                    )
                  ) : Container(),
                  user.shopAddress != null ?
                  Text(
                    "${user.shopAddress}, ${user.city}, ${user.state} ${user.zipcode}",
                    style: TextStyle(
                      color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0
                    )
                  ) : Text(
                    "${user.city}, ${user.state} ${user.zipcode}",
                    style: TextStyle(
                      color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0
                    )
                  )
                ]
              )
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "${user.numOfReviews} Ratings",
                  ),
                  Text(
                    user.rating != "0" ? double.parse(user.rating).toStringAsFixed(1) : "N/A",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  ),
                  RatingBarIndicator(
                    rating: double.parse(user.rating),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Color(0xFFD2AC47),
                    ),
                    itemCount: 5,
                    itemSize: 13.0,
                    direction: Axis.horizontal,
                    unratedColor: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                  ),
                ],
              ),
            ),
          ]
        )
      )
    );
  }

  _unfocusSearch() {
    FocusScope.of(context).unfocus();
    onTapDownSearch();
  }

  goToUserProfile(int token) {
    final userProfileController = new UserProfileController(token: token);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => userProfileController));
  }

  Widget buildSearchResults(List<User> users) {
    return GestureDetector(
      onTap: () => _unfocusSearch(),
      child: Container(
        child: ListView.builder(
          itemCount: users.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => goToUserProfile(users[index].id),
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: users[index].headerImage != null ? NetworkImage(
                        "${globals.baseImageUrl}${users[index].headerImage}",
                      ) : AssetImage("images/trimmz_icon_t.png"),
                      fit: BoxFit.cover
                    )
                  ),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        alignment: Alignment.center,
                        color: globals.darkModeEnabled ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
                        child: _buildUserSearchCard(users[index])
                      ),
                    ),
                  ),
                )
              )
            );
          },
        ),
      )
    );
  }

  _fetchUserByLocationData() async {
    int zipcode = await getCurrentLocationZipcode();
    print(zipcode);
    return this._memoizer.runOnce(() async {
      var res = await getUsersByLocation(context, zipcode);
      return res;
    });
  }

  _fetchUserFeed() async {
    return this._memoizer2.runOnce(() async {
      var res = await getUserFeed(context, globals.user.token);
      return res;
    });
  }

  buildEmptyFeed() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No Photos?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "This empty feed won\'t last long. Start following people and you\'ll see photos show up here.",
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.all(10)),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .5
                  ),
                  decoration: BoxDecoration(
                    color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(100, 0, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    border: Border.all(
                      color: CustomColors1.mystic.withAlpha(100)
                    )
                  ),
                  child: RippleButton(
                    splashColor: CustomColors1.mystic.withAlpha(100),
                    onPressed: () {
                      onTapDownSearch();
       


                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: Center(
                        child: Text(
                          "Find people to follow",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500
                          )
                        ),
                      )
                    )
                  )
                )
              ]
            ),
          ]
        )
      )
    );
  }

  _buildPhotoFeed() {
    var apiCall = _fetchUserFeed();
    return FutureBuilder(
      future: apiCall,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            // TODO: SHOW LOADING
          case ConnectionState.done:
            if(snapshot.hasData) {
              if(snapshot.data.length > 0) {
                return new RefreshIndicator(
                  key: refreshFeedKey,
                  color: globals.darkModeEnabled ? Colors.white : Colors.blue,
                  onRefresh: () {             
                    return apiCall = getUserFeed(context, globals.user.token);
                  },
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return FeedItemWidget(item: snapshot.data[index]);
                    },
                  )
                );
              }else {
                return buildEmptyFeed();
              }
            }else {
              return CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation(Colors.blue)
              );
            }
            break;
          default:
            return null; 
        }
      },
    );
  }

  _buildSearchList() {
    return FutureBuilder(
      future: _fetchUserByLocationData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildSearchResults(snapshot.data);
        } else {
          return CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation(Colors.blue)
          );
        }
      }
    );
  }

  Widget getCalendarOverlay() {
    var searchHeight = 0.0;
    var searchOpacity = 0.0;
    switch(_calendarWidgetStatus) {
      case WidgetStatus.HIDDEN:
        searchHeight = calendarPositionAnimation.value;
        searchOpacity = calendarOpacityAnimation.value;
        calendarActive = false;
        break;
      case WidgetStatus.VISIBLE:
        searchHeight = calendarPositionAnimation.value;
        searchOpacity = calendarOpacityAnimation.value;
        calendarActive = true;
        break;
    }
    return new Container(
        width: MediaQuery.of(context).size.width,
        height: searchHeight,
        child: new Opacity(
          opacity: searchOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: _buildCalendarList()
              ),
            ],
          )
        ),
        color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
    );
  }

  Widget getSearchOverlay() {
    var searchHeight = 0.0;
    var searchOpacity = 0.0;
    switch(_searchWidgetStatus) {
      case WidgetStatus.HIDDEN:
        searchHeight = searchPositionAnimation.value;
        searchOpacity = searchOpacityAnimation.value;
        searchActive = false;
        break;
      case WidgetStatus.VISIBLE:
        searchHeight = searchPositionAnimation.value;
        searchOpacity = searchOpacityAnimation.value;
        searchActive = true;
        break;
    }
    return new BackdropFilter(
      filter: new ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: searchHeight,
        child: new Opacity(
          opacity: searchOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: _buildSearchList()
              ),
            ],
          )
        ),
        color: globals.darkModeEnabled ? Color.fromARGB(220, 0, 0, 0) : Color.fromARGB(220, 255, 255, 255),
      )
    );
  }

  Widget getFeedOverlay() {
    var feedHeight = 0.0;
    var feedOpacity = 0.0;
    switch(_feedWidgetStatus) {
      case WidgetStatus.HIDDEN:
        feedHeight = feedPositionAnimation.value;
        feedOpacity = feedOpacityAnimation.value;
        feedActive = false;
        break;
      case WidgetStatus.VISIBLE:
        feedHeight = feedPositionAnimation.value;
        feedOpacity = feedOpacityAnimation.value;
        feedActive = true;
        break;
    }
    return new BackdropFilter(
      filter: new ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: feedHeight,
        child: new Opacity(
          opacity: feedOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: _buildPhotoFeed()
              ),
            ],
          )
        ),
        color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
      )
    );
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

  _buildCalendar() {
    return new GestureDetector(
      onVerticalDragEnd: (details) {
        if(details.velocity.pixelsPerSecond.dy > 0.0) {
          if(_calendarController.calendarFormat != CalendarFormat.month) {
            onTapDownCalendar();
          }
        }else {
          if(_calendarController.calendarFormat != CalendarFormat.week) {
            onTapDownCalendar();
          }
        }
      },
      child: TableCalendar(
        events: _calendarAppointments,
        onDaySelected: _onDaySelected,
        calendarController: _calendarController,
        initialSelectedDay: _calendarSelectedDay,
        initialCalendarFormat: CalendarFormat.week,
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
            AnimationController animation = new AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 400),
            );
            animation.forward();

            if(_calendarWidgetStatus == WidgetStatus.VISIBLE) {
              return FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
                child: Container(
                  margin: const EdgeInsets.all(10.0),
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
            }else {
             return Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? primaryColor : Colors.transparent
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? globals.darkModeEnabled ? Colors.white : Colors.white : globals.darkModeEnabled ? Colors.white : Colors.black,
                      fontWeight: DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                )
              );
            }
          },
          todayDayBuilder: (context, date, _) {
            if(_calendarWidgetStatus == WidgetStatus.VISIBLE) {
              return Container(
                margin: const EdgeInsets.all(10.0),
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
            }else {
              return Container(
                margin: const EdgeInsets.all(10.0),
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
              );
            }
          }
        )
      ),
    );
  }

  Widget _buildSearchTF() {
    return Container(
      decoration: BoxDecoration(
        color: globals.darkModeEnabled ? darkBackgroundGrey : Color.fromARGB(255, 232, 232, 232),
        borderRadius: BorderRadius.circular(50.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        autocorrect: false,
        style: TextStyle(
          color: globals.darkModeEnabled ? Colors.white : Colors.black,
          fontFamily: 'OpenSans',
        ),
        decoration: InputDecoration(
          border: UnderlineInputBorder(borderSide: BorderSide.none),
          isDense: true,
          contentPadding: EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8),
          hintText: 'Search Trimmz',
          hintStyle: TextStyle(
            color: globals.darkModeEnabled ? Colors.white54 : Colors.black54,
            fontFamily: 'OpenSans',
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
        accentColor: globals.darkModeEnabled ? Colors.white : Colors.black,
        dividerColor: Colors.transparent,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: _searchWidgetStatus != WidgetStatus.VISIBLE ? new Text(
            "Welcome ${globals.user.name}!",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ) : _buildSearchTF(),
          elevation: 0.0,
          actions: [
            _searchWidgetStatus != WidgetStatus.VISIBLE ? Container(
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
              child: GestureDetector(
                child: Icon(Icons.dashboard_outlined),
                onTap: () {
                  onTapDownFeed();
                },
              )
            ) : Container(),

            _searchWidgetStatus != WidgetStatus.VISIBLE ? Container(
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
              child: GestureDetector(
                child: Badge(
                  widget: Icon(Icons.notifications_none_sharp),
                  count: notifications.where((e) => e.read == false).length
                ),
                onTap: () async {
                  final notificationCenterController = new NotificationCenterController(notifications: notifications, clients: clients, screenHeight: MediaQuery.of(context).size.height);
                  await Navigator.push(context, new MaterialPageRoute(builder: (context) => notificationCenterController));

                  for(var item in notifications) {
                    setState(() {
                      item.read = true;
                    });
                  }
                },
              )
            ) : Container(),

            Container(
              margin: EdgeInsets.only(left: 8.0, right: 15.0),
              child: GestureDetector(
                child: _searchWidgetStatus == WidgetStatus.VISIBLE ? Icon(Icons.close) : Icon(Icons.search),
                onTap: () {
                  onTapDownSearch();
                },
              )
            )
          ],
          leading: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                child: BadgeIndicator(
                  widget: Icon(Icons.menu),
                  showIndicator: appointmentRequests.length > 0 ? true : false,
                ),
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: buildDrawer(),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: new Container(
            color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
            child: new WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: new Stack(
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.only(bottom:  2.0),
                        child: buildHeader(),
                        decoration: BoxDecoration(
                          color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
                        ),
                      ),
                      new Expanded(
                        child: new Container(
                          key: key,
                          child: Stack(
                            children: [
                              buildDashboard(),
                              getCalendarOverlay(),
                            ],
                          ),
                          padding: const EdgeInsets.only(top: 0.0),
                        )
                      ),
                    ]
                  ),
                  getFeedOverlay(),
                  getSearchOverlay(),
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