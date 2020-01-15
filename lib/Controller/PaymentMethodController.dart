import 'package:flutter/material.dart';
import 'package:trimmz/Model/ClientPaymentMethod.dart';
import '../globals.dart' as globals;
import 'HomeHubController.dart';
import '../Calls/FinancialCalls.dart';
import '../Calls/StripeConfig.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

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
    if(globals.sqCustomerId != null) {
      if(globals.sqCustomerId != '') {
        await spGetClientPaymentMethod(context, globals.sqCustomerId);
      }
    }
  }

  void setError() {

  }

  addPaymentMethod() async {
    await StripePayment.paymentRequestWithCardForm(
      CardFormPaymentRequest(),
    ).then((PaymentMethod paymentMethod) async {
        
    }).catchError(setError);
  }

  buildBody() {
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