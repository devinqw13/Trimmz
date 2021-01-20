import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/NotificationItem.dart';

class NotificationCenterController extends StatefulWidget {
  NotificationCenterController({Key key}) : super (key: key);

  @override
  NotificationCenterControllerState createState() => new NotificationCenterControllerState();
}

class NotificationCenterControllerState extends State<NotificationCenterController> {
  List<NotificationItem> notifications = [];
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  @override
  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      color: globals.darkModeEnabled ? lightBackgroundGrey : darkGrey,
      containerColor: globals.darkModeEnabled ? darkGrey : lightBackgroundGrey,
      borderRadius: 8.0,
      text: "Loading...",
      loading: false,
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

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.all(10),
      height: double.infinity,
      child: notifications.length > 0 ? SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Text(notifications[index].body);
              }
            )
          ]
        )
      ): Center(
        child: Text(
          "No Notifications",
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Notification Center",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new Stack(
                children: [
                  _buildScreen(),
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