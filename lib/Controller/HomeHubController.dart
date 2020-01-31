import 'package:flutter/material.dart';
import 'package:trimmz/Controller/MarketplaceCartController.dart';
import 'package:trimmz/View/Widgets.dart';
import '../Model/SuggestedBarbers.dart';
import '../globals.dart' as globals;
import '../View/HomeHubTabs.dart';
import 'package:line_icons/line_icons.dart';
import 'NotificationController.dart';
import 'package:badges/badges.dart';
import '../calls.dart';
import 'package:flushbar/flushbar.dart';
import '../Model/ClientBarbers.dart';
import 'BarberProfileV2Controller.dart';
import '../functions.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import 'AppointmentListController.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class HomeHubScreen extends StatefulWidget {
  final int dashType;
  HomeHubScreen({Key key, this.dashType}) : super (key: key);

  @override
  HomeHubScreenState createState() => new HomeHubScreenState();
}

class HomeHubScreenState extends State<HomeHubScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _search = new TextEditingController();
  StreamController<String> searchStreamController = StreamController();
  FocusNode _searchFocus = new FocusNode();
  int _currentIndex = 0;
  String _tabTitle = 'Home';
  List<Widget> _children = [
    HomeHubTabWidget(0),
    HomeHubTabWidget(1),
    HomeHubTabWidget(2),
    HomeHubTabWidget(3)
  ];
  int badgeCart = 0;
  int badgeNotifications = 0;
  List<SuggestedBarbers> suggestedBarbers = [];
  List<SuggestedBarbers> searchedBarbers = [];
  bool isSearching = false;
  int searchTabIndex = 0;

  @override
  void initState() {
    super.initState();

    searchStreamController.stream
    .debounce(Duration(milliseconds: 500))
    .listen((s) => _searchValue(s, searchTabIndex));

    initSuggestedBarbers();
    firebaseCloudMessagingListeners();
    checkNotificiations();
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
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['notification']['title'], message['notification']['body']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        await submitNotification(context, int.parse(message['sender']), int.parse(message['recipient']), message['notification']['title'], message['notification']['body']);
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
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
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: _tabTitle == 'Search' ? TextField(
              focusNode: _searchFocus,
              controller: _search,
              onChanged: (val) {
                searchStreamController.add(val);
              },
              autocorrect: false,
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
                Tab(text: "Barbers/Stylists"),
                Tab(text: "Marketplace")
              ],
            ) : null,
            actions: <Widget>[
              _tabTitle == "Home" ?
              Badge(
                showBadge: badgeNotifications == 0 ? false : true,
                badgeContent: Text(badgeNotifications.toString()),
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
              ): Text(''),
              _tabTitle == "Home" ?
              Badge(
                showBadge: false,
                child: IconButton(
                  onPressed: () {
                    final appointmentHistoryScreen = new AppointmentList();
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentHistoryScreen));
                  },
                  icon: Icon(Icons.calendar_today, size: 21.0),
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
            type: BottomNavigationBarType.fixed,
            backgroundColor: globals.userColor,
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