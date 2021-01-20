import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/palette.dart';

class SelectUserBookAppointmentController extends StatefulWidget {
  final int token;
  SelectUserBookAppointmentController({Key key, this.token}) : super (key: key);

  @override
  SelectUserBookAppointmentControllerState createState() => new SelectUserBookAppointmentControllerState();
}

class SelectUserBookAppointmentControllerState extends State<SelectUserBookAppointmentController> {
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
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                color: globals.darkModeEnabled ? darkBackgroundGrey : Color.fromARGB(255, 232, 232, 232),
                borderRadius: BorderRadius.circular(50.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.white : Colors.black,
                  fontFamily: 'OpenSans',
                ),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none),
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: globals.darkModeEnabled ? Colors.white54 : Colors.black54,
                    fontFamily: 'OpenSans',
                  ),
                ),
              )
            ),
          ]
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
            "Book with",
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