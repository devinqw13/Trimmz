import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/Model/ClientPaymentMethod.dart';
import 'package:trimmz/View/ModalSheets.dart';
import '../globals.dart' as globals;
import '../Calls/StripeConfig.dart';
import '../Calls/FinancialCalls.dart';
import 'package:stripe_payment/stripe_payment.dart';
import '../functions.dart';
import '../calls.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Model/PayoutDetails.dart';

class MobileTransactionScreen extends StatefulWidget {
  MobileTransactionScreen({Key key}) : super (key: key);

  @override
  MobileTransactionScreenState createState() => new MobileTransactionScreenState();
}

class MobileTransactionScreenState extends State<MobileTransactionScreen> {
  List<ClientPaymentMethod> payoutCards = [];
  List<PayoutDetails> payoutDetails = [];
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  String _payoutMethod = globals.payoutMethod ?? '';

  void initState() {
    super.initState();
    stripeInit();
    getPayoutOptions();
    getPayoutHistory();

    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.blue,
      containerColor: Colors.transparent,
      borderRadius: 8.0,
      loading: false,
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
    if(globals.spCustomerId != null) {
      if(globals.spCustomerId != '') {
        var res = await spGetClientPaymentMethod(context, globals.spCustomerId, 2);
        if(res != null) {
          setState(() {
            payoutCards = res;
          });
        }
      }
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
                setState(() {
                  payoutCards = res;
                });
              }
            }
          }else {
            // payment wasn't able to be authorized
          }
        }
        progressHUD();
    }).catchError(setError);
  }

  payoutOptions() {
    if(payoutCards.length > 0) {
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: payoutCards.length,
              itemBuilder: (context, i) {
                return new GestureDetector(
                  onTap: () {

                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(10),
                    child: Text(payoutCards[i].id)
                  )
                );
              },
            )
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

  payoutMethod() {
    if(payoutCards.length > 0){
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
            Text('Method', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            Text('Standard Transfer')
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
                            Text('Instant Transfer')
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
    }else {
      return Container();
    }
  }

  transactionHistory() {
    if(payoutDetails.length > 0) {

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
          children: <Widget> [
            Text('Transfer History', style: TextStyle(fontWeight: FontWeight.bold)),
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
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  payoutOptions(),
                  payoutMethod(),
                  transactionHistory()
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
          title: Text("Mobile Transactions"),
          actions: <Widget>[
            FlatButton(
              textColor: _payoutMethod != globals.payoutMethod ? Colors.white : Colors.grey,
              onPressed: () {

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