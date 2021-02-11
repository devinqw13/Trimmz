import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:async/async.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/FeedItemWidget.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/dialogs.dart';

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
  List<Widget> appBarWidgets = [];

  @override
  void initState() {
    _memoizer = AsyncMemoizer();
    _buildAppBarWidgets();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
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

  _buildAppBarWidgets() {
    var items = widget.dashboardItems.where((e) => e.clientConfig == "HOME_APPBAR");
    for(var item in items) {
      Widget icon = new Icon(
        IconData(
          int.parse(item.iconData),
          fontFamily: 'MaterialIcons'
        ),
        color: globals.darkModeEnabled ? Colors.white : darkBackgroundGrey
      );

      appBarWidgets.add(
        IconButton(
          padding: EdgeInsets.all(0),
          icon: icon,
          onPressed: () async {
            progressHUD();
            var microAppController = await buildMicroAppController(context, item);
            if (microAppController == null) {
              progressHUD();
              showErrorDialog(context, "An error has occurred", "Could not open '${item.name}'. Please try again.");
              return;
            }
            progressHUD();
            Navigator.push(context, new MaterialPageRoute(builder: (context) => microAppController));
          }
        )
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        brightness: globals.userBrightness,
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: new Text(
          "Welcome ${globals.user.name}",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 18.0
          ),
        ),
        actions: appBarWidgets,
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