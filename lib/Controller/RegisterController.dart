import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../calls.dart';
import 'dart:ui';
import 'RegisterStep3Controller.dart';
import 'RegisterStep2Controller.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:line_icons/line_icons.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super (key: key);

  @override
  State createState() => new RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> with WidgetsBindingObserver {
  TextEditingController _registerUserEmailController = new TextEditingController();
  TextEditingController _registerNameController = new TextEditingController();
  TextEditingController _registerUserNameController = new TextEditingController();
  StreamController<String> usernameStreamController = StreamController();
  StreamController<String> emailStreamController = StreamController();
  StreamController<String> nameStreamController = StreamController();
  String _accountType = '';
  bool showUsernameIndicator = false;
  bool usernameTaken;
  bool showEmailIndicator = false;
  bool emailValid;
  bool showNameIndicator = false;
  bool nameValid;

  void initState() {
    super.initState();

    usernameStreamController.stream
    .debounce(Duration(seconds: 1))
    .listen((s) => _validateValues(s, 1));

    emailStreamController.stream
    .debounce(Duration(seconds: 1))
    .listen((s) => _validateValues(s, 2));

    nameStreamController.stream
    .debounce(Duration(seconds: 1))
    .listen((s) => _validateValues(s, 3));
  }

  _validateValues(String string, int type) async {
    if(type == 1){
      if (_registerUserNameController.text.length > 3) {
        bool result = await exists(context, string, 1);
        if(result){
          setState(() {
            usernameTaken = true;
          });
        }else {
          setState(() {
            usernameTaken = false;
          });
        }
        setState(() {
          showUsernameIndicator = true;
        });
      }else if(_registerUserNameController.text.length <= 3) {
        setState(() {
          showUsernameIndicator = false;
        });
      }
    }else if(type == 2) {
      if(_registerUserEmailController.text.length > 7 && _registerUserEmailController.text.contains('@')) {
        setState(() {
          emailValid = true;
          showEmailIndicator = true;
        });
      }else if(!_registerUserEmailController.text.contains('@') && _registerUserEmailController.text.length > 7) {
        setState(() {
          emailValid = false;
          showEmailIndicator = true;
        });
      }else if(_registerUserNameController.text.length <= 3) {
        setState(() {
          showEmailIndicator = false;
        });
      }
    }else {
      if(_registerNameController.text.length >= 2) {
        setState(() {
          nameValid = true;
          showNameIndicator = true;
        });
      }else if(_registerNameController.text.length < 2) {
        setState(() {
          nameValid = false;
          showNameIndicator = false;
        });
      }
    }
  }

  buildNameTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerNameController,
            onChanged: (val) {
              nameStreamController.add(val);
            },
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Name',
              hintStyle: TextStyle(color: Colors.white70),
              suffix: showNameIndicator ? (!nameValid ? Icon(LineIcons.times, color: Colors.red) : Icon(LineIcons.check, color: Colors.green)) : null,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue)
              )
            ),
          )
        )
      ]
    );
  }

  buildUsernameTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Username',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerUserNameController,
            onChanged: (val) {
              usernameStreamController.add(val);
            },
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Username',
              hintStyle: TextStyle(color: Colors.white70),
              suffix: showUsernameIndicator ? (usernameTaken ? Text('Taken', style: TextStyle(color: Colors.red, fontSize: 14)) : Icon(LineIcons.check, color: Colors.green)) : null,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue)
              )
            ),
          )
        )
      ]
    );
  }

  buildEmailTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Email',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerUserEmailController,
            onChanged: (val) {
              emailStreamController.add(val);
            },
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(color: Colors.white70),
              suffix: showEmailIndicator ? (!emailValid ? Icon(LineIcons.times, color: Colors.red) : Icon(LineIcons.check, color: Colors.green)) : null,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue)
              )
            ),
          )
        )
      ]
    );
  }

  buildSelectAccountType(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Account Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .7,
          child: Row(
            children: <Widget>[
              Radio(
                groupValue: _accountType,
                value: '1',
                onChanged: (value) {
                  setState(() {
                    _accountType = value;
                  });
                }
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _accountType = '1';
                  });
                },
                child: Text(
                  'Client',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  )
                )
              ),
              Radio(
                groupValue: _accountType,
                value: '2',
                onChanged: (value) {
                  setState(() {
                    _accountType = value;
                  });
                }
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _accountType = '2';
                  });
                },
                child: Text(
                  'Barber/Merchant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  )
                )
              )
            ]
          )
        )
      ]
    );
  }

  buildSubmitButton(double size) {
    return new GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _submitRegisterUser(context, _registerUserEmailController.text, _registerUserNameController.text, _registerNameController.text, _accountType);
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
            'NEXT',
            style: new TextStyle(
              fontSize: 19.0,
              fontWeight: FontWeight.w300
            )
          )
        )
      )
    );
  }

  buildCancelButton(double size) {
    return new FlatButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'Cancel',
        style: TextStyle(
          color: Colors.white
        )
      )
    );
  }

  void _submitRegisterUser(BuildContext context, String emailAddress, String username, String name, String accountType) async {
    if(emailValid == true && usernameTaken == false && nameValid == true && _accountType != ''){
      if(accountType == '1') {
        final registerStep3Screen = new RegisterStep3Screen(username: username, name: name, email: emailAddress, accountType: accountType);
        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => registerStep3Screen));
      }else {
        final registerStep2Screen = new RegisterStep2Screen(username: username, name: name, email: emailAddress, accountType: accountType);
        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => registerStep2Screen));
      }
    }else {
      AlertDialog dialog = new AlertDialog(
        content: new SingleChildScrollView(
          child: new Text('Invalid or incomplete fields',
          textAlign: TextAlign.center
          ),
        ),
      );
      showDialog(context: context, builder: (context) => dialog, barrierDismissible: true);
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
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: new BoxDecoration(
                  color: Colors.black.withOpacity(0.85)
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
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(10),),
                                Text(
                                  'Sign up for your Trimmz account',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.all(10)),
                                      buildNameTextField(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildUsernameTextField(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildEmailTextField(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildSelectAccountType(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildSubmitButton(screenWidth),
                                      buildCancelButton(screenWidth)
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
        backgroundColor: Colors.black,
        resizeToAvoidBottomPadding: true,
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