import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../calls.dart';
import 'dart:ui';
import 'RegisterStep2Controller.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super (key: key);

  @override
  State createState() => new RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> with WidgetsBindingObserver {
  TextEditingController _registerUserEmailController = new TextEditingController();
  TextEditingController _registerNameController = new TextEditingController();
  TextEditingController _registerUserNameController = new TextEditingController();
  String _accountType = '';

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
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Name',
              hintStyle: TextStyle(color: Colors.white70),
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
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Username',
              hintStyle: TextStyle(color: Colors.white70),
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
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(color: Colors.white70),
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
          width: size * .6,
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
                  'Barber / Sales',
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
    final registerStep2Screen = new RegisterStep2Screen(username: username, name: name, email: emailAddress, accountType: accountType);
    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => registerStep2Screen));
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