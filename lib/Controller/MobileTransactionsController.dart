import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/Model/ClientPaymentMethod.dart';
import 'package:trimmz/View/ModalSheets.dart';
import '../globals.dart' as globals;
import '../Calls/StripeConfig.dart';
import '../Calls/FinancialCalls.dart';
import 'package:stripe_payment/stripe_payment.dart';
import '../functions.dart';
import '../Calls/GeneralCalls.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Model/PayoutDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MobileTransactionSettings.dart';

class MobileTransactionScreen extends StatefulWidget {
  MobileTransactionScreen({Key key}) : super (key: key);

  @override
  MobileTransactionScreenState createState() => new MobileTransactionScreenState();
}

class MobileTransactionScreenState extends State<MobileTransactionScreen> {
  List<ClientPaymentMethod> payoutCards = [];
  ClientPaymentMethod payoutCard;
  List<PayoutDetails> payoutDetails = [];
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  void initState() {
    super.initState();
    stripeInit();
    getPayoutOptions();
    getPayoutHistory();

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

  getPayoutOptions() async {
    var res = await spGetAccountPayoutCard(context, globals.spAccountId, globals.spPayoutId);
    if(res != null) {
      setState(() {
        payoutCard = res;
      });
    }
  }

  getPayoutHistory() {
  }

  void setError() {

  }

  addPayoutCard() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
        progressHUD();
        if(globals.spCustomerId != null){
          var res2 = await spAttachCustomerToPM(context, paymentMethod.id, globals.spCustomerId);
          if(res2.length > 0) {
            var res4 = await spGetClientPaymentMethod(context, globals.spCustomerId, 2); // return list of cards
            if(res4 != null) {
              for(var item in res4) {
                if(item.id == paymentMethod.id) {
                  var res = await updatePayoutSettings(context, globals.token, item.id, null);
                  if(res) {
                    setState(() {
                      globals.spPayoutId = paymentMethod.id;
                      payoutCard = item;
                    });
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString('spPayoutId', paymentMethod.id);
                  }
                }
              }
            }
          }
        }else {
          var res1 = await spCreateCustomer(context, paymentMethod.id);
          if(res1.length > 0) {
            String spCustomerId = res1['id'];
            var res2 = await spCreatePaymentIntent(context, paymentMethod.id, spCustomerId, '100');
            if(res2.length > 0) {
              var res3 = await updateSettings(context, globals.token, 1, '', '', spCustomerId);
              if(res3.length > 0) {
                setGlobals(res3);
                var res = await spGetClientPaymentMethod(context, globals.spCustomerId, 2);
                if(res != null) {
                  for(var item in res) {
                    if(item.id == paymentMethod.id) {
                      var res = await updatePayoutSettings(context, globals.token, item.id, null);
                      if(res) {
                        setState(() {
                          globals.spPayoutId = paymentMethod.id;
                          payoutCard = item;
                        });
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('spPayoutId', paymentMethod.id);
                      }
                    }
                  }
                }
              }
            }else {
              // payment wasn't able to be authorized
            }
          }
        }
        progressHUD();
    }).catchError(setError);
  }

  changePayoutCard() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
      progressHUD();
      var res1 = await spDetachCustomerFromPM(context, payoutCard.id);
      if(res1.length > 0) {
        var res2 = await spAttachCustomerToPM(context, paymentMethod.id, globals.spCustomerId);
        if(res2.length > 0) {
          var res4 = await spGetClientPaymentMethod(context, globals.spCustomerId, 2); // return list of cards
          if(res4 != null) {
            for(var item in res4) {
              var res3 = await updatePayoutSettings(context, globals.token, paymentMethod.id, null);
              if(res3){
                if(item.id == paymentMethod.id) {
                  setState(() {
                    globals.spPayoutId = paymentMethod.id;
                    payoutCard = item;
                  });
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('spPayoutId', paymentMethod.id);
                }
              }
            }
          }
        }
      }
      progressHUD();
    }).catchError(setError);
  }

  payoutOptions() {
    if(payoutCard != null) {
      return new Container(
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
            Text('Direct Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    payoutCard.icon,
                    Padding(padding: EdgeInsets.all(10)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Padding(padding: EdgeInsets.all(3)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Padding(padding: EdgeInsets.all(3)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: Colors.white)),
                    Padding(padding: EdgeInsets.all(3)),
                    Text(payoutCard.lastFour)
                  ]
                ),
                FlatButton(
                  textColor: Colors.blue,
                  onPressed: () {
                    changePayoutCard();
                  },
                  child: Text('Change')
                )
              ]
            ),
          ]
        )
      );
    }else {
      return new Container(
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
            Text('Direct Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  addPayoutCard();
                },
                child: Row(
                  children: <Widget> [
                    Icon(LineIcons.plus, size: 15, color: Colors.blue),
                    Text('Add Card', style: TextStyle(color: Colors.blue))
                  ]
                )
              )
            )
          ]
        )
      );
    }
  }

  payoutSettings() {
    return GestureDetector(
      onTap: () async {
        final mobileTransSettingsScreen = new MobileTransactionSettingsScreen();
        Navigator.push(context, new MaterialPageRoute(builder: (context) => mobileTransSettingsScreen));
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        color: Colors.grey[850],
        child: Row(
          children: <Widget> [
            Text('Settings', style: TextStyle(fontWeight: FontWeight.bold))
          ]
        )
      )
    );
  }

  transactionHistory() {
    if(payoutDetails.length > 0) {

    }else {
      return new Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
                    Text(
                      'No Direct Deposit History',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * .018,
                        color: Colors.grey[600]
                      )
                    ),
                  ]
                )
              )
            )
          ]
        )
      );
    }

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
                  payoutOptions(),
                  payoutSettings(),
                ],
              ),
            )
          ),
          Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            child: Text('Transfer History', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: transactionHistory()
          )
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
          title: Text("Mobile Transactions"),
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