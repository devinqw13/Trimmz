import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class AboutController extends StatefulWidget {
  AboutController({Key key}) : super (key: key);

  @override
  AboutControllerState createState() => new AboutControllerState();
}

class AboutControllerState extends State<AboutController> {
  String version;

  @override
  void initState() {
    super.initState();

    version = "1.0.0";
  }

  Widget buildPage() {
    return new Container(
      child: new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Column(
            children: <Widget>[
              new ClipRRect(
                borderRadius: new BorderRadius.circular(10.0),
                child: new Image.asset('images/trimmz_icon_t.png',
                  height: 200.0,
                )
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 20.0),
              ),
            ],
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 50.0),
          ),
          new Column(
            children: <Widget>[
              new Center(
                child: new Text("App Version: $version",
                  style: new TextStyle(
                    color: Colors.grey[800]
                  )
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 16.0),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 30.0)
              ),
              new Center(
                child: new Text("For support, please contact Trimmz support at:"),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 8.0)
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 8.0),
              ),
              new Center(
                child: new GestureDetector(
                  child: new Text("trimmzapp@gmail.com"),
                  onTap: () async {
                    String email = 'trimmzapp@gmail.com';
                    if (await canLaunch("mailto:$email")) {
                      await launch("mailto:$email?subject=Trimmz Support");
                    } else {
                      throw 'Could not launch';
                    }
                  }
                )
              )
            ],
          )
        ],
      ),
    );
  }

  /*_launchURL(String url) async {
    String encodedURL = Uri.encodeFull(url);
    if (await canLaunch(encodedURL)) {
      await launch(encodedURL);
    } else {
      print('could not launch $url');
    }
  }*/


  
  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.userColor,
        // accentColor: Colors.white,
        // unselectedWidgetColor: Colors.white,
        brightness: globals.userBrightness,
        // primaryColorBrightness: Brightness.dark,
        // accentColorBrightness: Brightness.light
      ),
      child: new Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          centerTitle: true,
          title: new Text("About"),
        ),
        body: buildPage()
      )
    );
  }
}