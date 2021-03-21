import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/Extensions.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import 'package:trimmz/calls.dart';
import 'package:trimmz/RippleButton.dart';

class EditingAccountController extends StatefulWidget {
  final String screen;
  EditingAccountController({Key key, this.screen}) : super (key: key);

  @override
  EditingAccountControllerState createState() => new EditingAccountControllerState();
}

class EditingAccountControllerState extends State<EditingAccountController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  bool currentPass;
  bool newPass;
  bool currentPassValidating = false;
  bool usernameValidating = false;
  bool usernameAccepted;
  bool canUpdate = false;
  final TextEditingController textTFController = new TextEditingController();
  final TextEditingController currentPasswordTFController = new TextEditingController();
  final TextEditingController newPasswordTFController = new TextEditingController();
  StreamController<String> textStreamController = StreamController();
  StreamController<String> currentPasswordStreamController = StreamController();
  StreamController<String> newPasswordStreamController = StreamController();
  String newPassErrors = "";

  @override
  void initState() {

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    currentPasswordStreamController.stream
    .debounce(Duration(seconds: 1))
    .listen((s) => _validatePassword(s));

    newPasswordStreamController.stream
    .debounce(Duration(seconds: 1))
    .listen((s) => _newPasswordValidate(s));

    textStreamController.stream
    .debounce(Duration(milliseconds: 700))
    .listen((s) => _textValidate(s));

    super.initState();
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
      if(currentPassValidating == null) {
        currentPassValidating = true;
      }else {
        currentPassValidating = !currentPassValidating;
      }
    });
  }

  void validatingInProcess2() {
    setState(() {
      if(usernameValidating == null) {
        usernameValidating = true;
      }else {
        usernameValidating = !usernameValidating;
      }
    });
  }

  _validatePassword(String s) async {
    if(s.length > 5){
      validatingInProcess();
      bool result = await validatePassword(context, globals.user.token, s);
      validatingInProcess();
      
      setState(() {
        currentPass = result;
      });
    }
  }

  _newPasswordValidate(String s) {
    if(RegExp(r'^(?=.*\d)').hasMatch(s) &&
      RegExp(r'^(?=.*[#$^+=!*()@%&])').hasMatch(s) &&
      RegExp(r'^.{8,}').hasMatch(s) &&
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])').hasMatch(s)) {
        setState(() {
          newPass = true;
        });
    }else {
      setState(() {
        newPass = false;
      });
      handleValidateErrors(s);
    }
  }

  _textValidate(String s) async {
    if(widget.screen == "username"){
      if(s.length >= 3) {
        validatingInProcess2();
        bool result = await validateUsername(context, globals.user.token, s);
        validatingInProcess2();
        
        if(result) {
          setState(() {
            usernameAccepted = false;
          });
        }else {
          setState(() {
            usernameAccepted = true;
          });
        }

        if(usernameAccepted) {
          setState(() {
            canUpdate = true;
          });
        }else {
          setState(() {
            canUpdate = false;
          });
        }
      }
    }else {
      if(textTFController.text.length >= 5) {
        setState(() {
          canUpdate = true;
        });
      }else {
        setState(() {
          canUpdate = false;
        });
      }
    }
  }

  String buildCurrentText() {
    switch (widget.screen) {
      case "name": {
        return globals.user.name;
      }
      case "username": {
        return globals.user.username;
      }
      case "email": {
        return globals.user.userEmail;
      }
      case "phone": {
        return globals.user.phone != null ? globals.user.phone : "Not Provided";
      }
      default: {
        return "";
      }
    }
  }

  buildEditText() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          ),
        ),
        Padding(
          padding: EdgeInsets.all(2.0),
        ),
        Text(
          buildCurrentText(),
          style: TextStyle(
            fontSize: 16
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        Text(
          "New",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color.fromARGB(110, 42, 42, 42),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: textTFController,
            onChanged: (val) {
              textStreamController.add(val);
            },
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              suffix: textSuffixWidget(),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 10.0),
              hintText: widget.screen.capitalize(),
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget currentSuffixWidget() {
    if(currentPassValidating) {
      return Container(
        margin: EdgeInsets.only(right: 10),
        height: 13,
        width: 13,
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation(Colors.blue),
          strokeWidth: 2.0,
        )
      );
    }else if(currentPass == null) {
      return null;
    }else if(currentPass) {
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

  Widget newSuffixWidget() {
    if(newPass == null) {
      return null;
    }else if(newPass) {
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

  Widget textSuffixWidget() {
    if(widget.screen != "username") {
      return null;
    }else {
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
  }

  void handleValidateErrors(value) {
    String errors = "";
    if(!RegExp(r'^(?=.*\d)').hasMatch(value)) {
      if(errors.length > 0) {
        errors += "\nPassword must include a number";
      }else {
        errors = "Password must include a number";
      }
    }

    if(!RegExp(r'^(?=.*[#$^+=!*()@%&])').hasMatch(value)) {
      if(errors.length > 0) {
        errors += "\nPassword must include a special character";
      }else {
        errors = "Password must include a special character";
      }
    }

    if(!RegExp(r'^.{8,}').hasMatch(value)) {
      if(errors.length > 0) {
        errors += "\nPassword must include at least 8 characters long";
      }else {
        errors = "Password must include at least 8 characters long";
      }
    }

    if(!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
      if(errors.length > 0) {
        errors += "\nPassword must include an upper case letter";
      }else {
        errors = "Password must include an upper case letter";
      }
    }

    setState(() {
      newPassErrors = errors;
    });
  }

  buildEditPassword() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter current password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color.fromARGB(110, 42, 42, 42),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextField(
            controller: currentPasswordTFController,
            onChanged: (val) {
              currentPasswordStreamController.add(val);
            },
            keyboardType: TextInputType.text,
            autocorrect: false,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              suffix: currentSuffixWidget(),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 10.0),
              hintText: "Current Password",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        Text(
          "Enter new password",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color.fromARGB(110, 42, 42, 42),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            controller: newPasswordTFController,
            onChanged: (val) {
              newPasswordStreamController.add(val);
            },
            keyboardType: TextInputType.text,
            autocorrect: false,
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              suffix: newSuffixWidget(),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 10.0),
              hintText: "New Password",
              hintStyle: TextStyle(
                color: Colors.white54,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        newPass == null || newPass ? Container() : Text(
          newPassErrors,
          style: TextStyle(
            color: Colors.red
          )
        )
      ],
    );
  }

  handleReturnData(Map result) {
    switch(result.keys.toList()[0]) {
      case "name": {
        setState(() {
          globals.user.name = result['name'];
        });
        break;
      }
      case "username": {
        setState(() {
          globals.user.username = result['username'];
        });
        break;
      }
      case "phone": {
        setState(() {
          globals.user.phone = result['phone'];
        });
        break;
      }
      case "email": {
        setState(() {
          globals.user.userEmail = result['email'];
        });
        break;
      }
    }
  }

  handleUpdateAccount() async {
    String data = widget.screen == "password" ? newPasswordTFController.text : textTFController.text;

    setState(() {
      canUpdate = false;
      textTFController.clear();
      newPasswordTFController.clear();
    });

    progressHUD();
    var results = await updateAccountInfo(context, globals.user.token, widget.screen, data);
    progressHUD();

    handleReturnData(results);
  }

  Widget buildUpdatebtn() {
    if(canUpdate) {
      return new Container(
        decoration: BoxDecoration(
          color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
          borderRadius: BorderRadius.all(Radius.circular(3)),
          border: Border.all(
            color: CustomColors1.mystic.withAlpha(100)
          )
        ),
        child: RippleButton(
          splashColor: CustomColors1.mystic.withAlpha(100),
          onPressed: () {
            FocusScope.of(context).unfocus();
            handleUpdateAccount();
          },
          child: Container(
            padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
            child: Center(
              child: Text(
                "Update",
                style: TextStyle(
                  color: Colors.white
                )
              ),
            )
          )
        )
      );
    }else {
      return new Container();
    }
  }

  Widget _buildScreen() {
    switch (widget.screen) {
      case "name": {
        return Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 25.0),
          child: Column(
            children: [
              Expanded(
                child: buildEditText()
              ),
              buildUpdatebtn()
            ],
          )
        );
      }
      case "username": {
        return Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 25.0),
          child: Column(
            children: [
              Expanded(
                child: buildEditText()
              ),
              buildUpdatebtn()
            ],
          )
        );
      }
      case "phone": {
        return Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 25.0),
          child: Column(
            children: [
              Expanded(
                child: buildEditText()
              ),
              buildUpdatebtn()
            ],
          )
        );
      }
      case "email": {
        return Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 25.0),
          child: Column(
            children: [
              Expanded(
                child: buildEditText()
              ),
              buildUpdatebtn()
            ],
          )
        );
      }
      case "password": {
        return Container(
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 25.0),
          child: Column(
            children: [
              Expanded(
                child: buildEditPassword()
              ),
              buildUpdatebtn()
            ],
          )
        );
      }
      default: {
        return Container();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: new Scaffold(
        backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Update ${widget.screen}",
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