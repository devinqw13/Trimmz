import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import '../globals.dart' as globals;
import '../Calls/GeneralCalls.dart';
import '../dialogs.dart';
import 'HomeHubController.dart';
import 'package:flutter/services.dart';
import 'BarberHubController.dart';
import 'RegisterController.dart';
import 'dart:ui';
import '../functions.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';
import '../Model/BarberPolicies.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super (key: key);

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  BuildContext currentContext;
  bool showPassword = false;

   @override
  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
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

  callLoginPost(String username, String password, bool retry, BuildContext context) async {
    progressHUD();
    Map results = await loginPost(username, password, context);
    if (results.length == 0) {
      return;
    }
    progressHUD();
    processLogin(results, retry);
  }

  void processLogin(Map results, bool retry) async {
    var status = results['error'];
    switch (status) {
      case 'true':
        showOkDialog(context, "Login failed. Please verify username and password are correct.");
        break;
      case 'false':
        setGlobals(results);

        if(globals.userType == 1 || globals.userType == 3) {
          final homeHubScreen = new HomeHubScreen();
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => homeHubScreen));
        }else if(globals.userType == 2){
          progressHUD();
          var packages = await getBarberPkgs(context, globals.token);
          final _selectedDay = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())));
          var events = await getBarberAppointments(context, globals.token);
          var selectedEvents = events[_selectedDay] ?? [];
          var availability = [];
          // var availability = await getBarberAvailability(context, globals.token);
          var availabilityV2 = await getBarberAvailabilityV2(context, globals.token);
          var appointmentReq = await getBarberAppointmentRequests(context, globals.token);
          var policies = await getBarberPolicies(context, globals.token) ?? new BarberPolicies();
          progressHUD();

          final barberHubScreen = new BarberHubScreen(packages: packages, events: events, selectedEvents: selectedEvents, availability: availability, availabilityV2: availabilityV2, appointmentReq: appointmentReq, policies: policies);
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => barberHubScreen));
        }
      break;
    }
  }

  void normalLogin(String user, String pass) async {
    if (pass != "") {
      currentContext = context;
      callLoginPost(user, pass, false, context);
    } else {
      _openTextDialog("Please enter a valid password");
    }
  }

  void _handleSubmitted(String user, String pass, BuildContext context) async {
    normalLogin(user, pass);
  }

  void _openTextDialog(String text) {
    AlertDialog dialog = new AlertDialog(
      content: new SingleChildScrollView(
        child: new Text(text,
        textAlign: TextAlign.center
        ),
      ),
    );
    showDialog(context: context, builder: (context) => dialog, barrierDismissible: true);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Widget titleSection = new Container(
      padding: const EdgeInsets.only(top: 0, left: 32.0, right: 32.0),
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .08),
      child: new ClipRRect(
        borderRadius: new BorderRadius.circular(10.0),
        child: new Image.asset('images/trimmz_icon_t.png',
          height: MediaQuery.of(context).size.height * .22,
        )
      ),
    );

    Widget usernameTextField() {
      return new Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        width: MediaQuery.of(context).size.width * .80,
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                style: new TextStyle(
                  fontSize: 18.0,
                  color: Colors.white
                ),
                decoration: new InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  hintText: 'Username',
                  hintStyle: TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)
                  )
                ),
                onSubmitted: (newValue) {
                  FocusScope.of(context).requestFocus(_passwordController ?? new FocusNode());
                },
              ),
            ),
          ],
        )
      );
    }

    Widget passwordTextField = new Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      width: MediaQuery.of(context).size.width * .80,
      child: new TextField(
        controller: _passwordController,
        obscureText: showPassword ? false : true,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        onSubmitted: (value) {
          FocusScope.of(context).requestFocus(new FocusNode());
          if(_passwordController.text.length > 0){
            _handleSubmitted(_usernameController.text, _passwordController.text, context);
          }
        },
        style: new TextStyle(
          fontSize: 18.0,
          color: Colors.white
        ),
        decoration: new InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.white),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
            child: Icon(showPassword ? LineIcons.eye_slash : LineIcons.eye, color: Colors.white),
          ),
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.white70),
          border: new UnderlineInputBorder(
            borderSide: new BorderSide(
              color: Colors.white
            )
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue)
          )
        ),
      ),
    );

    Widget buildLoginButton() {
      return new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _handleSubmitted(_usernameController.text, _passwordController.text, context);
        },
        child: Container(
          padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
          constraints: const BoxConstraints(maxHeight: 45.0, minWidth: 200.0, minHeight: 45.0),
          width: MediaQuery.of(context).size.width * .75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: new LinearGradient(
              colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent],
            )
          ),
          child: Center(
            child: Text(
              'Login',
              style: new TextStyle(
                fontSize: 19.0,
                fontWeight: FontWeight.w300
              )
            )
          )
        )
      );
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarBrightness: Brightness.dark
    ));

    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hintColor: Colors.white70,
        brightness: Brightness.dark,
      ),
      child: new Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomPadding: true,
        body: new Container(
          child: new WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: new Stack(
              children: <Widget>[
                new ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: new Image.asset(
                    'images/barberBackground.png',
                    fit: BoxFit.cover,
                  )
                ),
                new Center(
                  child: new ClipRect(
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: new Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: new BoxDecoration(
                          color: Colors.black.withOpacity(0.85)
                        ),
                        child: new Stack(
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    titleSection
                                  ],
                                ),
                                new Column(
                                  children: <Widget>[
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Container(
                                          child: new Column(
                                            children: <Widget>[
                                              new Container(
                                                width: screenWidth * .9,
                                                child: new Column(
                                                  children: <Widget>[
                                                    usernameTextField(),
                                                    passwordTextField
                                                  ],
                                                )
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    buildLoginButton()
                                  ],
                                ),
                                new Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      new GestureDetector(
                                        onTap: () {/*_resetPasswordTapped();*/},
                                        child: new Container(
                                          padding: const EdgeInsets.only(left: 12.0, bottom: 10.0),
                                          child: new Text("Forgot Password?",
                                            style: new TextStyle(
                                              fontSize: 13.0,
                                              color: Colors.white
                                            ),
                                          ),
                                        ),
                                      ),
                                      new GestureDetector(
                                        onTap: () {
                                          final registerScreen = new RegisterScreen();
                                          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => registerScreen));
                                        },
                                        child: new Container(
                                          padding: const EdgeInsets.only(right: 12.0,
                                          bottom: 10.0),
                                          child: new Text("New User? Click Here",
                                            style: new TextStyle(
                                              fontSize: 13.0,
                                              color: Colors.white
                                            ),
                                          ),
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            _progressHUD
                        ]
                      )
                    ),
                  ),
                ),
              ),
            ],
          )
          )
        )
      )
    );
  }
}