import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../globals.dart' as globals;
import '../Model/AdvancedSettings.dart';
import '../Calls/GeneralCalls.dart';

class AdvancedSettingsController extends StatefulWidget {
  AdvancedSettingsController({Key key}) : super (key: key);

  @override
  AdvancedSettingsControllerState createState() => new AdvancedSettingsControllerState();
}

class AdvancedSettingsControllerState extends State<AdvancedSettingsController> {
  AdvancedSettings settings = new AdvancedSettings();

  void initState() {
    super.initState();
    getAdvancedSet();
  }

  getAdvancedSet() async {
    var res = await getAdvancedSettings(context, globals.token);
    setState(() {
      settings = res;
    });
  }

  updateAdvanced() {
    var _ = updateAdvancedSettings(context, globals.token, settings);
  }

  buildBody() {
    return Container(
      child: Column(
        children: <Widget> [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    contentPadding: EdgeInsets.all(10),
                    activeColor: Colors.blue,
                    title: Text('Card Payments Only', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    subtitle: Text('Enable to set payments to card only', style: TextStyle(fontStyle: FontStyle.italic)),
                    value: settings.paymentOption,
                    onChanged: (value) {
                      setState(() {
                        settings.paymentOption = value;
                      });
                      updateAdvanced();
                    },
                  ),
                ]
              ),
            )
          )
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
          centerTitle: true,
          title: new Text('Advanced Settings')
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