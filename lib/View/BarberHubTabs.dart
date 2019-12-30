import 'package:flutter/material.dart';
import '../View/Widgets.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/LoginController.dart';
import '../Model/FeedItems.dart';
import 'package:line_icons/line_icons.dart';

class BarberHubTabWidget extends StatefulWidget{
  final int widgetItem;
  BarberHubTabWidget(this.widgetItem);

  @override
  BarberHubTabWidgetState  createState() => BarberHubTabWidgetState ();
}

class BarberHubTabWidgetState extends State<BarberHubTabWidget> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey = new GlobalKey<RefreshIndicatorState>();
  Radius cardEdgeRadius;
  List<Image> imageList = new List<Image>();
  List<FeedItem> feedItems = [];

  Future<Null> refreshHomeList() async {
  //  Completer<Null> completer = new Completer<Null>();
  //   refreshKey.currentState.show();
  //   //var results = await getTimeline(context);
  //   var results = await getUserMoves(context);
  //   completer.complete();
  //   setState(() {
  //     userMoves = results;    
  //   });
  //   _buildTabBarViewContainer();
  //   return completer.future;
  }

  logout() async {
    final loginScreen = new LoginScreen();
    Navigator.push(context, new MaterialPageRoute(builder: (context) => loginScreen));
    //Navigator.of(context).popUntil(ModalRoute.withName('/'));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    //bool _ = await logout(context);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.widgetItem == 0){
      return new Container();
    }else if(widget.widgetItem == 1){
      return new Container(
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
      );
    }else if(widget.widgetItem == 2){
      return new Container();
    }else {
      return settingsWidget(context);
    }
  }
}