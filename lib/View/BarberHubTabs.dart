import 'package:flutter/material.dart';
import 'package:trimmz/dialogs.dart';
import '../View/Widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_icons/line_icons.dart';
import '../Calls/GeneralCalls.dart';
import 'package:flushbar/flushbar.dart';
import '../Model/SuggestedBarbers.dart';
import '../globals.dart' as globals;
import '../Model/ClientBarbers.dart';
import '../Controller/BarberProfileV2Controller.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import '../functions.dart';
import 'package:badges/badges.dart';
import '../Controller/MarketplaceCartController.dart';
import '../Controller/SelectBarberController.dart';
import '../Controller/NotificationController.dart';
import 'package:expandable/expandable.dart';
import '../Controller/MobileTransactionSetup.dart';
import '../Model/Packages.dart';
import 'AddPackageModal.dart';
import '../Model/AppointmentRequests.dart';
import 'AppointmentRequestModal.dart';
import 'package:table_calendar/table_calendar.dart';
import 'FullCalendarModal.dart';
import 'BarberAppointmentOptions.dart';
import 'AppointmentCancelOptions.dart';
import 'AddManualAppointmentModal.dart';
import 'package:intl/intl.dart';
import 'FullPackagesListModalSheet.dart';
import 'PackageOptionsModal.dart';
import '../Model/BarberPolicies.dart';
import 'BarberPoliciesModal.dart';
import '../Model/availability.dart';
import 'SetAvailabilityModal.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import '../Controller/AddImageController.dart';
import '../Model/FeedItems.dart';
import 'SettingsTab.dart';
import '../Model/AvailabilityV2.dart';
import '../View/SetAvailabilityV2Modal.dart';

class BarberHubTabWidget extends StatefulWidget{
  final int widgetItem;
  final List selectedEvents;
  final List<Packages> packages;
  final Map<DateTime, List> events;
  final List<Availability> availability;
  final List<AvailabilityV2> availabilityV2;
  final List<AppointmentRequest> appointmentReq;
  final BarberPolicies policies;
  BarberHubTabWidget({Key key, this.widgetItem, this.selectedEvents, this.packages, this.events, this.availability, this.appointmentReq, this.policies, this.availabilityV2}) : super (key: key);

  @override
  BarberHubTabWidgetState  createState() => BarberHubTabWidgetState ();
}

