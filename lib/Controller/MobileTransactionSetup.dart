import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:line_icons/line_icons.dart';
import '../View/ModalSheets.dart';
import '../Model/ClientPaymentMethod.dart';
import 'package:stripe_payment/stripe_payment.dart';

class MobileTransactionSetup extends StatefulWidget {
  MobileTransactionSetup({Key key}) : super (key: key);

  @override
  MobileTransactionSetupState createState() => new MobileTransactionSetupState();
}

class MobileTransactionSetupState extends State<MobileTransactionSetup> {
  ProgressHUD _progressHUD;
  ClientPaymentMethod payoutCard;
  bool _loadingInProgress = false;
  String _payoutMethod = 'standard';

  void initState() {
    super.initState();

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

  submitMobileTransaction() async {
    //var res = await spCreateConnectAccount(context, firstName, lastName, expMonth, expYear, number);
  }

  void setError() {

  }

  changePayoutCard() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
      
    }).catchError(setError);
  }

  addPayoutCard() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
      print(paymentMethod.toJson());
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

  agreement() {
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
      child: Container(
        child: RichText(
          textAlign: TextAlign.center,
          softWrap: true,
          text: new TextSpan(
            children: <TextSpan>[
              new TextSpan(text: 'By clicking \'submit\', you agree to stripe\'s '),
              new TextSpan(text: 'Services Agreement ', style: TextStyle(color: Colors.blue)),
              new TextSpan(text: 'and the '),
              new TextSpan(text: 'Stripe Connected Account Agreement', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      )
    );
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
                  agreement()
                ],
              ),
            )
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: new GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    submitMobileTransaction();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: new LinearGradient(
                        colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent],
                      )
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
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
          ),
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
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new Text('Mobile Pay Setup')
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