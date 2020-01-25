import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'LoginController.dart';
import 'RegisterStep3Controller.dart';
import '../View/StateBottomSheetPicker.dart';
import '../states.dart' as states;

class RegisterStep2Screen extends StatefulWidget {
  final String username;
  final String email;
  final String name;
  final String accountType;
  RegisterStep2Screen({Key key, this.username, this.email, this.name, this.accountType}) : super (key: key);

  @override
  State createState() => new RegisterStep2ScreenState();
}

class RegisterStep2ScreenState extends State<RegisterStep2Screen> with WidgetsBindingObserver {
  TextEditingController _registerBarberAddressController = new TextEditingController();
  TextEditingController _registerBarberZipcodeController = new TextEditingController();
  TextEditingController _registerBarberCityController = new TextEditingController();
  int stateValue;
  String state = '';
  String stateAbr = '';
  bool stateSelected = false;

  buildAddressTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Shop Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerBarberAddressController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            onSubmitted: (value) {

            },
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Shop Address',
              hintStyle: TextStyle(color: Colors.white70),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue)
              )
            ),
          )
        )
      ]
    );
  }

  buildCityTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'City',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerBarberCityController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'City',
              hintStyle: TextStyle(color: Colors.white70),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue)
              )
            ),
          )
        )
      ]
    );
  }

  buildStatePicker(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'State',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Padding(padding: EdgeInsets.all(5)),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
              return StateBottomSheet(
                value: stateValue,
                valueChanged: (value) {
                  setState(() {
                    stateValue = value;
                    state = states.states[value];
                    stateAbr = states.abr[value];
                  });
                }
              );
            });
          },
          child: Container(
            color: Colors.transparent,
            width: size * .6,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(state == '' ? 'State' : state, style: TextStyle(color: state == '' ? Colors.grey[400] : Colors.white, fontSize: 15)),
                    Icon(Icons.keyboard_arrow_down, color: state == '' ? Colors.grey[400] : Colors.white)
                  ]
                ),
              ]
            )
          )
        )
      ]
    );
  }

  buildZipcodeTextField(double size) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Text(
          'Zipcode',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16
          )
        ),
        Container(
          width: size * .6,
          child: TextField(
            controller: _registerBarberZipcodeController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: new TextStyle(
              fontSize: 15.0,
              color: Colors.white
            ),
            decoration: new InputDecoration(
              hintText: 'Zipcode',
              hintStyle: TextStyle(color: Colors.white70),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue)
              )
            ),
          )
        )
      ]
    );
  }

  buildSubmitButton(double size) {
    return new GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _submitAddressInfo(context, _registerBarberAddressController.text, _registerBarberCityController.text, stateAbr, state, _registerBarberZipcodeController.text);
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

  void _submitAddressInfo(BuildContext context, String address, String city, String stateAbr, String state, String zipcode) async {
    if(address != '' && city != '' && state != '' && zipcode != ''){
      final registerStep3Screen = new RegisterStep3Screen(username: widget.username, name: widget.name, email: widget.email, accountType: widget.accountType, shopAddress: address, city: city, state: state, stateAbr: stateAbr, zipcode: zipcode, stateValue: stateValue);
      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => registerStep3Screen));
    }else {
      AlertDialog dialog = new AlertDialog(
        content: new SingleChildScrollView(
          child: new Text('Incomplete Fields',
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
                                  'Set Address',
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
                                      buildAddressTextField(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildCityTextField(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildStatePicker(screenWidth),
                                      Padding(padding: EdgeInsets.all(8)),
                                      buildZipcodeTextField(screenWidth),
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
        unselectedWidgetColor: Colors.white,
        brightness: Brightness.dark
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