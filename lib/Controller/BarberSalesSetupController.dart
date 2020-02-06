import 'package:flutter/material.dart';
import '../Model/availability.dart';
import '../globals.dart' as globals;
import 'BarberHubController.dart';
import '../Model/Packages.dart';
import 'package:line_icons/line_icons.dart';
import '../View/AddPackageModal.dart';
import 'package:intl/intl.dart';
import '../calls.dart';
import '../View/SetAvailabilityModal.dart';
import '../states.dart' as states;
import '../View/StateBottomSheetPicker.dart';
import '../Model/ClientPaymentMethod.dart';
import 'package:stripe_payment/stripe_payment.dart';
import '../Calls/StripeConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../functions.dart';
import '../Calls/FinancialCalls.dart';
import 'package:progress_hud/progress_hud.dart';

class BarberSalesSetup extends StatefulWidget{
  final String address;
  final String city;
  final String state;
  final String stateAbr;
  final String zipcode;
  final int stateValue;
  BarberSalesSetup({Key key, this.address, this.city, this.state, this.stateAbr, this.zipcode, this.stateValue}) : super (key: key);

  @override
  BarberSalesSetupState  createState() => BarberSalesSetupState ();
}

class BarberSalesSetupState extends State<BarberSalesSetup> {
  TextEditingController _addressTextController = new TextEditingController();
  TextEditingController _cityTextController = new TextEditingController();
  TextEditingController _zipcodeTextController = new TextEditingController();
  TextEditingController _shopNameTextController = new TextEditingController();
  int stateValue;
  String state = '';
  String stateAbr = '';
  List<Packages> packages = [];
  List<Availability> availability = [];
  ClientPaymentMethod payoutCard;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  @override
  void initState() {
    super.initState();
    stripeInit();
    getBarberInfo();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    setState(() {
      stateValue = widget.stateValue;
      stateAbr = widget.stateAbr;
      state = widget.state;
      _addressTextController.text = widget.address;
      _cityTextController.text = widget.city;
      _zipcodeTextController.text = widget.zipcode;
    });
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

  getBarberInfo() async {
    var res1 = await getBarberAvailability(context, globals.token);
    setState(() {
      availability = res1;
    });
  }

  shopInfo() {
    return new Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Colors.grey[850]]
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Shop Infomation',
            style: TextStyle(
              fontWeight: FontWeight.bold
            )
          ),
          Padding(padding: EdgeInsets.all(5)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Shop Name', style: TextStyle(fontSize: 15)),
              TextField(
                controller: _shopNameTextController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                style: new TextStyle(
                  fontSize: 15.0,
                  color: Colors.white
                ),
                decoration: new InputDecoration(
                  hintText: 'Shop Name',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none
                ),
              )
            ]
          ),
          Padding(padding: EdgeInsets.all(5)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Shop Address', style: TextStyle(fontSize: 15)),
              TextField(
                controller: _addressTextController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                style: new TextStyle(
                  fontSize: 15.0,
                  color: Colors.white
                ),
                decoration: new InputDecoration(
                  hintText: 'Shop Address',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none
                ),
              )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('City'),
                  Container(
                    width: MediaQuery.of(context).size.width * .30,
                    child: TextField(
                      controller: _cityTextController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: new TextStyle(
                        fontSize: 15.0,
                        color: Colors.white
                      ),
                      decoration: new InputDecoration(
                        hintText: 'City',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none
                      ),
                    )
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('State'),
                  Padding(padding: EdgeInsets.all(6)),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                        return StateBottomSheet(
                          value: stateValue,
                          valueChanged: (value) {
                            setState(() {
                              stateValue = value;
                              state = states.states[value];
                              stateAbr = states.abr[value];
                            });
                          }
                        );
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width * .30,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(state == '' ? 'State' : state, style: TextStyle(color: state == '' ? Colors.grey[400] : Colors.white, fontSize: 15)),
                              Icon(Icons.keyboard_arrow_down, color: state == '' ? Colors.grey[400] : Colors.white)
                            ]
                          ),
                        ]
                      )
                    )
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Zipcode'),
                  Container(
                    width: MediaQuery.of(context).size.width * .30,
                    child: TextField(
                      controller: _zipcodeTextController,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      style: new TextStyle(
                        fontSize: 15.0,
                        color: Colors.white
                      ),
                      decoration: new InputDecoration(
                        hintText: 'Zipcode',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none
                      ),
                    )
                  )
                ],
              ),
            ],
          ),
        ]
      )
    );
  }

  barberPackages() {
    return new Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Colors.grey[850]]
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Add Packages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(2),),
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.all(5),
                    child: Center(child: Text(packages.length.toString(), textAlign: TextAlign.center)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800]
                    ),
                  )
                ]
              ),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 5, right: 10.0),
                    child: GestureDetector(
                      onTap: () async {
                        showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: true, builder: (builder) {
                          return AddPackageBottomSheet(
                            updatePackages: (value) {
                              setState(() {
                                packages = value;
                              });
                            },
                          );
                        });
                      },
                      child: Icon(LineIcons.plus, color: Colors.blue)
                    )
                  )
                ]
              )
            ],
          ),
          packages.length == 0 ?
          Container(): Container(
            child: ListView.builder(
              reverse: true,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: packages.length,
              padding: const EdgeInsets.all(5.0),
              itemBuilder: (context, i) {
                return new ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget> [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget> [
                          Text(packages[i].name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500
                            )
                          ),
                          Text(packages[i].duration + (int.parse(packages[i].duration) > 1 ? ' Mins' : ' Min'),
                            style: TextStyle(
                              color: Colors.grey
                            )
                          )
                        ]
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(12),
                            child: Text('\$' + packages[i].price, style: TextStyle(fontSize: 17.0)),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              shape: BoxShape.circle
                            ),
                          )
                        ],
                      )
                    ]
                  )
                );
              }
            )
          )
        ],
      )
    );
  }

  showSetAvailableTime(BuildContext context, Availability aDay) {
    showModalBottomSheet(context: context, backgroundColor: Colors.black.withOpacity(0), isScrollControlled: true, isDismissible: false, builder: (builder) {
      bool isClosedChecked;
      if(aDay.start == null && aDay.end == null){
        isClosedChecked = true;
      }else {
        if(aDay.start == '00:00:00' && aDay.end == '00:00:00'){
          isClosedChecked = true;
        }else {
          isClosedChecked = false;
        }
      }
      return AvailabilityBottomSheet(
        switchValue: isClosedChecked,
        avail: aDay,
        valueChanged: (value) {
          setState(() {
            isClosedChecked = value;
          });
        },
        getAvailability: (avail) {
          setState(() {
            availability = avail;
          });
        },
      );
    });
  }

  barberDBAvailability(BuildContext context) {
    return new Column(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: availability.length,
          itemBuilder: (context, i){
            final todayDay = DateFormat.EEEE().format(DateTime.now());
            bool isNull = false;
            String start;
            String end;
            final df = new DateFormat('hh:mm a');
            if(availability[i].start != null && availability[i].end != null) {
              if(availability[i].start == '00:00:00' && availability[i].end == '00:00:00') {
                isNull = true;
              }else {
                start = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].start).toString()));
                end = df.format(DateTime.parse(DateFormat('Hms', 'en_US').parse(availability[i].end).toString()));
              }
            }else {
              isNull = true;
            }
            return Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      todayDay == availability[i].day ? Container(height: 5.0, width: 5.0, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),) : Container(height: 5.0, width: 5.0),
                      Padding(padding: EdgeInsets.all(5.0),),
                      Text(availability[i].day, style: TextStyle(fontSize: 18.0)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showSetAvailableTime(context, availability[i]);
                        },
                        child: Text(
                          isNull ? 'Closed' : start + " to " + end,
                          style: TextStyle(
                            fontSize: 17.0
                          ),
                        )
                      ),
                    ],
                  )
                ],
              )
            );
          },
        )
      ],
    );
  }

  barberAvailability() {
    return new Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5.0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Colors.grey[850]]
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Set Availability',
            style: TextStyle(
              fontWeight: FontWeight.bold
            )
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10.0, right: 20.0),
            child: barberDBAvailability(context)
          )
        ],
      )
    );
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

  payoutSetup() {
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

  buildBody() {
    return new Container(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  shopInfo(),
                  barberPackages(),
                  barberAvailability(),
                  payoutSetup()
                ],
              ),
            )
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: new GestureDetector(
                  onTap: () {
                    if(_addressTextController.text != widget.address || _cityTextController.text != widget.city || _zipcodeTextController.text != widget.zipcode || _shopNameTextController.text != '') {
                      
                      final barberHubScreen = new BarberHubScreen();
                      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => barberHubScreen));
                    }else {
                      final barberHubScreen = new BarberHubScreen();
                      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => barberHubScreen));
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                    // padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                    constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: new LinearGradient(
                        colors: [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent],
                      )
                    ),
                    child: Center(
                      child: Text(
                        'Save & Complete',
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
          automaticallyImplyLeading: false,
          title: Text("Additional Setup"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                final barberHubScreen = new BarberHubScreen();
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => barberHubScreen));
              },
              child: Text('Skip')
            )
          ],
        ),
        body: new WillPopScope(
        onWillPop: () async {
          return false;
        }, child: Stack(
            children: <Widget>[
              buildBody(),
              _progressHUD
            ]
          )
        ),
      )
    );
  }
}