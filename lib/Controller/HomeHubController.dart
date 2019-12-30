import 'package:flutter/material.dart';
import '../Model/SuggestedBarbers.dart';
import '../globals.dart' as globals;
import '../palette.dart';
import '../View/HomeHubTabs.dart';
import 'package:line_icons/line_icons.dart';
import 'NotificationController.dart';
import 'package:badges/badges.dart';
import '../calls.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flushbar/flushbar.dart';
import '../Model/ClientBarbers.dart';
import 'BarberProfileController.dart';

class HomeHubScreen extends StatefulWidget {
  final int dashType;
  HomeHubScreen({Key key, this.dashType}) : super (key: key);

  @override
  HomeHubScreenState createState() => new HomeHubScreenState();
}

class HomeHubScreenState extends State<HomeHubScreen> {
  final TextEditingController _search = new TextEditingController();
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
  bool isSearching = false;
  int searchTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _search.addListener(() {
      if(_search.text.length > 0) {
        setState(() {
          
          isSearching = true;
        });
      }else {
        isSearching = false;
      }
    });

    initSuggestedBarbers();
  }

  void initSuggestedBarbers() async {
    var res = await getSuggestions(context, globals.token, 1);
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
                  var res = await getSuggestions(context, globals.token, 1);
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