import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/PaymentMethodCardWidget.dart';

class PaymentMethodController extends StatefulWidget {
  PaymentMethodController({Key key}) : super (key: key);

  @override
  PaymentMethodControllerState createState() => new PaymentMethodControllerState();
}

class PaymentMethodControllerState extends State<PaymentMethodController> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  void initState() {
    super.initState();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
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

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PaymentMethodCard(
            controllerState: this,
            onPaymentMethodChanged: (method) {

            },
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Notifications",
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