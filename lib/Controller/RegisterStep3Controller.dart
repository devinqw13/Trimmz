import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../calls.dart';
import 'dart:ui';
import 'LoginController.dart';
import '../functions.dart';
import '../globals.dart' as globals;
import 'PaymentMethod.dart';
import 'BarberSalesSetupController.dart';

class RegisterStep3Screen extends StatefulWidget {
  final String username;
  final String email;
  final String name;
  final String accountType;
  final String shopAddress;
  final String city;
  final String state;
  final String stateAbr;
  final String zipcode;
  final int stateValue;
  RegisterStep3Screen({Key key, this.username, this.email, this.name, this.accountType, this.shopAddress, this.city, this.zipcode, this.state, this.stateAbr, this.stateValue}) : super (key: key);

  @override
  State createState() => new RegisterStep3ScreenState();
}

class RegisterStep3ScreenState extends State<RegisterStep3Screen> with WidgetsBindingObserver {
  TextEditingController _registerUserPasswordController = new TextEditingController();
  TextEditingController _registerUserPassword2Controller = new TextEditingController();

  buildPasswordTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerUserPasswordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            autocorrect: false,
            onSubmitted: (value) {

            },
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          )
        )
      ]
    );
  }

  buildPasswordConfirmTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerUserPassword2Controller,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            autocorrect: false,
            onSubmitted: (value) {
              _submitPassword(context, _registerUserPasswordController.text, _registerUserPassword2Controller.text);
            },
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Confirm Password',
              hintStyle: TextStyle(color: Colors.white70),
            ),
          )
        )
      ]
    );
  }

  buildSubmitButton(double size) {
    return new GestureDetector(
      onTap: () {
        _submitPassword(context, _registerUserPasswordController.text, _registerUserPassword2Controller.text);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
        constraints: const BoxConstraints(maxHeight: 45.0, minWidth: 200.0, minHeight: 45.0),
        width: size * .6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          gradient: new LinearGradient(
            colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent],
          )
        ),
        child: Center(
          child: Text(
            'SIGN UP',
            style: new TextStyle(
              fontSize: 19.0,
              fontWeight: FontWeight.w300
            )
          )
        )
      )
    );
  }

  buildBackCancelButton(double size) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget> [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Back',
            style: TextStyle(
              color: Colors.white
            )
          )
        ),
        FlatButton(
          onPressed: () {
            final loginScreen = new LoginScreen();
            Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => loginScreen));
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white
            )
          )
        )
      ]
    );
  }

  void _submitPassword(BuildContext context, String password, String password2) async {
    bool passwordIsValid = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$^+=!*()@%&]).{8,}').hasMatch(password);
    // Valid password check and prompt
    if (!passwordIsValid) {
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text("Password is not valid",
            textAlign: TextAlign.center,
          ),
          content: new Container(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text("Password must contain at least 8 characters and contain an uppercase, numeric, and special character.",
                  textAlign: TextAlign.center,
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new RaisedButton(
                        child: new Text("OK",
                        textAlign: TextAlign.center),
                        onPressed: () { 
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                )
              ],
            )
          )
        )
      );
      return;
    }
    // Empty entry check and prompt
    if (password == "" || password2 == "") {
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text("A field is empty",
            textAlign: TextAlign.center,
          ),
          content: new Container(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text("Please ensure all fields are entered and try again.",
                  textAlign: TextAlign.center,
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new RaisedButton(
                        child: new Text("OK",
                        textAlign: TextAlign.center),
                        onPressed: () { 
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                )
              ],
            )
          )
        )
      );
      return;
    }
    // Passwords don't match check and prompt
    if (password != password2) {
      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text("Passwords do not match",
            textAlign: TextAlign.center,
          ),
          content: new Container(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text("Please ensure both passwords are the same and try again.",
                  textAlign: TextAlign.center,
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new RaisedButton(
                        child: new Text("OK",
                        textAlign: TextAlign.center),
                        onPressed: () { 
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                )
              ],
            )
          )
        )
      );
      return;
    }

    bool result;
    if(widget.accountType == ''){
      result = await registerUser(context, widget.name, widget.username, widget.email, widget.accountType, password);
    }else {
      result = await registerUser(context, widget.name, widget.username, widget.email, widget.accountType, password, widget.shopAddress, widget.city, widget.stateAbr, widget.zipcode);
    }

    if (result) {
      Map userInfo = await loginPost('${globals.baseUrl}login/', {'username': widget.username, 'password': password}, context);

      setGlobals(userInfo);

      if(widget.accountType == '1') {
        final paymentMethod = new PaymentMethod(signup: true);
        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => paymentMethod));
      }else {
        await setTimeAvailability(context, globals.token, '', null, null, null, true);
        final barberSalesSetup = new BarberSalesSetup(address: widget.shopAddress, city: widget.city, state: widget.state, zipcode: widget.zipcode, stateValue: widget.stateValue);
        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => barberSalesSetup));
      }
    }
  }

  _buildRegisterBody() {
    double screenWidth = MediaQuery.of(context).size.width;
    return new Stack(
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
                child: new Center(
                  child: new Column (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        child: new Stack(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Set Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(10),),
                                Text(
                                  'Signing up for your Trimmz account',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.all(10)),
                                      buildPasswordTextField(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildPasswordConfirmTextField(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildSubmitButton(screenWidth),
                                      buildBackCancelButton(screenWidth),
                                    ]
                                  )
                                )
                              ]
                            )
                          ],
                        )
                      )
                    ],
                  )
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {


    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarBrightness: Brightness.dark
    ));

    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hintColor: Colors.white70,
        unselectedWidgetColor: Colors.white
      ),
      child: new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new WillPopScope(
        onWillPop: () async {
          return false;
        }, child: Stack(
          children: <Widget>[
            _buildRegisterBody()
          ]
        )
      )
    )
    );
  }
}