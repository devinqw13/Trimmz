import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../globals.dart' as globals;
import '../Model/Notifications.dart';
import 'package:line_icons/line_icons.dart';
import '../functions.dart';
import '../calls.dart';
import '../View/SendNotificationModal.dart';
import '../View/AddNotificationRecipientsModal.dart';
import 'package:flushbar/flushbar.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key key}) : super (key: key);

  @override
  NotificationScreenState createState() => new NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  List<Notifications> notifications = [];

  void initState() {
    super.initState();

    setupNotifications();
  }

  setupNotifications() async {
    var res = await getAllNotifications(context, globals.token);
    setState(() {
      notifications = res;
    });
    for(var item in notifications) {
      if(item.read == false) {
        await setNotificationsRead(context, globals.token);
        break;
      }
    }
  }

  buildNotificationList() {
    return Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        itemCount: notifications.length,
        itemBuilder: (context, i) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                left: !notifications[i].read ? BorderSide(width: 3.0, color: Colors.blue) : BorderSide.none
              )
            ),
            margin: EdgeInsets.all(3),
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  width: 50.0,
                  height: 50.0,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple,
                    gradient: new LinearGradient(
                      colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                    )
                  ),
                  child: Center(child:Text('T', style: TextStyle(fontSize: 20))) //Text(searchedBarbers[i].name.substring(0,1), style: TextStyle(fontSize: 20)))
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(notifications[i].title, style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      width: MediaQuery.of(context).size.width * .75,
                      child: Text(notifications[i].message, softWrap: true),
                    ),
                    buildTimeAgo(notifications[i].created)
                  ]
                )
              ]
            )
          );
        },
      )
    );
  }

  sendNotification([var recipients]) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
      return SendNotificationModal(
        success: (value) {
          if(value) {
            Flushbar(
              flushbarPosition: FlushbarPosition.BOTTOM,
              title: "Announcement Sent",
              message: "Your announcement has been sent successfully",
              duration: Duration(seconds: 2),
            )..show(context);
          }
        },
        recipients: recipients,
        addRecipients: (value) {
          showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
            return AddNotificationRecipientsModal(
              recipients: value,
              showSendNotification: (value) {
                sendNotification(value);
              }
            );
          });
        },
      );
    });
  }

  buildBody() {
    return Container(
      child: Column(
        children: <Widget> [
          globals.userType == 2 ? Container(
            margin: EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width,
            color: Colors.black45,
            child: new FlatButton(
              padding: EdgeInsets.all(0),
              textColor: Colors.blue,
              child: Text('Send Annoucement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
              onPressed: () async {
                sendNotification();
              },
            )
          ) : Container(),
          notifications.length > 0 ?
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  buildNotificationList(),
                ],
              ),
            )
          ) : 
          Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
                  Text(
                    'You don\'t have any notifications.',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * .018,
                      color: Colors.grey[600]
                    )
                  ),
                ]
              )
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
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new Text('Notifications')
        ),
        body: new Stack(
          children: <Widget> [
            buildBody()
          ]
        )
      )
    );
  }
}