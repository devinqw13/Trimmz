import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;

class ClientController extends StatefulWidget {
  ClientController({Key key}) : super (key: key);

  @override
  ClientControllerState createState() => new ClientControllerState();
}

class ClientControllerState extends State<ClientController> {
  
  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: new Text("Welcome ${globals.user.name}"),
        ),
        body: Container()
      )
    );
  }
}