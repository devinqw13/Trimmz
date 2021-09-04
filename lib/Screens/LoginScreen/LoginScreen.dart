import 'package:flutter/material.dart';
import 'package:trimmz/Screens/LoginScreen/Components/Body.dart';

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
    return Scaffold(
      body: Stack(
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
      ),
    );
  }
}