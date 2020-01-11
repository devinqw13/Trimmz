import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../globals.dart' as globals;

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key key}) : super (key: key);

  @override
  NotificationScreenState createState() => new NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {

  buildBody() {
    return Container(
      child: Container()
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
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: new AppBar(
          title: new Text('Notifications')
        ),
        body: buildBody()
      )
    );
  }
}