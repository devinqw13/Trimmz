import 'package:flutter/material.dart';
import 'package:trimmz/Model/ClientPaymentMethod.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/functions.dart';
import '../globals.dart' as globals;
import 'HomeHubController.dart';
import '../Calls/FinancialCalls.dart';
import '../Calls/StripeConfig.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentMethodScreen extends StatefulWidget{
  final bool signup;
  PaymentMethodScreen({Key key, this.signup}) : super (key: key);

  @override
  PaymentMethodScreenState  createState() => PaymentMethodScreenState ();
}

class PaymentMethodScreenState extends State<PaymentMethodScreen> {
  ClientPaymentMethod clientPaymentMethod;

  void initState() {
    super.initState();
    stripeInit();
    initChecks();
  }

  void initChecks() async {
    if(globals.spCustomerId != null) {
      if(globals.spCustomerId != '') {
        var res = await spGetClientPaymentMethod(context, globals.spCustomerId, 1);
        if(res != null) {
          setState(() {
            clientPaymentMethod = res;
          });
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
        var res1 = await spCreateCustomer(context, paymentMethod.id);
        if(res1.length > 0) {
          String spCustomerId = res1['id'];
          var res2 = await spCreatePaymentIntent(context, paymentMethod.id, spCustomerId, '100');
          if(res2.length > 0) {
            var res3 = await updateSettings(context, globals.token, 1, '', '', spCustomerId);
            if(res3.length > 0) {
              setGlobals(res3);

            }
          }else {
            // payment wasn't able to be authorized
          }
        }
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
              color: Colors.grey[850],
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
            color: Colors.grey[850],
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
              buildBody()
            ]
          )
        ) : buildBody(),
      )
    );
  }
}