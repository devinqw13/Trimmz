import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/NotificationItem.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trimmz/calls.dart';

class NotificationCenterController extends StatefulWidget {
  final List<NotificationItem> notifications;
  NotificationCenterController({Key key, this.notifications}) : super (key: key);

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

    readNotifications();
    
    notifications = widget.notifications;

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

  readNotifications() {
    var _ = setNotificationsRead(context, globals.user.token);
  }

  Widget _buildScreen() {
    return Container(
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
                return Slidable(
                  actionPane: SlidableStrechActionPane(),
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        buildSmallUserProfilePicture(context, notifications[index].profilePicture, notifications[index].fromUser),
                        Padding(padding: EdgeInsets.all(5)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifications[index].title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text(notifications[index].body)
                            ]
                          )
                        )
                      ]
                    )
                  ),
                  secondaryActions: [
                    IconSlideAction(
                      caption: 'Remove',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        var _ = removeNotification(context, globals.user.token, notifications[index].id);
                        setState(() {
                          notifications.removeAt(index);
                        });
                      },
                    ),
                  ]
                );
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
            "Notifications",
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