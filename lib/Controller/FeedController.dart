import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:async/async.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/FeedItemWidget.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/Model/NotificationItem.dart';
import 'package:trimmz/Badge.dart';
import 'package:trimmz/Controller/NotificationCenterController.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:trimmz/Controller/ConversationController.dart';
import 'package:trimmz/helpers.dart';

class FeedController extends StatefulWidget {
  final List<DashboardItem> dashboardItems;
  FeedController({Key key, this.dashboardItems}) : super (key: key);

  @override
  FeedControllerState createState() => FeedControllerState();
}

class FeedControllerState extends State<FeedController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  AsyncMemoizer _memoizer;
  var refreshFeedKey = GlobalKey<RefreshIndicatorState>();
  List<NotificationItem> notifications = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    firebaseCloudMessagingListeners();
    initGetNotifications();
    _memoizer = AsyncMemoizer();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    super.initState();
  }
  
  initGetNotifications() async {
    var result = await getNotifications(context, globals.user.token);
    handleNotificationData(result);
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

  _fetchUserFeed() async {
    return this._memoizer.runOnce(() async {
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
                    color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(50, 0, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    border: Border.all(
                      color: CustomColors1.mystic.withAlpha(100)
                    )
                  ),
                  child: RippleButton(
                    splashColor: CustomColors1.mystic.withAlpha(100),
                    onPressed: () {
                      //TODO: Call action VALUE CHANGED
                      // onTapDownSearch();
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                      child: Center(
                        child: Text(
                          "Find people to follow",
                          style: TextStyle(
                            color: globals.darkModeEnabled ? Colors.white : Colors.black,
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
                    padding: EdgeInsets.all(0),
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
              return Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation(Colors.blue)
                )
              );
            }
            break;
          default:
            return null; 
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        brightness: globals.userBrightness,
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: new Text(
          "Welcome ${globals.user.name}!",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18.0
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(left: 8.0, right: 8.0),
            child: GestureDetector(
              child: Badge(
                widget: Icon(Icons.messenger_outline_outlined),
                count: notifications.where((e) => e.read == false).length
              ),
              onTap: () async {
                var results = await getCached("conversations");
                final messageController = new ConversationController(cachedConversations: results, screenHeight: MediaQuery.of(context).size.height);

                Navigator.push(context, new MaterialPageRoute(builder: (context) => messageController));
              },
            )
          ),

          Container(
            margin: EdgeInsets.only(left: 8.0, right: 8.0),
            child: GestureDetector(
              child: Badge(
                widget: Icon(Icons.notifications_none_sharp),
                count: notifications.where((e) => e.read == false).length
              ),
              onTap: () async {
                final notificationCenterController = new NotificationCenterController(notifications: notifications);
                await Navigator.push(context, new MaterialPageRoute(builder: (context) => notificationCenterController));

                for(var item in notifications) {
                  setState(() {
                    item.read = true;
                  });
                }
              },
            )
          )
        ],
        elevation: 0.0,
      ),
      body: Container(
        color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
        child: new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: _buildPhotoFeed()
                  ),
                ],
              ),
              _progressHUD
            ]
          )
        )
      )
    );
  }
}