import 'package:flutter/material.dart';
import '../Model/availability.dart';
import '../globals.dart' as globals;
import 'BarberHubController.dart';
import '../Model/Packages.dart';
import 'package:line_icons/line_icons.dart';
import '../View/ModalSheets.dart';
import 'package:intl/intl.dart';
import '../calls.dart';
import '../View/SetAvailabilityModal.dart';
import '../states.dart' as states;
import '../View/StateBottomSheetPicker.dart';

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
  int stateValue;
  String state = '';
  String stateAbr = '';
  List<Packages> packages = [];
  List<Availability> availability = [];

  @override
  void initState() {
    super.initState();

    getBarberInfo();

    setState(() {
      stateValue = widget.stateValue;
      stateAbr = widget.stateAbr;
      state = widget.state;
      _addressTextController.text = widget.address;
      _cityTextController.text = widget.city;
      _zipcodeTextController.text = widget.zipcode;
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
                        var res = await showAddPackageModalSheet(context);
                        if(res != null) {
                          setState(() {
                            packages = res;
                          });
                        }else {
                          return;
                        }
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
                  barberAvailability()
                ],
              ),
            )
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: new GestureDetector(
                  onTap: () {
                    
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
                final homeHubScreen = new BarberHubScreen();
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => homeHubScreen));
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
              buildBody()
            ]
          )
        ),
      )
    );
  }
}