class BarberHubTabWidgetState extends State<BarberHubTabWidget> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> refreshKey2 = new GlobalKey<RefreshIndicatorState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool isSearching = false;
  List<SuggestedBarbers> suggestedBarbers = [];
  List<SuggestedBarbers> searchedBarbers = [];
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  int searchTabIndex = 0;
  StreamController<String> searchStreamController = StreamController();
  final TextEditingController _search = new TextEditingController();
  FocusNode _searchFocus = new FocusNode();
  int badgeCart = 0;
  int badgeNotifications = 0;
  List<Packages> packages = [];
  List<Availability> availability = [];
  List<AvailabilityV2> availabilityV2 = [];
  List<AppointmentRequest> appointmentReq = [];
  Map<DateTime, List> _events;
  Map<DateTime, List> _availability = {};
  DateTime _calendarSelectDay = DateTime.now();
  List _selectedEvents = [];
  Colors status;
  CalendarController _calendarController;
  CalendarController _calendarAvailabilityController;
  AnimationController _animationController;
  AnimationController _animationAvailabilityController;
  BarberPolicies policies = new BarberPolicies();
  final df2 = new DateFormat('yyyy-MM-dd');
  List<FeedItem> feedItems = [];

  void initState() {
    super.initState();

    _calendarController = new CalendarController();
    _animationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();

    _calendarAvailabilityController = new CalendarController();
    _animationAvailabilityController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationAvailabilityController.forward();

    searchStreamController.stream
    .debounce(Duration(milliseconds: 0))
    .listen((s) => _searchValue(s, searchTabIndex));

    initSuggestedBarbers();
    initBarberInfo();
    firebaseCloudMessagingListeners();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token) async {
      await setFirebaseToken(context, token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        var res = await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['title'], message['body']);
        if(res) {
          checkNotificiations();
          if(message['action'] == 'BOOK_APPOINTMENT') {
            var res3 = await getBarberAppointmentRequests(context, globals.token);
            setState(() {
              appointmentReq = res3;
            });
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        var res = await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['title'], message['body']);
        if(res) {
          checkNotificiations();
          if(message['action'] == 'BOOK_APPOINTMENT') {
            var res3 = await getBarberAppointmentRequests(context, globals.token);
            setState(() {
              appointmentReq = res3;
            });
          }
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        var res = await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['notification']['title'], message['notification']['body']);
        if(res) {
          checkNotificiations();
          if(message['action'] == 'BOOK_APPOINTMENT') {
            var res3 = await getBarberAppointmentRequests(context, globals.token);
            setState(() {
              appointmentReq = res3;
            });
          }
        }
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

  initBarberInfo() async {
    setState(() {
      packages = widget.packages;
      _events = widget.events;
      _selectedEvents = widget.selectedEvents;
      availability = widget.availability;
      availabilityV2 =  widget.availabilityV2;
      appointmentReq = widget.appointmentReq;
      policies = widget.policies;
    });
    
    for(var item in availabilityV2) {
      DateTime date = DateTime.parse(DateFormat('yyyy-MM-dd').format(item.date));
      setState(() {
        _availability[date] = [{'date': item.date, 'start': item.start, 'end': item.end, 'closed': item.closed}];
      });
    }
    
    var res5 = await getPosts(context, globals.token, 1);
    setState(() {
      feedItems = res5;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  checkNotificiations() async {
    var res = await getUnreadNotifications(context, globals.token);
    setState(() {
      badgeNotifications = res.length;
    });
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

  _searchValue(String string, int type) async {
    if(type == 0) {
      if(_search.text.length > 0) {
        var res = await getSearchBarbers(context, _search.text);
        setState(() {
          searchedBarbers = res;
          isSearching = true;
        });
      }
      if(_search.text.length == 0) {
        setState(() {
          isSearching = false;
        });
      }
    }else {

    }
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

  barberTab() {
    if(isSearching){
      return searchBarbers();
    }else {
      return suggestBarbers();
    }
  }

  marketplaceTab() {
    if(isSearching){
      return searchMarketplace();
    }else {
      return suggestMarketplace();
    }
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: globals.darkModeEnabled ? Colors.blue[700] : Colors.lightBlue
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
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  progressHUD();
                  var res = await getBarberPolicies(context, int.parse(searchedBarbers[i].id));
                  progressHUD();
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
                  barber.profilePicture = searchedBarbers[i].profilePicture;
                  barber.headerImage = searchedBarbers[i].headerImage;
                  // barber.created = suggestedBarbers[i].created;
                  final profileScreen = new BarberProfileV2Screen(token: globals.token, userInfo: barber, barberPolicies: res);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));
                },
                child: Column(
                  children: <Widget> [ 
                    Container(
                      color: globals.darkModeEnabled ? Colors.black87 : Colors.white10,
                      child: ListTile(
                        leading: buildProfilePictures(context, searchedBarbers[i].profilePicture, searchedBarbers[i].username, 30.0),
                        subtitle: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            searchedBarbers[i].shopName != null && searchedBarbers[i].shopName != '' ?
                            Text(
                              searchedBarbers[i].shopName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic
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
                                        child: RichText(
                                          softWrap: true,
                                          text: new TextSpan(
                                            children: <TextSpan> [
                                              new TextSpan(text: searchedBarbers[i].name+' ', style: TextStyle(fontWeight: FontWeight.bold, color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                              new TextSpan(text: '@'+searchedBarbers[i].username, style: TextStyle(fontSize: 12,color: Colors.grey)),
                                            ]
                                          )
                                        )
                                      ),
                                    ),
                                  ]
                                )
                              )
                            ),
                          ]
                        ),
                        trailing: globals.token == int.parse(searchedBarbers[i].id) ? Container(child:Text('')) : !searchedBarbers[i].hasAdded ? IconButton(
                          onPressed: () async {
                            bool res = await addBarber(context, globals.token, int.parse(searchedBarbers[i].id));
                            if(res) {
                              setState(() {
                                searchedBarbers[i].hasAdded = true;
                              });
                              Flushbar(
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                flushbarStyle: FlushbarStyle.GROUNDED,
                                title: "Barber Added",
                                message: "You can now book an appointment with this barber",
                                duration: Duration(seconds: 2),
                              )..show(context);
                            }
                          },
                          color: Colors.green,
                          icon: Icon(LineIcons.plus),
                        ) : 
                        IconButton(
                          onPressed: () async {
                            bool res = await removeBarber(context, globals.token, int.parse(searchedBarbers[i].id));
                            if(res) {
                              setState(() {
                                searchedBarbers[i].hasAdded = false;
                              });
                              Flushbar(
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                flushbarStyle: FlushbarStyle.GROUNDED,
                                title: "Barber Removed",
                                message: "This babrber has been removed from your list",
                                duration: Duration(seconds: 2),
                              )..show(context);
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
              valueColor: new AlwaysStoppedAnimation<Color>(globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400]),
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
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  progressHUD();
                  var res = await getBarberPolicies(context, int.parse(suggestedBarbers[i].id));
                  progressHUD();
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
                  barber.profilePicture = suggestedBarbers[i].profilePicture;
                  barber.headerImage = suggestedBarbers[i].headerImage;
                  // barber.created = suggestedBarbers[i].created;
                  final profileScreen = new BarberProfileV2Screen(token: globals.token, userInfo: barber, barberPolicies: res);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));
                },
                child: Column(
                  children: <Widget> [
                    Container(
                      color: globals.darkModeEnabled ? Colors.black87 : Colors.white10,
                      child: ListTile(
                        leading: buildProfilePictures(context, suggestedBarbers[i].profilePicture, suggestedBarbers[i].username, 30.0),
                        subtitle: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            suggestedBarbers[i].shopName != null && suggestedBarbers[i].shopName != '' ?
                            Text(
                              suggestedBarbers[i].shopName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic
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
                                        child: RichText(
                                          softWrap: true,
                                          text: new TextSpan(
                                            children: <TextSpan> [
                                              new TextSpan(text: suggestedBarbers[i].name+' ', style: TextStyle(fontWeight: FontWeight.bold, color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                              new TextSpan(text: '@'+suggestedBarbers[i].username, style: TextStyle(fontSize: 12,color: Colors.grey)),
                                            ]
                                          )
                                        )
                                      ),
                                    ),
                                  ]
                                )
                              )
                            ),
                          ]
                        ),
                        trailing: globals.token == int.parse(suggestedBarbers[i].id) ? Container(child:Text('')) : !suggestedBarbers[i].hasAdded ? IconButton(
                          onPressed: () async {
                            bool res = await addBarber(context, globals.token, int.parse(suggestedBarbers[i].id));
                            if(res) {
                              Flushbar(
                                flushbarPosition: FlushbarPosition.BOTTOM,
                                flushbarStyle: FlushbarStyle.GROUNDED,
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
                                flushbarStyle: FlushbarStyle.GROUNDED,
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

  setupChecks() {
    if(globals.spPayoutId == null || packages.length == 0) {
      return ExpandableNotifier(
        child: Card(
          child: Column(
            children: <Widget>[
              Expandable(
                collapsed: ExpandableButton(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(0.0, -8.0),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[400], Colors.grey[50]]
                      )
                    ),
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
                                new TextSpan(text: 'Actions Required ', style: new TextStyle(fontWeight: FontWeight.bold, color: globals.darkModeEnabled ? Colors.blue : Colors.blue[700])),
                              ]
                            )
                          )
                        ),
                        Icon(Icons.arrow_drop_down, color: globals.darkModeEnabled ? Colors.blue : Colors.blue[700])
                      ],
                    ),
                  ),
                ),
                expanded: Column(
                  children: <Widget>[
                    ExpandableButton(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: new LinearGradient(
                            begin: Alignment(0.0, -8.0),
                            colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[400], Colors.grey[50]]
                          )
                        ),
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
                                    new TextSpan(text: 'Actions Required', style: new TextStyle(fontWeight: FontWeight.bold, color: globals.darkModeEnabled ? Colors.blue : Colors.blue[700])),
                                  ]
                                )
                              )
                            ),
                            Icon(Icons.arrow_drop_up, color: globals.darkModeEnabled ? Colors.blue : Colors.blue[700])
                          ],
                        ),
                      ),
                    ),
                    new Container(
                      decoration: BoxDecoration(
                        gradient: new LinearGradient(
                          begin: Alignment(0.0, -6.0),
                          colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[400], Colors.grey[50]]
                        ),
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
                          globals.spPayoutId == null ? new GestureDetector(
                            onTap: () {
                              final mobileTransaction = new MobileTransactionSetup();
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => mobileTransaction));
                            },
                            child: RichText(
                              softWrap: true,
                              text: new TextSpan(
                                children: <TextSpan> [
                                  new TextSpan(text: 'Connect Direct Deposit: ', style: TextStyle(color: globals.darkModeEnabled ? Colors.blue : Colors.blue[700])),
                                  new TextSpan(text: 'required before taking any appointments.', style: TextStyle(fontStyle: FontStyle.italic, color: globals.darkModeEnabled ? Colors.grey : Colors.black54)),
                                ]
                              )
                            )
                           ) : Container(),
                          Padding(padding: EdgeInsets.all(5)),
                          packages.length == 0 ? new GestureDetector(
                            onTap: () async {
                              showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                                return AddPackageBottomSheet(
                                  updatePackages: (value) {
                                    setState(() {
                                      packages = value;
                                    });
                                  },
                                );
                              });
                            },
                            child: RichText(
                              softWrap: true,
                              text: new TextSpan(
                                children: <TextSpan> [
                                  new TextSpan(text: 'Add Services: ', style: TextStyle(color: globals.darkModeEnabled ? Colors.blue : Colors.blue[700])),
                                  new TextSpan(text: 'required before taking any appointments.', style: TextStyle(fontStyle: FontStyle.italic, color: globals.darkModeEnabled ? Colors.grey : Colors.black54)),
                                ]
                              )
                            )
                           ) : Container()
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

  showAddManualAppointment(DateTime selectedDate) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return AddManualAppointmentModal(
        selectedDate: selectedDate,
        packages: packages,
        appointments: _events,
        updateAppointmentList: (value) {
          setState(() {
            _events = value;
          });
          print(_events);
        },
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
        showManualAddAppointment: (value) {
          showAddManualAppointment(value);
        },
      );
    });
  }

  showAppointmentOptions(var appointment) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return AppointmentOptionsBottomSheet(
        appointment: appointment,
        updateAppointments: (value) {
          setState(() {
            _events = value;
          });
        },
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
              return new Padding(padding: EdgeInsets.all(8),);
            }else {
              final i = index ~/ 2;
              Color statusColor;
              if(_selectedEvents[i]['status'] == 0){
                var time = _selectedEvents[i]['full_time'];
                if(DateTime.now().isAfter(DateTime.parse(time))) {
                  statusColor = Colors.grey;
                }else {
                  statusColor = Colors.blue;
                }
              }else if(_selectedEvents[i]['status'] == 1){
                statusColor = Colors.green;
              }else if(_selectedEvents[i]['status'] == 2){
                statusColor = Colors.red;
              }else if(_selectedEvents[i]['status'] == 4){
                statusColor = Colors.indigo;
              }
              return GestureDetector(
                onTap: () {
                  showAppointmentOptions(_selectedEvents[i]);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            buildProfilePictures(context, _selectedEvents[i]['client_pp'], _selectedEvents[i]['clientid'] == 0 ? _selectedEvents[i]['manual_client_name'] : _selectedEvents[i]['name'], 30),
                            Padding(padding: EdgeInsets.all(5)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      constraints: new BoxConstraints(
                                        maxWidth: 100
                                      ),
                                      child: Text(
                                        _selectedEvents[i]['clientid'] == 0 ? _selectedEvents[i]['manual_client_name'] : _selectedEvents[i]['name'],
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)
                                      )
                                    ),
                                    Padding(padding: EdgeInsets.all(5)),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 1, top: 1, right: 6, left: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                      child: Text(
                                        statusColor == Colors.grey ? 'Pending' : statusColor == Colors.blue ? 'Upcoming' : statusColor == Colors.green ? 'Completed' : statusColor == Colors.indigo ? 'No-Show' : 'Cancelled',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        )
                                      )
                                    )
                                  ]
                                ),
                                Text(_selectedEvents[i]['package']),
                                Text('\$' + (_selectedEvents[i]['price'] + (_selectedEvents[i]['tip'])).toString()),
                              ]
                            ),
                          ]
                        )
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                              decoration: BoxDecoration(
                                color: globals.darkModeEnabled ? Colors.grey[700] : Colors.grey[300],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                              child: Text(_selectedEvents[i]['time'], style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: globals.darkModeEnabled ? Colors.white : Colors.black))
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
                  showFullPackageList(value);
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

  barberPolicies() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(LineIcons.times, color: globals.darkModeEnabled ? Colors.white : Colors.black),
            Padding(padding: EdgeInsets.all(5)),
            policies.cancelEnabled ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Cancellation Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                Text('Fee Amount: ${policies.cancelFee}'),
                Text('Within: ${policies.cancelWithinTime} Hour')
              ]
            ) :
            Text('No Cancellation Policy', style: TextStyle(fontWeight: FontWeight.bold))
          ]
        ),
        Divider(
          color: Colors.grey
        ),
        Row(
          children: <Widget>[
            Icon(LineIcons.minus, color: globals.darkModeEnabled ? Colors.white : Colors.black),
            Padding(padding: EdgeInsets.all(5)),
            policies.noShowEnabled ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No-Show Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                ),
                Text('Fee Amount: ${policies.noShowFee}'),
              ]
            ) :
            Text('No No-Show Policy', style: TextStyle(fontWeight: FontWeight.bold))
          ]
        ),
      ]
    );
  }

  // barberDBAvailability(BuildContext context) {
  //   return new Column(
  //     children: <Widget>[
  //       ListView.builder(
  //         physics: NeverScrollableScrollPhysics(),
  //         shrinkWrap: true,
  //         itemCount: availability.length,
  //         itemBuilder: (context, i){
  //           final todayDay = DateFormat.EEEE().format(DateTime.now());
  //           bool isNull = false;
  //           String start;
  //           String end;
  //           final df = new DateFormat('h:mm a');
  //           if(availability[i].start != null && availability[i].end != null) {
  //             if(availability[i].start == '0:00:00' && availability[i].end == '0:00:00') {
  //               isNull = true;
  //             }else {
  //               start = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].start).toString()));
  //               end = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].end).toString()));
  //             }
  //           }else {
  //             isNull = true;
  //           }
  //           return Container(
  //             margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: <Widget>[
  //                 Row(
  //                   children: <Widget>[
  //                     todayDay == availability[i].day ? Container(height: 5.0, width: 5.0, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),) : Container(height: 5.0, width: 5.0),
  //                     Padding(padding: EdgeInsets.all(5.0),),
  //                     Text(availability[i].day, style: TextStyle(fontSize: 18.0)),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: <Widget>[
  //                     GestureDetector(
  //                       onTap: () {
  //                         showSetAvailableTime(context, availability[i]);
  //                       },
  //                       child: Text(
  //                         isNull ? 'Closed' : start + " - " + end,
  //                         style: TextStyle(
  //                           fontSize: 17.0
  //                         ),
  //                       )
  //                     ),
  //                   ],
  //                 )
  //               ],
  //             )
  //           );
  //         },
  //       )
  //     ],
  //   );
  // }

  _onAvailabilityDaySelect(DateTime day, List aDay) {
    if(DateTime.parse(DateFormat('yyyy-MM-dd').format(day)).isBefore(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))) {
      showErrorDialog(context, "Cannot Edit Availability", "This date has passed");
    }else {
      showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
        bool isClosedChecked;
        if(aDay.length > 0) {
          if(aDay.first['closed'] == 1){
            isClosedChecked = true;
          }else {
            isClosedChecked = false;
          }
        }else {
          aDay.add({'date': day, 'start': '09:00:00', 'end': '17:00:00', 'closed': 0});
          isClosedChecked = false;
        }
        return AvailabilityV2BottomSheet(
          switchValue: isClosedChecked,
          avail: aDay,
          valueChanged: (value) {
            setState(() {
              isClosedChecked = value;
            });
          },
          getAvailability: (avail) {
            setState(() {
              availabilityV2 = avail;
            });
            for(var item in availabilityV2) {
              DateTime date = DateTime.parse(DateFormat('yyyy-MM-dd').format(item.date));
              setState(() {
                _availability[date] = [{'date': item.date, 'start': item.start, 'end': item.end, 'closed': item.closed}];
              });
            }
          },
        );
      });
    }
  }

  barberDBAvailability(BuildContext context) {
    return TableCalendar(
      locale: 'en_US',
      events: _availability,
      onDaySelected: _onAvailabilityDaySelect,
      availableGestures: AvailableGestures.horizontalSwipe,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black),
        weekendStyle: TextStyle(color: globals.darkModeEnabled ?  Color(0xFFf2f2f2) : Colors.black)
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.blue),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.blue)
      ),
      calendarStyle: CalendarStyle(
        weekendStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
        outsideWeekendStyle: TextStyle(color: Color(0xFF9E9E9E))
      ),
      headerVisible: true,
      calendarController: _calendarAvailabilityController,
      initialSelectedDay: DateTime.now(),
      initialCalendarFormat: CalendarFormat.twoWeeks,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationAvailabilityController),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[400] : Colors.transparent
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                ),
              )
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationAvailabilityController),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[400]
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
          var start = DateFormat('h').format(DateTime.parse(DateFormat('Hms', 'en_US').parse(events.first['start']).toString()));
          var end = DateFormat('h').format(DateTime.parse(DateFormat('Hms', 'en_US').parse(events.first['end']).toString()));

          if (events.isNotEmpty) {
            children.add(
              AnimatedContainer(
                margin: EdgeInsets.only(top: 29, left: 2),
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                  color: globals.darkModeEnabled ? Colors.blue[700] : Colors.lightBlue
                ),
                width: 46.0,
                height: 20.0,
                child: Center(
                  child: Text(
                    events.first['closed'] == 0 ? '$start-$end' : 'Closed',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle().copyWith(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              )
            );
          }
          return children;
        },
      ),
    );
  }

  Widget dashboardTab() {
    return Container(
      child: new RefreshIndicator(
        color: Colors.blue,
        onRefresh: refreshDashboardList,
        key: refreshKey2,
        child: SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              setupChecks(),
              appointmentReq.length > 0 ? 
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                    return AppointmentRequestBottomSheet(
                      requests: appointmentReq,
                      updateAppointments: (value) {
                        setState(() {
                          _events = value;
                        });
                      },
                      updateAppointmentRequests: (value) {
                        setState(() {
                          appointmentReq = value;
                        });
                      }
                    );
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(left: 5, right: 20, bottom: 5, top: 5),
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                      begin: Alignment(0.0, -2.0),
                      colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[400], Colors.grey[50]]
                    )
                  ),
                  margin: EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Appointment Requests', style: TextStyle(fontWeight: FontWeight.w400)),
                      Container(
                        padding: EdgeInsets.all(9),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400]
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
                    begin: Alignment(0.0, -5.0),
                    colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[600], Colors.grey[50]]
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
                            weekdayStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black),
                            weekendStyle: TextStyle(color: globals.darkModeEnabled ?  Color(0xFFf2f2f2) : Colors.black)
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            leftChevronIcon: Icon(Icons.chevron_left, color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400]),
                            rightChevronIcon: Icon(Icons.chevron_right, color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400])
                          ),
                          calendarStyle: CalendarStyle(
                            weekendStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
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
                                    color: globals.darkModeEnabled ? Colors.blue[500] : Colors.lightBlueAccent[400]
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
                                    color: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[400]
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
                          top: MediaQuery.of(context).size.width * .046,
                          child: GestureDetector(
                            onTap: () {
                              showFullCalendar();
                            },
                            child: Icon(Icons.menu, color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400])
                          )
                        ),
                      ]
                    ),
                    buildAppointmentList()
                  ]
                )
              ),
              // Container(
              //   margin: EdgeInsets.only(left: 5.0, top: 10),
              //   child: Text(
              //     'Services',
              //     style: TextStyle(
              //       fontSize: 17.0,
              //       fontWeight: FontWeight.w400,
              //     )
              //   )
              // ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(5.0),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                    begin: Alignment(0.0, -5.0),
                    colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[500], Colors.grey[50]]
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
                              'Services',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w400
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(2),),
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.all(7),
                              child: Center(child: Text(packages.length.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
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
                                child: Icon(Icons.menu, color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400])
                              )
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5, right: 10.0),
                              child: GestureDetector(
                                onTap: () async {
                                  showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                                    return AddPackageBottomSheet(
                                      updatePackages: (value) {
                                        setState(() {
                                          packages = value;
                                        });
                                      },
                                    );
                                  });
                                },
                                child: Icon(LineIcons.plus, color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400])
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
                            return new GestureDetector(
                              onTap: () {
                                showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                                  return PackageOptionsBottomSheet(
                                    package: packages[i],
                                    updatePackages: (value) {
                                      setState(() {
                                        packages = value;
                                      });
                                    },
                                    showPackagesList: (value) {

                                    },
                                  );
                                });
                              },
                              child: ListTile(
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
                                            color: globals.darkModeEnabled ? Colors.grey[900] : Colors.grey[300],
                                            shape: BoxShape.circle
                                          ),
                                        )
                                      ],
                                    )
                                  ]
                                )
                              )
                            );
                          }
                        }
                      )
                    )
                  ],
                )
              ),
              // Container(
              //   margin: EdgeInsets.only(left: 5.0, top: 10),
              //   child: Text(
              //     'Policies',
              //     style: TextStyle(
              //       fontSize: 17.0,
              //       fontWeight: FontWeight.w400,
              //     )
              //   )
              // ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(5.0),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                    begin: Alignment(0.0, -5.0),
                    colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[500], Colors.grey[50]]
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
                            fontWeight: FontWeight.w400
                          )
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 5, right: 10.0),
                          child: GestureDetector(
                            onTap: () async {
                              showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                                return BarberPoliciesModal(
                                  policies: policies ?? new BarberPolicies(),
                                  setPolicies: (value) {
                                    setState(() {
                                      policies = value;
                                    });
                                  },
                                );
                              });
                            },
                            child: Icon(LineIcons.pencil, color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400])
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
              // Container(
              //   margin: EdgeInsets.only(left: 5.0, top: 10),
              //   child: Text(
              //     'Availability',
              //     style: TextStyle(
              //       fontSize: 17.0,
              //       fontWeight: FontWeight.w400,
              //     )
              //   )
              // ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(5.0),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                    begin: Alignment(0.0, -5.0),
                    colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[900]] : [Colors.grey[500], Colors.grey[50]]
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Availability',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400
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
      )
    );
  }

  Future<Null> refreshDashboardList() async {
    Completer<Null> completer = new Completer<Null>();
    refreshKey2.currentState.show();
    var p = await getBarberPkgs(context, globals.token);
    final sd = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())));
    var e = await getBarberAppointments(context, globals.token);
    var se = e[sd] ?? [];
    var a = await getBarberAvailability(context, globals.token);
    var ar = await getBarberAppointmentRequests(context, globals.token);
    var po = await getBarberPolicies(context, globals.token) ?? new BarberPolicies();
    checkNotificiations();
    completer.complete();
    setState(() {
      packages = p;
      _events = e;
      _selectedEvents = se;
      availability = a;
      appointmentReq = ar;
      policies = po;
    });
    return completer.future;
  }

  Future<Null> refreshFeedList() async {
   Completer<Null> completer = new Completer<Null>();
    refreshKey.currentState.show();
    var results = await getPosts(context, globals.token, 1);
    completer.complete();
    setState(() {
      feedItems = results;
    });
    return completer.future;
  }

  feedList() {
    if (feedItems.length > 0) {
      return new RefreshIndicator(
        color: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400],
        onRefresh: refreshFeedList,
        key: refreshKey,
        child: new ListView.builder(
          itemCount: feedItems.length,
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context, i) {
            return Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          feedItems[i].imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: globals.darkModeEnabled ? Color.fromRGBO(21, 21, 21, 0.6) : Color.fromRGBO(100, 100, 100, 0.3),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)
                          )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                progressHUD();
                                var res = await getUserDetailsPost(feedItems[i].userId, context);
                                var res2 = await getBarberPolicies(context, feedItems[i].userId);
                                progressHUD();
                                final profileScreen = new BarberProfileV2Screen(token: feedItems[i].userId, userInfo: res, barberPolicies: res2);
                                Navigator.push(context, new MaterialPageRoute(builder: (context) => profileScreen));
                              },
                              child: Row(
                                children: <Widget>[
                                  buildProfilePictures(context, feedItems[i].profilePic, feedItems[i].username, 20),
                                  Padding(padding: EdgeInsets.all(5)),
                                  Text(
                                    feedItems[i].name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    )
                                  )
                                ]
                              )
                            ),
                            Row(
                              children: <Widget>[
                                buildTimeAgo(feedItems[i].created.toLocal().toString()),
                                // IconButton(
                                //   onPressed: () {

                                //   },
                                //   icon: Icon(Icons.more_horiz)
                                // )
                              ]
                            )
                          ]
                        )
                      ),
                    ]
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  feedItems[i].caption != null &&  feedItems[i].caption != '' ? Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: RichText(
                      softWrap: true,
                      text: new TextSpan(
                        children: <TextSpan> [
                          new TextSpan(text: feedItems[i].username+' ', style: TextStyle(fontWeight: FontWeight.bold, color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                          new TextSpan(text: feedItems[i].caption, style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                        ]
                      )
                    )
                  ) : Container()
                ]
              )
            );
          },
        ),
      );
    }else {
      return new RefreshIndicator(
        color: globals.darkModeEnabled ? Colors.white : globals.userColor,
        onRefresh: refreshFeedList,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
            new Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: new Text(
                "Follow a barber to start viewing cuts",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * .018,
                  color: Colors.grey[600]
                )
              ),
            ),
          ],
        )
      );
    }
  }

  Widget feedTab() {
    return new Container(
      child: Column(
        children: <Widget>[
          new Container(
            margin: EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width,
            color: globals.darkModeEnabled ? Colors.black45 : Colors.white10,
            child: new FlatButton(
              padding: EdgeInsets.all(0),
              textColor: Colors.blue,
              child: Text('Book Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
              onPressed: () async {
                progressHUD();
                var barberList = await getUserBarbers(context, globals.token);
                progressHUD();
                final selectBarberScreen = new SelectBarberScreen(clientBarbers: barberList, selectedEvents: _selectedEvents, packages: packages, events: _events, availability: availability, appointmentReq: appointmentReq, policies: policies); 
                Navigator.push(context, new MaterialPageRoute(builder: (context) => selectBarberScreen));
              },
            )
          ),
          Expanded(
            child: feedList() 
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(widget.widgetItem == 0){
      return new DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
          // floatingActionButton: new Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: <Widget>[
          //     new Container(
          //       child: new FloatingActionButton(
          //         onPressed: () async {
          //           var cameras = await availableCameras();
          //           final cameraScreen = new CameraApp(uploadType: 2, cameras: cameras, selectedEvents: _selectedEvents, packages: packages, events: _events, availability: availability, appointmentReq: appointmentReq, policies: policies);
          //           Navigator.push(context, new MaterialPageRoute(builder: (context) => cameraScreen));
          //         },
          //         child: new Icon(LineIcons.plus),
          //         tooltip: "Add",
          //         backgroundColor: globals.darkModeEnabled ? Colors.blue : Colors.lightBlueAccent[400],
          //         foregroundColor: Colors.white,
          //         heroTag: null,
          //       )
          //     ),
          //   ]
          // ),
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text('Home', textAlign: TextAlign.center,),
            actions: <Widget>[
              Badge(
                showBadge: badgeNotifications == 0 ? false : true,
                badgeContent: Text(badgeNotifications.toString(), style: TextStyle(color: Colors.white)),
                position: BadgePosition.topLeft(top:0, left: 7),
                animationType: BadgeAnimationType.scale,
                animationDuration: const Duration(milliseconds: 300),
                child: IconButton(
                  onPressed: () async {
                    final notificationScreen = new NotificationScreen(selectedEvents: _selectedEvents, packages: packages, events: _events, availability: availability, appointmentReq: appointmentReq, policies: policies);
                    var result = await Navigator.push(context, new MaterialPageRoute(builder: (context) => notificationScreen));
                    if(result == null) {
                      setState(() {
                        badgeNotifications = 0;
                      });
                    }
                  },
                  icon: Icon(LineIcons.bell, size: 25.0),
                ) 
              ),
              Badge(
                child: IconButton(
                  onPressed: () async {
                    var cameras = await availableCameras();
                    final cameraScreen = new CameraApp(uploadType: 2, cameras: cameras, selectedEvents: _selectedEvents, packages: packages, events: _events, availability: availability, appointmentReq: appointmentReq, policies: policies);
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => cameraScreen));
                  },
                  icon: Icon(LineIcons.plus, size: 25.0),
                )
              )
            ],
            bottom: TabBar(
              indicatorColor: globals.darkModeEnabled ? Colors.white : Colors.black,
              tabs: <Widget>[
                Tab(text: "Dashboard"),
                Tab(text: "Feed")
              ],
            ),
          ),
          body: new WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: new Stack(
              children: <Widget> [
                TabBarView(
                  children: <Widget>[
                    dashboardTab(),
                    feedTab()
                  ],
                ),
                _progressHUD
              ]
            )
          )
        )
      );
    }else if(widget.widgetItem == 1){
      return new Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          title: Text('Marketplace'),
          actions: <Widget>[
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
            )
          ],
        ),
        body: new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new Stack(
            children: <Widget> [
              Container(
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
              ),
              _progressHUD
            ]
          )
        )
      );
    }else if(widget.widgetItem == 2){
      return new DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
          appBar: new AppBar(
            automaticallyImplyLeading: false,
            title: TextField(
              focusNode: _searchFocus,
              autofocus: false,
              controller: _search,
              onChanged: (val) {
                searchStreamController.add(val);
              },
              autocorrect: false,
              textInputAction: TextInputAction.done, 
              decoration: new InputDecoration(
                prefixIcon: Icon(LineIcons.search, color: Colors.grey),
                contentPadding: EdgeInsets.all(8.0),
                hintText: 'Search',
                fillColor: globals.darkModeEnabled ? Colors.grey[900] : Colors.grey[100],
                filled: true,
                hintStyle: TextStyle(
                  color: Colors.grey
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
            ),
            bottom: TabBar(
              onTap: (index) async {
                if(index == 0) {
                  setState(() {
                    searchTabIndex = 0;
                  });
                }else {
                  setState(() {
                    searchTabIndex = 1;
                  });
                }
              },
              indicatorColor: globals.darkModeEnabled ? Colors.white : Colors.black,
              tabs: <Widget>[
                Tab(text: "Barbers"),
                Tab(text: "Marketplace")
              ],
            ),
          ),
          body: new WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: new Stack(
              children: <Widget> [
                TabBarView(
                  children: <Widget>[
                    barberTab(),
                    marketplaceTab()
                  ],
                ),
                _progressHUD
              ]
            )
          )
        )
      );
    }else {
      return new Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          title: Text('Settings'),
        ),
        body: new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new Stack(
            children: <Widget> [
              SettingsTab(),
              _progressHUD
            ]
          )
        )
      );
    }
  }
}