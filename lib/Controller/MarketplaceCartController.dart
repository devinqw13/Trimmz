import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:line_icons/line_icons.dart';

class MarketplaceCart extends StatefulWidget {
  MarketplaceCart({Key key}) : super (key: key);

  @override
  MarketplaceCartState createState() => new MarketplaceCartState();
}

class MarketplaceCartState extends State<MarketplaceCart> {

  void initState() {
    super.initState();
  }

  buildBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
          Text(
            'You do not have any items in your cart.',
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
      child: Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          title: new Text('Cart')
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