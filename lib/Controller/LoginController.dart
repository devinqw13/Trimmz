import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import '../globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import '../calls.dart';
import '../dialogs.dart';
import 'HomeHubController.dart';
import 'package:flutter/services.dart';
import 'BarberHubController.dart';
import 'RegisterController.dart';
import 'dart:ui';

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

   @override
  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.blue,
      containerColor: Colors.transparent,
      borderRadius: 8.0,
      //text: "Loading...",
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

  callLoginPost(String url, Map jsonData, bool retry, BuildContext context) async {
    Map results = await loginPost(url, jsonData, context);
    if (results.length == 0) {
      progressHUD();
      return;
    }
    processLogin(results, jsonData, retry);
  }

  void processLogin(Map results, Map jsonData, bool retry) async {
    var status = results['error'];

    switch (status) {
      case true:
        progressHUD();
        showOkDialog(context, "Login failed. Please verify username and password are correct.");
        break;
      case false:
        globals.LoginUser user = new globals.LoginUser();
        user.token = results['user']['id'];
        user.username = results['user']['username'];
        user.userEmail = results['user']['email'];
        user.userAdmin = results['user']['type'] == 3 ? true : false;
        user.userType = results['user']['type'];

        globals.user = user;
        globals.token = user.token;
        globals.username = user.username;
        globals.userAdmin = user.userAdmin;
        globals.userType = user.userType;
        print(globals.userType);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? true : prefs.getBool('darkModeEnabled');
        if (globals.darkModeEnabled) {
          globals.userBrightness = Brightness.dark;
          globals.userColor = Color.fromARGB(255, 20, 20, 20); //31
        }
        else {
          globals.userBrightness = Brightness.light;
          globals.userColor = Color.fromARGB(255, 255, 255, 255);
        }

        prefs.setInt('userToken', globals.user.token);
        prefs.setString('userUsername', globals.user.username);
        prefs.setString('userUserEmail', globals.user.userEmail);
        prefs.setBool('userIsAdmin', globals.user.userAdmin);
        prefs.setInt('userType', globals.user.userType);

        progressHUD();
        if(globals.userType == 1 || globals.userType == 3) {
          final homeHubScreen = new HomeHubScreen();
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => homeHubScreen));
        }else if(globals.userType == 2){
          final barberHubScreen = new BarberHubScreen();
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => barberHubScreen));
        }
      break;
    }
  }

  void normalLogin(String user, String pass) async {
    if (pass != "") {
      progressHUD();
      currentContext = context;
      //var deviceInfo = await getDeviceDetails();
      callLoginPost('${globals.baseUrl}login/', {'username': user, 'password': pass, /*'device_id': deviceInfo[2]*/}, false, context);
      progressHUD();
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
      padding: const EdgeInsets.only(top: 160.0, left: 32.0, right: 32.0),
      margin: EdgeInsets.only(top: 50.0),
      // width: 100.0,
      // height: 100.0,
      // decoration: new BoxDecoration(
      //   image: new DecorationImage(
      //     image: new AssetImage('images/trimmz_icon.png'),
      //     fit: BoxFit.fill,
      //   ),
      // )
      child: new Text(
        'Trimmz',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30.0,
          fontWeight: FontWeight.w400
        ),
      )
    );

    Widget usernameTextField() {
      return new Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                  hintStyle: TextStyle(color: Colors.white70)
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
      child: new TextField(
        controller: _passwordController,
        obscureText: true,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        onSubmitted: (value) {
          _handleSubmitted(_usernameController.text, _passwordController.text, context);
        },
        style: new TextStyle(
          fontSize: 18.0,
          color: Colors.white
        ),
        decoration: new InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.white),
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.white70),
          border: new UnderlineInputBorder(
            borderSide: new BorderSide(
              color: Colors.white
            )
          )
        ),
      ),
    );

    Widget buildLoginButton() {
      return new GestureDetector(
        onTap: () {
          _handleSubmitted(_usernameController.text, _passwordController.text, context);
        },
        child: Container(
          padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
          constraints: const BoxConstraints(maxHeight: 45.0, minWidth: 200.0, minHeight: 45.0),
          width: MediaQuery.of(context).size.width * .85,
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
        //brightness: Brightness.dark,
      ),
      child: new Scaffold(
        resizeToAvoidBottomPadding: true,
        body: new Container(
          child: Stack(
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
                    filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: new Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: new BoxDecoration(
                        color: Colors.black.withOpacity(0.8)
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
                                        padding: const EdgeInsets.only(left: 12.0, bottom: 25.0),
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
                                        bottom: 25.0),
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
    );
  }
}