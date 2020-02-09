import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import '../View/BarberHubTabs.dart';
import 'package:line_icons/line_icons.dart';
import 'package:progress_hud/progress_hud.dart';

class BarberHubScreen extends StatefulWidget {
  final Map message;
  BarberHubScreen({Key key, this.message}) : super (key: key);

  @override
  BarberHubScreenState createState() => new BarberHubScreenState();
}

class BarberHubScreenState extends State<BarberHubScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<Widget> _children = [
    BarberHubTabWidget(0),
    BarberHubTabWidget(1),
    BarberHubTabWidget(2),
    BarberHubTabWidget(3)
  ];
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  @override
  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
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

  void onNavTapTapped(int index) {
   setState(() {
     _currentIndex = index;
   });
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
      child: new Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          child: new WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: new Stack(
              children: <Widget>[
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
                _progressHUD
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
    );
  }
}