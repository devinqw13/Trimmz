import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Calls/GeneralCalls.dart';
import '../globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:expandable/expandable.dart';
import '../Controller/SelectBarberController.dart';
import 'package:line_icons/line_icons.dart';
import '../View/Widgets.dart';
import '../Model/Appointment.dart';
import 'package:intl/intl.dart';
import '../Model/FeedItems.dart';
import 'dart:async';
import '../functions.dart';
import '../Controller/BarberProfileV2Controller.dart';
import '../View/SettingsTab.dart';
import 'package:stream_transform/stream_transform.dart';
import '../Model/SuggestedBarbers.dart';
import 'package:flushbar/flushbar.dart';
import '../Model/ClientBarbers.dart';
import 'package:badges/badges.dart';
import '../Controller/MarketplaceCartController.dart';
import '../Controller/NotificationController.dart';
import '../Controller/AppointmentListController.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class HomeHubTabWidget extends StatefulWidget{
  final int widgetItem;
  HomeHubTabWidget(this.widgetItem);

  @override
  HomeHubTabWidgetState  createState() => HomeHubTabWidgetState ();
}

class HomeHubTabWidgetState extends State<HomeHubTabWidget> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey = new GlobalKey<RefreshIndicatorState>();
  Appointment upcomingAppointment;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<FeedItem> feedItems = [];
  bool isSearching = false;
  FocusNode _searchFocus = new FocusNode();
  int searchTabIndex = 0;
  final TextEditingController _search = new TextEditingController();
  StreamController<String> searchStreamController = StreamController();
  List<SuggestedBarbers> suggestedBarbers = [];
  List<SuggestedBarbers> searchedBarbers = [];
  int badgeCart = 0;
  int badgeNotifications = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void initState() {
    super.initState();
    initChecks();

    firebaseCloudMessagingListeners();
    initSuggestedBarbers();
    checkNotificiations();

    searchStreamController.stream
    .debounce(Duration(milliseconds: 0))
    .listen((s) => _searchValue(s, searchTabIndex));

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
        var res = await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['title'], message['body']);
        if(res) {
          checkNotificiations();
        }
      },
      onResume: (Map<String, dynamic> message) async {
        var res = await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['notification']['title'], message['notification']['body']);
        if(res) {
          checkNotificiations();
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        var res = await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['notification']['title'], message['notification']['body']);
        if(res) {
          checkNotificiations();
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

  checkNotificiations() async {
    var res = await getUnreadNotifications(context, globals.token);
    setState(() {
      badgeNotifications = res.length;
    });
  }

  initChecks() async {
    var res1 = await getUpcomingAppointment(context, globals.token);
    setState(() {
      upcomingAppointment = res1;
    });

    var res2 = await getPosts(context, globals.token, 1);
    setState(() {
      feedItems = res2;
    });
  }

  upcomingAlert() {
    if(upcomingAppointment != null){
      final df = new DateFormat('EEE, MMM d @ hh:mm a');
      String appointmentTime = df.format(DateTime.parse(upcomingAppointment.dateTime.toString()));
      return ExpandableNotifier(
        child: Card(
          child: Column(
            children: <Widget>[
              Expandable(
                collapsed: ExpandableButton(
                  child: Container(
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
                              style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                              children: <TextSpan> [
                                new TextSpan(text: 'Upcoming Appointment: ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                new TextSpan(text: appointmentTime),
                              ]
                            )
                          )
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ),
                expanded: Column(
                  children: <Widget>[
                    ExpandableButton(
                      child: Container(
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
                                  style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                                  children: <TextSpan> [
                                    new TextSpan(text: 'Upcoming Appointment', style: new TextStyle(fontWeight: FontWeight.bold)),
                                  ]
                                )
                              )
                            ),
                            Icon(Icons.arrow_drop_up)
                          ],
                        ),
                      ),
                    ),
                    new Container(
                      decoration: BoxDecoration(
                        color: globals.userBrightness == Brightness.light ? Color.fromARGB(255, 242, 242, 242) : Color.fromARGB(255, 42, 42, 42),
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
                          RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: new TextSpan(
                              style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                              children: <TextSpan> [
                                new TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: appointmentTime)
                              ]
                            )
                          ),
                          RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: new TextSpan(
                              style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                              children: <TextSpan> [
                                new TextSpan(text: 'Barber: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: upcomingAppointment.barberName)
                              ]
                            )
                          ),
                          RichText(
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            text: new TextSpan(
                              style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                              children: <TextSpan> [
                                new TextSpan(text: 'Location: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '${upcomingAppointment.locationAddress}, ${upcomingAppointment.geoAddress}')
                              ]
                            )
                          )
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

  Future<Null> refreshFeedList() async {
   Completer<Null> completer = new Completer<Null>();
    refreshKey.currentState.show();
    var results = await getPosts(context, globals.token, 1);
    checkNotificiations();
    completer.complete();
    setState(() {
      feedItems = results;
    });
    return completer.future;
  }

  feedList() {
    if (feedItems.length > 0) {
      return new RefreshIndicator(
        color: Colors.blue,
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
                                      fontWeight: FontWeight.bold
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
                  feedItems[i].caption != null && feedItems[i].caption != '' ? Container(
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
                onTap: () async {
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
                        trailing: !searchedBarbers[i].hasAdded ? IconButton(
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
              onTap: () async {
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
                      trailing: !suggestedBarbers[i].hasAdded ? IconButton(
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
                  )
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
            height:50,
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
    if(widget.widgetItem == 0){
      return Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Home'),
          actions: <Widget>[
            Badge(
              showBadge: badgeNotifications == 0 ? false : true,
              badgeContent: Text(badgeNotifications.toString(), style: TextStyle(color: Colors.white)),
              position: BadgePosition.topLeft(top:0, left: 7),
              animationType: BadgeAnimationType.scale,
              animationDuration: const Duration(milliseconds: 300),
              child: IconButton(
                onPressed: () async {
                  final notificationScreen = new NotificationScreen();
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
              showBadge: false,
              child: IconButton(
                onPressed: () {
                  final appointmentHistoryScreen = new AppointmentList();
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentHistoryScreen));
                },
                icon: Icon(Icons.calendar_today, size: 21.0),
              )
            ),
            Badge(
              showBadge: false,
              child: IconButton(
                onPressed: () {
                  final appointmentHistoryScreen = new AppointmentList();
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentHistoryScreen));
                },
                icon: Icon(Icons.chat_bubble_outline, size: 21.0),
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
              Column(
                children: <Widget>[
                  upcomingAlert(),
                  new Container(
                    margin: EdgeInsets.all(0),
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
                        final selectBarberScreen = new SelectBarberScreen(clientBarbers: barberList); 
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => selectBarberScreen));
                      },
                    )
                  ),
                  Expanded(
                    child: feedList()
                  )
                ],
              ),
              _progressHUD
            ]
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