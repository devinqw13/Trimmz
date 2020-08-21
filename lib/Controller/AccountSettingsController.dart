import 'package:flutter/material.dart';
import 'package:trimmz/View/Widgets.dart';
import 'package:trimmz/dialogs.dart';
import 'package:trimmz/functions.dart';
import '../globals.dart' as globals;
import 'ChangePasswordController.dart';
import 'package:flushbar/flushbar.dart';
import '../Calls/GeneralCalls.dart';
import '../states.dart' as states;
import '../View/StateBottomSheetPicker.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import '../Controller/AddImageController.dart';

class AccountSettings extends StatefulWidget {
  AccountSettings({Key key}) : super (key: key);

  @override
  AccountSettingsState createState() => new AccountSettingsState();
}

class AccountSettingsState extends State<AccountSettings> {
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _shopNameController = new TextEditingController();
  TextEditingController _streetAddressController = new TextEditingController();
  TextEditingController _cityController = new TextEditingController();
  bool usernameEmpty;
  bool nameEmpty;
  bool emailEmpty;
  bool shopNameEmpty;
  bool streetAddressEmpty;
  bool cityEmpty;
  int stateValue;
  String stateStr = '';
  String stateAbr = '';
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  void initState() {
    super.initState();

    _usernameController.text = globals.username;
    if(_usernameController.text.length == 0) {
      setState(() {
        usernameEmpty = true;
      });
    }else {
      setState(() {
        usernameEmpty = false;
      });
    }
    _usernameController.addListener(() {
      if(_usernameController.text.length == 0) {
        setState(() {
          usernameEmpty = true;
        });
      }else {
        setState(() {
          usernameEmpty = false;
        });
      }
    });

    _nameController.text = globals.name;
    if(_nameController.text.length == 0) {
      setState(() {
        nameEmpty = true;
      });
    }else {
      setState(() {
        nameEmpty = false;
      });
    }
    _nameController.addListener(() {
      if(_nameController.text.length == 0) {
        setState(() {
          nameEmpty = true;
        });
      }else {
        setState(() {
          nameEmpty = false;
        });
      }
    });

    _emailController.text = globals.email;
    if(_emailController.text.length == 0) {
      setState(() {
        emailEmpty = true;
      });
    }else {
      setState(() {
        emailEmpty = false;
      });
    }
    _emailController.addListener(() {
      if(_emailController.text.length == 0) {
        setState(() {
          emailEmpty = true;
        });
      }else {
        setState(() {
          emailEmpty = false;
        });
      }
    });

    if(globals.userType == 2) {
      _shopNameController.text = globals.shopName ?? '';
      if(_shopNameController.text.length == 0) {
        setState(() {
          shopNameEmpty = true;
        });
      }else {
        setState(() {
          shopNameEmpty = false;
        });
      }
      _shopNameController.addListener(() {
        if(_shopNameController.text.length == 0) {
          setState(() {
            shopNameEmpty = true;
          });
        }else {
          setState(() {
            shopNameEmpty = false;
          });
        }
      });

      _streetAddressController.text = globals.shopAddress;
      if(_streetAddressController.text.length == 0) {
        setState(() {
          streetAddressEmpty = true;
        });
      }else {
        setState(() {
          streetAddressEmpty = false;
        });
      }
      _streetAddressController.addListener(() {
        if(_streetAddressController.text.length == 0) {
          setState(() {
            streetAddressEmpty = true;
          });
        }else {
          setState(() {
            streetAddressEmpty = false;
          });
        }
      });

      _cityController.text = globals.city;
      if(_cityController.text.length == 0) {
        setState(() {
          cityEmpty = true;
        });
      }else {
        setState(() {
          cityEmpty = false;
        });
      }
      _cityController.addListener(() {
        if(_cityController.text.length == 0) {
          setState(() {
            cityEmpty = true;
          });
        }else {
          setState(() {
            cityEmpty = false;
          });
        }
      });

      setState(() {
        stateValue = states.abr.indexWhere((abrs) => abrs == globals.state);
        stateAbr = globals.state;
        stateStr = states.states[states.abr.indexWhere((abrs) => abrs == globals.state)];
      });
    }

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

  changeProfilePicture() async {
    var cameras = await availableCameras();
    final cameraScreen = new CameraApp(uploadType: 1, cameras: cameras);
    var res = await Navigator.push(context, new MaterialPageRoute(builder: (context) => cameraScreen));
    if(res != null) {
      setState(() {
        globals.profilePic = res;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profilePic', res);
    }
  }

  profilePicture() {
    return new GestureDetector(
      onTap: () {
        changeProfilePicture();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            buildProfilePictures(context, globals.profilePic, globals.username, 50)
          ]
        )
      )
    );
  }

  username() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        usernameEmpty ? Container() : Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _usernameController,
          keyboardType: TextInputType.text,
          readOnly: true,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0,
            color: Colors.grey
          ),
          decoration: new InputDecoration(
            hintText: 'Username',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  name() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        nameEmpty ? Container() : Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.text,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0,
          ),
          decoration: new InputDecoration(
            hintText: 'Name',
            hintStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white70 : Colors.black54),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  email() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        emailEmpty ? Container() : Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0
          ),
          decoration: new InputDecoration(
            hintText: 'Email',
            hintStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white70 : Colors.black54),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  shopName() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        shopNameEmpty ? Container() : Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _shopNameController,
          keyboardType: TextInputType.text,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0
          ),
          decoration: new InputDecoration(
            hintText: 'Shop Name',
            hintStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white70 : Colors.black54),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  streetAddress() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        streetAddressEmpty ? Container() : Text('Street Address', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _streetAddressController,
          keyboardType: TextInputType.text,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0
          ),
          decoration: new InputDecoration(
            hintText: 'Street Address',
            hintStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white70 : Colors.black54),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  city() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        cityEmpty ? Container() : Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: _cityController,
          keyboardType: TextInputType.text,
          autocorrect: false,
          style: new TextStyle(
            fontSize: 13.0
          ),
          decoration: new InputDecoration(
            hintText: 'City',
            hintStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white70 : Colors.black54),
            border: InputBorder.none
          ),
        )
      ]
    );
  }

  state() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        cityEmpty ? Container() : Text('State', style: TextStyle(fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
              return StateBottomSheet(
                value: stateValue,
                valueChanged: (value) {
                  setState(() {
                    stateValue = value;
                    stateStr = states.states[value];
                    stateAbr = states.abr[value];
                  });
                }
              );
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(stateStr == '' ? 'State' : stateStr, style: TextStyle(color: stateStr == '' ? Colors.grey[400] : globals.darkModeEnabled ? Colors.white : Colors.black, fontSize: 15)),
                    Icon(Icons.keyboard_arrow_down, color: stateStr == '' ? Colors.grey[400] : globals.darkModeEnabled ? Colors.white : Colors.black)
                  ]
                ),
              ]
            )
          )
        )
      ]
    );
  }

  settings() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: globals.darkModeEnabled ? [Colors.black, Color.fromRGBO(45, 45, 45, 1)] : [Colors.grey[500], Colors.grey[50]]
        )
      ),
      child: Column(
        children: <Widget>[
          profilePicture(),
          GestureDetector(
            onTap: () async {
              changeProfilePicture();
            },
            child: Text('Change profile picture', style: TextStyle(color: Colors.blue))
          ),
          Divider(
            height: 15,
            color: Colors.grey[700],
          ),
          username(),
          Divider(
            height: 15,
            color: Colors.grey[700],
          ),
          name(),
          Divider(
            height: 15,
            color: Colors.grey[700],
          ),
          email()
        ]
      )
    );
  }

  password() {
    return GestureDetector(
      onTap: () async {
        final passwordScreen = new ChangePassword();
        var result = await Navigator.push(context, new MaterialPageRoute(builder: (context) => passwordScreen));
        if(result != null) {
          if(result){
            Flushbar(
              flushbarPosition: FlushbarPosition.BOTTOM,
              flushbarStyle: FlushbarStyle.GROUNDED,
              title: "Password Changed",
              message: "Your password was succesfully changed.",
              duration: Duration(seconds: 5),
            )..show(context);
          }
        }
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        color: globals.darkModeEnabled ? Colors.grey[850] : Color.fromARGB(255, 225, 225, 225),
        child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))
      )
    );
  }

  address() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -5.0),
          colors: globals.darkModeEnabled ? [Colors.black, Color.fromRGBO(45, 45, 45, 1)] : [Colors.grey[500], Colors.grey[50]]
        )
      ),
      child: Column(
        children: <Widget>[
          shopName(),
          Divider(
            height: 15,
            color: Colors.grey[700],
          ),
          streetAddress(),
          Divider(
            height: 15,
            color: Colors.grey[700],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: city()
              ),
              Expanded(
                child: state()
              )
            ]
          ),
        ]
      )
    );
  }

  submitUpdatedSettings() async {
    var nameChanged = false;
    var emailChanged = false;
    if(_nameController.text != globals.name) {
      nameChanged = true;
    }
    if(_emailController.text != globals.email){
      emailChanged = true;
    }

    if(nameChanged || emailChanged){
      progressHUD();
      Map result = await updateSettings(context, globals.token, 1, nameChanged ? _nameController.text : null, emailChanged ? _emailController.text : null);
      if(result['error'] == 'false' && result['user'].length > 0) {
        setGlobals(result);
        progressHUD();
        Flushbar(
          flushbarPosition: FlushbarPosition.BOTTOM,
          flushbarStyle: FlushbarStyle.GROUNDED,
          title: "Account Updated",
          message: "Your account has been updated.",
          duration: Duration(seconds: 3),
        )..show(context);
      }
    }

    if(globals.userType == 2) {
      var shopNameChanged = false;
      var addressChanged = false;
      var stateChanged = false;
      var cityChanged = false;
      _shopNameController.text != globals.shopName ? shopNameChanged = true : shopNameChanged = false;
      _streetAddressController.text != globals.shopAddress ? addressChanged = true : addressChanged = false;
      _cityController.text != globals.city ? cityChanged = true : cityChanged = false;
      stateAbr != globals.state ? stateChanged = true : stateChanged = false;

      if(shopNameChanged || addressChanged || stateChanged || cityChanged) {
        progressHUD();
        var res = await validateAddress('${_streetAddressController.text}, ${_cityController.text}, $stateAbr');
        if(res){
          Map result = await updateBarberSettings(context, globals.token, shopNameChanged ? _shopNameController.text : null, addressChanged ? _streetAddressController.text : null, stateChanged ? stateAbr : null, cityChanged ? _cityController.text : null);
          if(result['error'] == 'false' && result['user']['user'].length > 0) {
            setGlobals(result['user']);
            progressHUD();
            Flushbar(
              flushbarPosition: FlushbarPosition.BOTTOM,
              flushbarStyle: FlushbarStyle.GROUNDED,
              title: "Account Updated",
              message: "Your account has been updated.",
              duration: Duration(seconds: 3),
            )..show(context);
          }
        }else {
          progressHUD();
          showErrorDialog(context, 'Address Error', 'The address you provided is not valid');
        }
      }
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
                  settings(),
                  globals.userType == 2 ? address() : Container(),
                  password(),
                ],
              ),
            )
          ),
          globals.userType != 2 ? _emailController.text != globals.email || _nameController.text != globals.name ? Row(
            children: <Widget>[
              Expanded(
                child: new GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    submitUpdatedSettings();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: new LinearGradient(
                        colors: globals.darkModeEnabled ? [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent] : [Color.fromARGB(255, 54, 121, 255), Colors.lightBlueAccent],
                      )
                    ),
                    child: Center(
                      child: Text(
                        'Save',
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
          ) : Container() : 
          _emailController.text != globals.email || _nameController.text != globals.name || _shopNameController.text != globals.shopName || _streetAddressController.text != globals.shopAddress || _cityController.text != globals.city || stateAbr != globals.state?
          Row(
            children: <Widget>[
              Expanded(
                child: new GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    submitUpdatedSettings();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: new LinearGradient(
                        colors: globals.darkModeEnabled ? [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent] : [Color.fromARGB(255, 54, 121, 255), Colors.lightBlueAccent],
                      )
                    ),
                    child: Center(
                      child: Text(
                        'Save',
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
          ) : Container(),
          Padding(padding: EdgeInsets.only(bottom: 24))
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          centerTitle: true,
          title: new Text('Account Settings')
        ),
        body: new Stack(
          children: <Widget> [
            buildBody(),
            _progressHUD
          ]
        )
      )
    );
  }
}