import 'package:flutter/material.dart';
import '../dialogs.dart';
import '../globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:line_icons/line_icons.dart';
import '../View/ModalSheets.dart';
// import 'package:stripe_payment/stripe_payment.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import '../View/TextFieldFormatter.dart';
import 'package:flutter/services.dart';
import '../Calls/FinancialCalls.dart';
import '../View/DatePicker.dart';
import 'package:intl/intl.dart';
import '../Calls/GeneralCalls.dart';
import 'MobileTransactionsController.dart';

class MobileTransactionSetup extends StatefulWidget {
  MobileTransactionSetup({Key key}) : super (key: key);

  @override
  MobileTransactionSetupState createState() => new MobileTransactionSetupState();
}

class MobileTransactionSetupState extends State<MobileTransactionSetup> {
  TextEditingController cardNumber = new TextEditingController();
  TextEditingController expDate = new TextEditingController();
  TextEditingController ccv = new TextEditingController();
  TextEditingController firstName = new TextEditingController();
  TextEditingController lastName = new TextEditingController();
  TextEditingController last4SSN = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  final expDateFocus = new FocusNode();
  final ccvFocus = new FocusNode();
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  String _payoutMethod = 'standard';
  var type = CreditCardType.unknown;
  String dob = '';

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
    if(firstName.text != '' && lastName.text != '' && cardNumber.text != '' && expDate.text != '' && ccv.text != '' && dob != '' && last4SSN.text != '' && last4SSN.text.length == 4) {
      var number = cardNumber.text.replaceAll(new RegExp(r"\s\b|\b\s"), "");
      var exp = expDate.text.split('/');
      var dob2 = DateFormat('yyyy/MM/dd').format(DateTime.parse(dob)).split('/');
      progressHUD();
      var res = await spCreateConnectAccount(context, firstName.text, lastName.text, exp[0], exp[1], number, _payoutMethod, dob2, last4SSN.text);
      if(res.length > 0) {
        var res2 = await updatePayoutSettings(context, globals.token, res['external_accounts']['data'][0]['id'], _payoutMethod, res['external_accounts']['data'][0]['account']);
        progressHUD();
        if(res2){
          setState(() {
            globals.spPayoutId = res['external_accounts']['data'][0]['id'];
            globals.spAccountId = res['external_accounts']['data'][0]['account'];
          });
          print(globals.spPayoutId);
          print(globals.spAccountId);
          final mobileTransaction = new MobileTransactionScreen();
          Navigator.push(context, new MaterialPageRoute(builder: (context) => mobileTransaction));
        }
      }
    }else {
      showErrorDialog(context, "Missing Fields", "Missing required information. Enter all required fields.");
    }
  }

  void setError() {

  }

  // changePayoutCard() async {
  //   await StripePayment.paymentRequestWithCardForm(
  //     CardFormPaymentRequest(),
  //   ).then((PaymentMethod paymentMethod) async {
      
  //   }).catchError(setError);
  // }

  // addPayoutCard() async {
  //   await StripePayment.paymentRequestWithCardForm(
  //     CardFormPaymentRequest(),
  //   ).then((PaymentMethod paymentMethod) async {
  //     print(paymentMethod.toJson());
  //   }).catchError(setError);
  // }

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
                )
              ]
            )
          )
        ]
      )
    );
  }

  accountName() {
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
          Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: <Widget> [
              Expanded(
                child: TextFormField(
                  controller: firstName,
                  decoration: InputDecoration(
                    labelText: "First Name"
                  ),
                  autocorrect: false,
                )
              ),
              Padding(padding: EdgeInsets.all(10)),
              Expanded(
                child: TextFormField(
                  controller: lastName,
                  decoration: InputDecoration(
                    labelText: "Last Name"
                  ),
                  autocorrect: false,
                )
              )
            ]
          )
        ]
      )
    );
  }

  dateOfBirth() {
    final DateFormat dateFormat = new DateFormat('MM/dd/yyyy');
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
        children: <Widget> [
          Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
          DateTimeField(
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                initialDate: currentValue ?? DateTime.now()
              );
            },
            readOnly: true,
            enabled: true,
            initialValue: dob.length == 0 ? null : DateFormat('yyyy/MM/dd').parse(dob.split(' ')[0].replaceAll('-', '/')),
            format: dateFormat,
            autofocus: false,
            controller: dobController,
            decoration: InputDecoration(
              labelText: "Date of Birth",
            ),
            onChanged: (value) {
              if (value != null) {
                dob = value.toString();
              }
              else {
                dob = "";
              }
            },
          ),
        ]
      )
    );
  }

  ssnLast4() {
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
        children: <Widget> [
          Text('Identity Verification', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: last4SSN,
            inputFormatters: [
              LengthLimitingTextInputFormatter(4),
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Last 4 of SSN"
            ),
            autocorrect: false,
          )
        ]
      )
    );
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
              new TextSpan(text: 'By clicking \'submit\', you agree to '),
              new TextSpan(text: 'Stripe Services Agreement ', style: TextStyle(color: Colors.blue)),
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
                  accountName(),
                  dateOfBirth(),
                  ssnLast4(),
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