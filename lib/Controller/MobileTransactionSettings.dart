import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/View/ModalSheets.dart';
import '../Calls/FinancialCalls.dart';
import '../globals.dart' as globals;
import '../Calls/StripeConfig.dart';
import '../Calls/GeneralCalls.dart';
import 'package:progress_hud/progress_hud.dart';

class MobileTransactionSettingsScreen extends StatefulWidget {
  MobileTransactionSettingsScreen({Key key}) : super (key: key);

  @override
  MobileTransactionSettingsScreenState createState() => new MobileTransactionSettingsScreenState();
}

class MobileTransactionSettingsScreenState extends State<MobileTransactionSettingsScreen> {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  String _payoutMethod = globals.spPayoutMethod;

  void initState() {
    super.initState();
    stripeInit();

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

  payoutMethod() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Color.fromRGBO(45, 45, 45, 1)]
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Transfer Method', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _payoutMethod = 'standard';
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _payoutMethod,
                            value: 'standard',
                            onChanged: (value) {
                              setState(() {
                                _payoutMethod = value;
                              });
                            },
                          ),
                          Text('Standard')
                        ]
                      )
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _payoutMethod = 'instant';
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Radio(
                            activeColor: Colors.blue,
                            groupValue: _payoutMethod,
                            value: 'instant',
                            onChanged: (value) {
                              setState(() {
                                _payoutMethod = value;
                              });
                            },
                          ),
                          Text('Instant')
                        ]
                      )
                    )
                  )
                ]
              ),
              IconButton(
                onPressed: () {
                  showPayoutInfoModalSheet(context);
                },
                icon: Icon(LineIcons.info_circle),
              )
            ]
          )
        ]
      )
    );
  }

  buildBody() {
    return new Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  payoutMethod(),
                ],
              ),
            )
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: globals.userColor,
        brightness: globals.userBrightness,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Mobile Pay Settings"),
          actions: <Widget>[
            FlatButton(
              textColor: _payoutMethod != globals.spPayoutMethod ? Colors.white : Colors.grey,
              onPressed: () async {
                progressHUD();
                var res = await spUpdateConnectAccount(context, globals.spAccountId, _payoutMethod);
                if(res.length > 0) {
                  var res2 = await updatePayoutSettings(context, globals.token, null, _payoutMethod);
                  progressHUD();
                  if(res2) {
                    setState(() {
                      globals.spPayoutMethod = _payoutMethod;
                    });
                  }
                }
              },
              child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
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