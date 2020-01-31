import 'package:flutter/material.dart';
import '../View/Widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_icons/line_icons.dart';

class BarberHubTabWidget extends StatefulWidget{
  final int widgetItem;
  BarberHubTabWidget(this.widgetItem);

  @override
  BarberHubTabWidgetState  createState() => BarberHubTabWidgetState ();
}

class BarberHubTabWidgetState extends State<BarberHubTabWidget> with TickerProviderStateMixin {

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