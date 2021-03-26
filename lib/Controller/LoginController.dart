import 'package:flutter/material.dart';
import 'package:trimmz/Controller/UserController.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/dialogs.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/Controller/ClientController.dart';
import 'package:trimmz/Model/SignupUser.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:circular_check_box/circular_check_box.dart';

class LoginController extends StatefulWidget {
  LoginController({Key key}) : super (key: key);

  @override
  LoginControllerState createState() => new LoginControllerState();
}

class LoginControllerState extends State<LoginController> with TickerProviderStateMixin {
  final TextEditingController userEmailTFController = new TextEditingController();
  final TextEditingController passwordTFController = new TextEditingController();
  final TextEditingController nameTFController = new TextEditingController();
  final TextEditingController emailTFController = new TextEditingController();
  final TextEditingController usernameTFController = new TextEditingController();
  final TextEditingController sPasswordTFController = new TextEditingController();
  final TextEditingController zipcodeTFController = new TextEditingController();
  final TextEditingController addressTFController = new TextEditingController();
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  SignupUser signupUser = new SignupUser();
  bool usernameValidating = false;
  bool usernameAccepted;
  StreamController<String> usernameStreamController = StreamController();
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: 2, vsync: this);

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    usernameStreamController.stream
    .debounce(Duration(milliseconds: 700))
    .listen((s) => _usernameValidate(s));
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

  void validatingInProcess() {
    setState(() {
      if(usernameValidating == null) {
        usernameValidating = true;
      }else {
        usernameValidating = !usernameValidating;
      }
    });
  }

  _usernameValidate(String s) async {
    if(s.length >= 3) {
      validatingInProcess();
      bool result = await validateUsername(context, 0, s);
      validatingInProcess();
      
      if(result) {
        setState(() {
          usernameAccepted = false;
        });
      }else {
        setState(() {
          usernameAccepted = true;
        });
      }
    }else {
      setState(() {
        usernameAccepted = false;
      });
    }
  }

  final kHintTextStyle = TextStyle(
    color: Colors.white54,
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: Color.fromARGB(110, 0, 0, 0), //Color(0xFF6CA8F1),
    borderRadius: BorderRadius.circular(10.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  _handleSubmit(String user, String password) async {
    if(password != "") {
      progressHUD();
      var results = await login(context, user, password);
      if(results.length == 0) {
        progressHUD();
        showErrorDialog(context, "Login Error", "Incorrect username or password. Try again;");
        return;
      }else {
        setGlobals(results);
        var dashboardItems = await getDashboardItems(globals.user.token, context);
        var appointments = await getAppointments(context, globals.user.token, globals.user.userType);
        progressHUD();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? true : prefs.getBool('darkModeEnabled');
        prefs.setBool('darkModeEnabled', globals.darkModeEnabled);
        prefs.setInt('token', globals.user.token);
        if (globals.darkModeEnabled) {
          globals.userBrightness = Brightness.dark;
        }else {
          globals.userBrightness = Brightness.light;
        }

        if(globals.user.userType == 1) {
          final clientController = new ClientController(dashboardItems: dashboardItems, appointments: appointments);
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => clientController));
        }else {
          final userController = new UserController(screenHeight: MediaQuery.of(context).size.height, dashboardItems: dashboardItems, appointments: appointments);
          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => userController));
        }
      }
    }else {
      showOkDialog(context, "Please enter a valid password");
    }
  }

  _handleSignup(SignupUser user) async {
    progressHUD();
    var results = await signupUserAPI(context, user);
    setGlobals(results);
    var dashboardItems = await getDashboardItems(globals.user.token, context);
    var appointments = await getAppointments(context, globals.user.token, globals.user.userType);
    progressHUD();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? true : prefs.getBool('darkModeEnabled');
    prefs.setBool('darkModeEnabled', globals.darkModeEnabled);
    prefs.setInt('token', globals.user.token);
    if (globals.darkModeEnabled) {
      globals.userBrightness = Brightness.dark;
    }else {
      globals.userBrightness = Brightness.light;
    }

    if(globals.user.userType == 1) {
      final clientController = new ClientController(dashboardItems: dashboardItems, appointments: appointments);
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => clientController));
    }else {
      final userController = new UserController(screenHeight: MediaQuery.of(context).size.height, dashboardItems: dashboardItems, appointments: appointments);
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => userController));
    }
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: userEmailTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Enter your username',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Name',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: nameTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'Name',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget usernameSuffixWidget() {
    if(usernameValidating) {
      return Container(
        margin: EdgeInsets.only(right: 10),
        height: 13,
        width: 13,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation(Colors.blue),
          strokeWidth: 2.0,
        )
      );
    }else if(usernameAccepted == null) {
      return null;
    }else if(usernameAccepted) {
      return Container(
        margin: EdgeInsets.only(right: 10),
        child: Icon(Icons.check, color: Colors.green, size: 17)
      );
    }else {
      return Container(
        margin: EdgeInsets.only(right: 10),
        child: Icon(Icons.close, color: Colors.red, size: 17)
      );
    }
  }

  Widget _buildUsernameTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: usernameTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            onChanged: (val) {
              usernameStreamController.add(val);
            },
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              suffix: usernameSuffixWidget(),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'Username',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameAndUsernameTF() {
    return Row(
      children: [
        Expanded(
          child: _buildNameTF()
        ),
        SizedBox(
          width: 5.0,
        ),
        Expanded(
          child: _buildUsernameTF()
        )
      ],
    );
  }

  Widget _buildSEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: emailTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
              hintText: 'Email',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: sPasswordTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Business / Place of Work Address',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: addressTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Address',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZipcodeTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Business / Place of Work Zipcode',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: zipcodeTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Zipcode',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: passwordTFController,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          _handleSubmit(userEmailTFController.text, passwordTFController.text);
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildSignupBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {
          setState(() {
            signupUser.name = nameTFController.text;
            signupUser.email= emailTFController.text;
            signupUser.username = usernameTFController.text;
            signupUser.password = sPasswordTFController.text;

            if(signupUser.type == 2) {
              signupUser.address = addressTFController.text;
              signupUser.zipcode = zipcodeTFController.text;
            }

            if(
              usernameAccepted &&
              signupUser.name.length > 0 &&
              signupUser.username.length > 3 &&
              signupUser.email.length > 0 
            ) {
              _handleSignup(signupUser);
            }else {
              showErrorDialog(context, 'Validation Error', 'Please check all the required fields');
            }
          });
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'SIGNUP',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  _buildAccountType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: kLabelStyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: new CircularCheckBox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Colors.blue,
                    value: signupUser.type == 1 ? true : false,
                    onChanged: (bool value) {
                      setState(() {
                        signupUser.type = 1;
                      });
                    }
                  )
                ),
                AutoSizeText(
                  "Client",
                  maxLines: 1,
                  minFontSize: 9,
                  style: kLabelStyle
                ),
              ],
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: new CircularCheckBox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Colors.blue,
                    value: signupUser.type == 2 ? true : false,
                    onChanged: (bool value) {
                      setState(() {
                        signupUser.type = 2;
                      });
                    }
                  ),
                ),
                 AutoSizeText(
                  "Professional",
                  maxLines: 1,
                  minFontSize: 9,
                  style: kLabelStyle,
                ),
              ],
            )
          ]
        )
      ]
    );
  }

  Widget _buildSignupNote() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = 1;
        });
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabBarView() {
    return new DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          Container(
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Login"),
                Tab(text: "Sign up")
              ],
            )
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListView(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    // ListView(
                    //   physics: AlwaysScrollableScrollPhysics(),
                    //   child: Column(
                    //     children: [
                    //       SizedBox(
                    //         height: 20.0,
                    //       ),
                    //       _buildEmailTF(),
                    //       SizedBox(
                    //         height: 30.0,
                    //       ),
                    //       _buildPasswordTF(),
                    //       _buildForgotPasswordBtn(),
                    //       _buildLoginBtn(),
                    //       _buildSignupNote()
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 20.0,
                    ),
                    _buildEmailTF(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildPasswordTF(),
                    _buildForgotPasswordBtn(),
                    _buildLoginBtn(),
                    _buildSignupNote()
                  ]
                ),
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildAccountType(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child:_buildNameAndUsernameTF(),
                            ),
                            signupUser.type == 2 ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: _buildAddressTF(),
                            ) : Container(),
                            signupUser.type == 2 ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: _buildZipcodeTF(),
                            ) : Container(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child:_buildSEmailTF(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: _buildSPasswordTF(),
                            )
                          ],
                        ),
                      ),
                    ),
                    _buildSignupBtn(),
                  ]
                )
              ],
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.dark,
      ),
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: primaryGradient
                    ),
                  ),
                  Container(
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 60.0
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Image.asset('images/trimmz_icon_t.png',
                          height: 150.0,
                        ),
                        Expanded(
                          child: buildTabBarView()
                        ),
                      ],
                    ),
                  ),
                  _progressHUD
                ],
              ),
            )
          ),
        ),
      )
    );
  }
}