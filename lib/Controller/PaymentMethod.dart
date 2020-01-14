import 'package:flutter/material.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/google_pay_constants.dart' as google_pay_constants;
import 'dart:io' show Platform;
import '../Model/SqPaymentMethodConfig.dart';
import '../globals.dart' as globals;
import '../Model/ClientPaymentMethod.dart';
import '../TransactionService.dart';
import 'HomeHubController.dart';

class PaymentMethod extends StatefulWidget{
  final bool signup;
  PaymentMethod({Key key, this.signup}) : super (key: key);

  @override
  HomeHubTabWidgetState  createState() => HomeHubTabWidgetState ();
}

class HomeHubTabWidgetState extends State<PaymentMethod> {
  bool isLoading = true;
  bool applePayEnabled = false;
  bool googlePayEnabled = false;
  List<ClientPaymentMethod> paymentMethod = [];
  bool isCustomer = false;
  Brand cardBrand;
  String customerId = '';
  String ccof = '';

  @override
  void initState() {
    super.initState();
    checkExistingCustomer();
    _initSquarePayment();
  }

  checkExistingCustomer() async {
    var customers = await getCustomerTS(context);
    if(customers != null) {
      for(var item in customers) {
        if(item['reference_id'] == globals.token) {
          setState(() {
            isCustomer = true;
          });
        }
      }
    }
  }

  setSquareGlobals() {
    setState(() {
      globals.sqccof = ccof;
      globals.sqCustomerId = customerId;
    });
    print('globals');
    print(globals.sqccof);
    print(globals.sqCustomerId);
  }

  buildBody() {
    return new Column(
      children: <Widget> [
        Container(
          margin: EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width,
          child: !isCustomer ? FlatButton(
            color: Colors.grey[850],
            onPressed: () {_onStartCardEntryFlow();},
            child: Text('Add Payment Method')
          ) : Container(child: Text(cardBrand.name))
        )
      ]
    );
  }

  Future<void> _initSquarePayment() async {
    await InAppPayments.setSquareApplicationId(squareApplicationId);

    var canUseApplePay = false;
    var canUseGooglePay = false;
    if (Platform.isAndroid) {
      await InAppPayments.initializeGooglePay(
          squareLocationId, google_pay_constants.environmentTest);
      canUseGooglePay = await InAppPayments.canUseGooglePay;
    } else if (Platform.isIOS) {
      await _setIOSCardEntryTheme();
      await InAppPayments.initializeApplePay(applePayMerchantId);
      canUseApplePay = await InAppPayments.canUseApplePay;
    }

    setState(() {
      isLoading = false;
      applePayEnabled = canUseApplePay;
      googlePayEnabled = canUseGooglePay;
    });
  }

  Future _setIOSCardEntryTheme() async {
    var themeConfiguationBuilder = IOSThemeBuilder();
    themeConfiguationBuilder.saveButtonTitle = 'Save';
    themeConfiguationBuilder.errorColor = RGBAColorBuilder()
      ..r = 255
      ..g = 0
      ..b = 0;
    themeConfiguationBuilder.tintColor = RGBAColorBuilder()
      ..r = 33
      ..g = 156
      ..b = 51;
    themeConfiguationBuilder.keyboardAppearance = KeyboardAppearance.dark;
    themeConfiguationBuilder.messageColor = RGBAColorBuilder()
      ..r = 114
      ..g = 114
      ..b = 114;
    themeConfiguationBuilder.backgroundColor = RGBAColorBuilder()
      ..r = 56
      ..g = 56
      ..b = 56;
    themeConfiguationBuilder.foregroundColor = RGBAColorBuilder()
      ..r = 92
      ..g = 92
      ..b = 92;
    themeConfiguationBuilder.textColor = RGBAColorBuilder()
      ..r = 225
      ..g = 225
      ..b = 225;
    themeConfiguationBuilder.placeholderTextColor = RGBAColorBuilder()
      ..r = 225
      ..g = 225
      ..b = 225;

    await InAppPayments.setIOSCardEntryTheme(themeConfiguationBuilder.build());
  }

  Future<void> _onStartCardEntryFlow() async {
  await InAppPayments.startCardEntryFlow(
      onCardNonceRequestSuccess: _onCardEntryCardNonceRequestSuccess,
      onCardEntryCancel: _onCancelCardEntryFlow);

  }

  void _onCancelCardEntryFlow() {
    // Handle the cancel callback
  }

  /*
  * Callback when successfully get the card nonce details for processig
  * card entry is still open and waiting for processing card nonce details
  */
  void _onCardEntryCardNonceRequestSuccess(CardDetails result) async {
    try {
      setState(() {
        cardBrand = result.card.brand;
      });

      var res = await createCustomerTS(context);
      var res2 = await createCustomerCardTS(context, res['id'], result.nonce);
      print(res2);
      if(res2.length > 0) {
        setState(() {
          customerId = res['id'];
          ccof = res2['id'];
        });
        setSquareGlobals();
        await chargeCardV2TS(context, 100, ccof, customerId);
      }

      //await chargeCardV2TS(context, 100, result.nonce);

      InAppPayments.completeCardEntry(
          onCardEntryComplete: _onCardEntryComplete);
    } on ChargeException catch (ex) {
      // payment failed to complete due to error
      // notify card entry to show processing error
      InAppPayments.showCardNonceProcessingError(ex.toString());
    }
  }

  /*
  * Callback when the card entry is closed after call 'completeCardEntry'
  */
  void _onCardEntryComplete() {
    // Update UI to notify user that the payment flow is finished successfully
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