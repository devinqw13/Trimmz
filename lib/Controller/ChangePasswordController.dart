import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import '../globals.dart' as globals;
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import 'package:line_icons/line_icons.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key key}) : super (key: key);

  @override
  ChangePasswordState createState() => new ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  TextEditingController _oldPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();
  StreamController<String> passwordStreamController = StreamController();
  StreamController<String> newPasswordStreamController = StreamController();
  StreamController<String> confirmPasswordStreamController = StreamController();
  bool passwordValid = false;
  bool showPasswordIndicator = false;
  bool newPasswordValid = false;
  bool showNewPasswordIndicator = false;
  bool confirmPasswordValid = false;
  bool showConfirmPasswordIndicator = false;

  void initState() {
    super.initState();

    passwordStreamController.stream
    .debounce(Duration(seconds: 2))
    .listen((s) => _validatePassword(s, 1));

    newPasswordStreamController.stream
    .debounce(Duration(seconds: 2))
    .listen((s) => _validatePassword(s, 2));

    confirmPasswordStreamController.stream
    .debounce(Duration(seconds: 2))
    .listen((s) => _validatePassword(s, 3));
  }

  _validatePassword(String string, int type) async {
    if(type == 1){
      if (_oldPasswordController.text.length > 3) {
        bool result = await exists(context, string, 2, globals.token);
        if(result){
          setState(() {
            passwordValid = true;
          });
        }else {
          setState(() {
            passwordValid = false;
          });
        }
        setState(() {
          showPasswordIndicator = true;
        });
      }else if(_oldPasswordController.text.length <= 3) {
        setState(() {
          showPasswordIndicator = false;
          passwordValid = false;
        });
      }
    }else if(type == 2) {
      if (_newPasswordController.text.length > 3) {
        bool passwordIsValid = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$^+=!*()@%&]).{8,}').hasMatch(string);
        if(passwordIsValid){
          setState(() {
            newPasswordValid = true;
          });
        }else {
          setState(() {
            newPasswordValid = false;
          });
        }
        setState(() {
          showNewPasswordIndicator = true;
        });
      }else if(_newPasswordController.text.length <= 3) {
        setState(() {
          showNewPasswordIndicator = false;
          newPasswordValid = false;
        });
      }
    }else {
      if (_confirmPasswordController.text.length > 3) {
        if(_newPasswordController.text == _confirmPasswordController.text) {
          setState(() {
            confirmPasswordValid = true;
          });
        }else {
          setState(() {
            confirmPasswordValid = false;
          });
        }
        setState(() {
          showConfirmPasswordIndicator = true;
        });
      }else if(_confirmPasswordController.text.length <= 3) {
        setState(() {
          showConfirmPasswordIndicator = false;
          confirmPasswordValid = false;
        });
      }
    }
  }

  oldPassword() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Old Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        TextField(
          controller: _oldPasswordController,
          onChanged: (val) {
            passwordStreamController.add(val);
          },
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0,
            color: Colors.white
          ),
          decoration: new InputDecoration(
            hintText: 'Old Password',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffix: showPasswordIndicator ? (!passwordValid ? Icon(LineIcons.times, color: Colors.red) : Icon(LineIcons.check, color: Colors.green)) : null,
          ),
        )
      ]
    );
  }

  setNewPassword() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('New Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        TextField(
          controller: _newPasswordController,
          onChanged: (val) {
            newPasswordStreamController.add(val);
          },
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0,
            color: Colors.white
          ),
          decoration: new InputDecoration(
            hintText: 'New Password',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffix: showNewPasswordIndicator ? (!newPasswordValid ? Icon(LineIcons.times, color: Colors.red) : Icon(LineIcons.check, color: Colors.green)) : null,
          )
        ),
        showNewPasswordIndicator && !newPasswordValid ? Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Text(
            'Requires at least 8 characters, an uppercase, a numeric, and a special character',
            style: TextStyle(
              color: Colors.red,
              fontStyle: FontStyle.italic,
              fontSize: 12
            )
          )
        ) : Container(),
        Text('Confirm Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        TextField(
          controller: _confirmPasswordController,
          onChanged: (val) {
            confirmPasswordStreamController.add(val);
          },
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0,
            color: Colors.white
          ),
          decoration: new InputDecoration(
            hintText: 'Confirm Password',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffix: showConfirmPasswordIndicator ? (!confirmPasswordValid ? Icon(LineIcons.times, color: Colors.red) : Icon(LineIcons.check, color: Colors.green)) : null,
          )
        ),
      ]
    );
  }

  submitNewPassword() async {
    if((passwordValid && newPasswordValid) && (_newPasswordController.text == _confirmPasswordController.text)) {
      var result = await changePassword(context, _newPasswordController.text, globals.token);
      if(result) {
        Navigator.pop(context, true);
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

  buildBody() {
    return new Container(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(5.0),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(0.0, -2.0),
                        colors: [Colors.black, Colors.grey[850]]
                      )
                    ),
                    child: Column(
                      children: <Widget>[
                        Center(child:Text('Enter old password and set new password', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
                        Padding(padding: EdgeInsets.all(10)),
                        oldPassword(),
                        Divider(
                          height: 15,
                          color: Colors.grey[700],
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        setNewPassword()
                      ]
                    )
                  )
                ],
              ),
            )
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: new GestureDetector(
                  onTap: () {
                    submitNewPassword();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    // padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                    constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: new LinearGradient(
                        colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent],
                      )
                    ),
                    child: Center(
                      child: Text(
                        'Set New Password',
                        style: new TextStyle(
                          fontSize: 19.0,
                          fontWeight: FontWeight.w300
                        )
                      )
                    )
                  )
                )
              )
            ]
          ),
          Padding(padding: EdgeInsets.only(bottom: 24))
        ]
      )
    );
  }

  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('Change Password')
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