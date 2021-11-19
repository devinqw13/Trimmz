import 'package:flutter/material.dart';
import 'package:trimmz/Screens/LoginScreen/Components/Body.dart';
import 'package:trimmz/SizeConfig.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen();

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool _loadingInProgress = false;

  @override
  void initState() {
    super.initState();

  }

  void dismissProgressHUD() {
    setState(() {
      _loadingInProgress = !_loadingInProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Stack(
            children: [
              Body(
                dismissProgressHUD: dismissProgressHUD,
              ),
              // _loadingInProgress ? 
              // SpinKitWave(
              //   size: 40,
              //   color: primaryOrange
              // ) : Container()
            ],
          )
        )
      ),
    );
  }
}