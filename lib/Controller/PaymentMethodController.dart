import 'package:flutter/material.dart';
import 'package:trimmz/Model/ClientPaymentMethod.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/functions.dart';
import '../globals.dart' as globals;
import 'HomeHubController.dart';
import '../Calls/FinancialCalls.dart';
import '../Calls/StripeConfig.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:progress_hud/progress_hud.dart';

class PaymentMethodScreen extends StatefulWidget{
  final bool signup;
  PaymentMethodScreen({Key key, this.signup}) : super (key: key);

  @override
  PaymentMethodScreenState  createState() => PaymentMethodScreenState ();
}

class PaymentMethodScreenState extends State<PaymentMethodScreen> {
  ClientPaymentMethod clientPaymentMethod;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  void initState() {
    super.initState();
    stripeInit();
    initChecks();

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

  void initChecks() async {
    if(globals.spCustomerId != null && globals.spPaymentId != null) {
      if(globals.spCustomerId != '') {
        var res = await spGetClientPaymentMethod(context, globals.spCustomerId, 2);
        if(res != null) {
          if(res != null) {
            for(var item in res) {
              if(item.id == globals.spPaymentId) {
                setState(() {
                  clientPaymentMethod = item;
                });
              }
            }
          }
        }
      }
    }
  }

  void setError() {

  }

  addPaymentMethod() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
        progressHUD();
        if(globals.spCustomerId != null) {
          var res2 = await spAttachCustomerToPM(context, paymentMethod.id, globals.spCustomerId);
          if(res2.length > 0) {
            var res4 = await spGetClientPaymentMethod(context, globals.spCustomerId, 2); // return list of cards
            if(res4 != null) {
              for(var item in res4) {
                if(item.id == paymentMethod.id) {
                  var res = await updateSettings(context, globals.token, 1, '', '', '', item.id);
                  if(res.length > 0) {
                    setGlobals(res);
                    setState(() {
                      clientPaymentMethod = item;
                    });
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

                var res = await spGetClientPaymentMethod(context, globals.spCustomerId, 1);
                if(res != null) {
                  setState(() {
                    clientPaymentMethod = res;
                  });
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

  changePaymentMethod() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
      progressHUD();
      var res1 = await spDetachCustomerFromPM(context, clientPaymentMethod.id);
      if(res1.length > 0) {
        var res2 = await spAttachCustomerToPM(context, paymentMethod.id, globals.spCustomerId);
        if(res2.length > 0) {
          var res3 = await spCreatePaymentIntent(context, paymentMethod.id, globals.spCustomerId, "100");
          if(res3.length > 0){
            var res4 = await spGetClientPaymentMethod(context, globals.spCustomerId, 1);
            if(res4 != null) {
              setState(() {
                clientPaymentMethod = res4;
              });
            }
          }
        }
      }
      progressHUD();
    }).catchError(setError);
  }

  buildBody() {
    if(clientPaymentMethod == null){
      return new Column(
        children: <Widget> [
          Container(
            margin: EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width,
            child: FlatButton(
              color: Color.fromARGB(255, 21, 21, 21),
              onPressed: () {
                addPaymentMethod();
              },
              child: Text('Add Payment Method')
            )
          )
        ]
      );
    }else {
      return new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10),
            color: Color.fromARGB(255, 21, 21, 21),
            margin: EdgeInsets.all(5),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    clientPaymentMethod.icon,
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
                    Text(clientPaymentMethod.lastFour)
                  ]
                ),
                FlatButton(
                  textColor: Colors.blue,
                  onPressed: () {
                    changePaymentMethod();
                  },
                  child: Text('Change')
                )
              ]
            )
          )
        ]
      );
    }
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
          automaticallyImplyLeading: widget.signup ? false : true,
          title: Text("Payment Method"),
          actions: <Widget>[
            widget.signup ? FlatButton(
              onPressed: () {
                final homeHubScreen = new HomeHubScreen();
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => homeHubScreen));
              },
              child: Text('Skip')
            ) : Container()
          ],
        ),
        body: widget.signup ? new WillPopScope(
        onWillPop: () async {
          return false;
        }, child: Stack(
            children: <Widget>[
              buildBody(),
              _progressHUD
            ]
          )
        ) : Stack(
          children: <Widget> [
            buildBody(),
            _progressHUD
          ]
        )
      )
    );
  }
}