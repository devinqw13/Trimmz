import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/Model/ClientPaymentMethod.dart';
import '../Calls/FinancialCalls.dart';
import '../globals.dart' as globals;
import '../Calls/StripeConfig.dart';
import '../Calls/FinancialCalls.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:progress_hud/progress_hud.dart';
import '../Model/PayoutDetails.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'MobileTransactionSettings.dart';
import '../View/TextFieldFormatter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MobileTransactionScreen extends StatefulWidget {
  MobileTransactionScreen({Key key}) : super (key: key);

  @override
  MobileTransactionScreenState createState() => new MobileTransactionScreenState();
}

class MobileTransactionScreenState extends State<MobileTransactionScreen> {
  TextEditingController cardNumber = new TextEditingController();
  TextEditingController expDate = new TextEditingController();
  TextEditingController ccv = new TextEditingController();
  List<ClientPaymentMethod> payoutCards = [];
  ClientPaymentMethod payoutCard;
  List<PayoutDetails> payoutDetails = [];
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  bool changePayoutCard = false;
  final expDateFocus = new FocusNode();
  final ccvFocus = new FocusNode();
  var type = CreditCardType.unknown;

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

  getPayoutHistory() async {
    var res = await spGetPayoutHistory(context, globals.spAccountId);
    setState(() {
      payoutDetails = res;
    });
  }

  void setError() {

  }

  getCardIcon() {
    if(type == CreditCardType.visa) {
      return Tab(icon: Container(child: Image(image: AssetImage('ccimages/visa1.png'),fit: BoxFit.cover),height: 25));
    }else if(type == CreditCardType.discover){
      return Tab(icon: Container(child: Image(image: AssetImage('ccimages/discover1.png'),fit: BoxFit.cover),height: 25));
    }else if(type == CreditCardType.amex){
      return Tab(icon: Container(child: Image(image: AssetImage('ccimages/amex1.png'),fit: BoxFit.cover),height: 25));
    }else if(type == CreditCardType.mastercard){
      return Tab(icon: Container(child: Image(image: AssetImage('ccimages/mastercard1.png'),fit: BoxFit.cover),height: 25));
    }else {
      return Container(child: Text(''));
    }
  }

  payoutOptions() {
    if(payoutCard != null) {
      if(!changePayoutCard) {
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
                      setState(() {
                        changePayoutCard = true;
                      });
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
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: cardNumber,
                      inputFormatters: [
                        MaskedTextInputFormatter(
                          mask: 'xxxx xxxx xxxx xxxx',
                          separator: ' ',
                        ),
                      ],
                      onChanged: (value) async {
                        var t = detectCCType(value);
                        setState(() {
                          type = t;
                        });

                        if(value.length == 19) {
                          FocusScope.of(context).requestFocus(expDateFocus);
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Card Number",
                        suffixIcon: getCardIcon()
                      ),
                      autocorrect: false,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            focusNode: expDateFocus,
                            controller: expDate,
                            inputFormatters: [
                              MaskedTextInputFormatter(
                                mask: 'xx/xx',
                                separator: '/',
                              ),
                            ],
                            onChanged: (value) {
                              if(value.length == 5) {
                                FocusScope.of(context).requestFocus(ccvFocus);
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Expiration Date",
                            ),
                            autocorrect: false,
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        Expanded(
                          child: TextFormField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(type == CreditCardType.amex ? 4 : 3),
                            ],
                            focusNode: ccvFocus,
                            controller: ccv,
                            onChanged: (value) {
                              if(type == CreditCardType.amex) {
                                if(value.length == 4) {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                }
                              }else {
                                if(value.length == 3) {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                }
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Security Code"
                            ),
                            autocorrect: false,
                          ),
                        )
                      ]
                    ),
                    Padding(padding: EdgeInsets.all(5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              changePayoutCard = false;
                            });
                          },
                          child: Text('Cancel')
                        ),
                        RaisedButton(
                          onPressed: () {

                          },
                          child: Text('Save'),
                        )
                      ]
                    )
                  ]
                )
              )
            ]
          )
        );
      }
    }else {
      return new Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(5),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)
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
      return Container(
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: payoutDetails.length,
          itemBuilder: (context, i) {
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                              child: Text(payoutDetails[i].status, style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Container(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                              child: Text(payoutDetails[i].method, style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                          ]
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text(DateFormat("EEE, MMM d, yyyy").format(payoutDetails[i].arrivalDate), style: TextStyle(fontWeight: FontWeight.bold)),
                        // Text('Txn #: '+payoutDetails[i].id.split("po_")[1], style: TextStyle(color: Colors.grey)),
                      ]
                    )
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Appointment Total', style: TextStyle(color: Colors.grey)),
                            Text('\$1', style: TextStyle(color: Colors.grey))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Fees', style: TextStyle(color: Colors.grey)),
                            Text('\$0.03', style: TextStyle(color: Colors.grey))
                          ],
                        ),
                        Divider(color: Colors.grey[100]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Total Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${payoutDetails[i].amount}', style: TextStyle(fontWeight: FontWeight.bold))
                          ],
                        )
                      ]
                    )
                  )
                ]
              )
            );
          },
        )
      );
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
            child: SingleChildScrollView(
              child: transactionHistory()
            )
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
          title: Text("Mobile Pay"),
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