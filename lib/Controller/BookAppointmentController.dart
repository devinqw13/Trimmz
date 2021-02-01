import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/Model/User.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trimmz/Model/Availability.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:expandable/expandable.dart';
import 'package:trimmz/PaymentMethodCardWidget.dart';

class BookAppointmentController extends StatefulWidget {
  final User user;
  BookAppointmentController({Key key, this.user}) : super (key: key);

  @override
  BookAppointmentControllerState createState() => new BookAppointmentControllerState();
}

class BookAppointmentControllerState extends State<BookAppointmentController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  User user;
  CalendarController calendarController = new CalendarController();
  int overallDuration = 0;
  List overallServices = [];
  double overallSubTotal = 0;
  double processingFee = globals.processingFee;
  double overallTotal = globals.processingFee;
  DateTime appointmentDateTime;
  Map<DateTime, List<RadioModel>> times;
  List<RadioModel> _availableTimes = new List<RadioModel>();
  AnimationController animation;
  List<ServiceOption> services = [];
  ExpandableController expandableController = new ExpandableController();
  TextEditingController tipTFController = new TextEditingController();
  bool cardPaymentSelected = true;
  List<OptionType> tipOptions = [];

  @override
  void initState() {
    user = widget.user;

    tipOptions.add(OptionType(key: "10%", value: 0.1, selected: false));
    tipOptions.add(OptionType(key: "20%", value: 0.2, selected: false));
    tipOptions.add(OptionType(key: "Custom", value: "", selected: false));

    if(!user.cardPaymentOnly) {
      expandableController.expanded = true;
    }

    for(var item in user.services) {
      services.add(new ServiceOption(item));
    }
    
    animation = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    animation.forward();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
    
    _onDaySelected(DateTime.now(), null, null);
    super.initState();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
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

  _buildUserIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BOOKING WITH",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildUserProfilePicture(context, user.profilePicture, user.username),
              Expanded(
                flex: 9,
                child: Container(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${user.name} ",
                              style: TextStyle(
                                color: globals.darkModeEnabled ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              )
                            ),
                            TextSpan(
                              text: "@${user.username}",
                              style: TextStyle(
                                color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                                fontWeight: FontWeight.normal,
                                fontSize: 13.0
                              )
                            )
                          ]
                        ),
                      ),
                      user.shopName != null && user.shopName != "" ?
                      Text(
                        user.shopName,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.0
                        )
                      ) : Container(),
                      user.shopAddress != null ?
                      Text(
                        "${user.shopAddress}, ${user.city}, ${user.state} ${user.zipcode}",
                        style: TextStyle(
                          color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                          fontWeight: FontWeight.normal,
                          fontSize: 13.0
                        )
                      ) : Text(
                        "${user.city}, ${user.state} ${user.zipcode}",
                        style: TextStyle(
                          color: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                          fontWeight: FontWeight.normal,
                          fontSize: 13.0
                        )
                      )
                    ]
                  ),
                )
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "${user.numOfReviews} Ratings",
                    ),
                    Text(
                      user.rating != "0" ? double.parse(user.rating).toStringAsFixed(1) : "N/A",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    RatingBarIndicator(
                      rating: double.parse(user.rating),
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Color(0xFFD2AC47),
                      ),
                      itemCount: 5,
                      itemSize: 13.0,
                      direction: Axis.horizontal,
                      unratedColor: globals.darkModeEnabled ? Colors.grey[400] : Color.fromARGB(255, 80, 80, 80),
                    ),
                  ],
                ),
              ),
            ]
          ),
        )
      ],
    );
  }

  void selectService(ServiceOption service) {
    setState(() {
      service.selected = !service.selected;
      service.selected ?
        overallDuration += service.duration:
        overallDuration -= service.duration;
      service.selected ?
        overallTotal += double.parse(service.price.toString()):
        overallTotal -= double.parse(service.price.toString());
      service.selected ?
        overallSubTotal += double.parse(service.price.toString()):
        overallSubTotal -= double.parse(service.price.toString());
    });
    var tip = tipOptions.where((element) => element.selected == true);
    if(tip.length > 0) {
      overallSubTotal = tip.first.value * overallSubTotal;
    }
    _onDaySelected(calendarController.selectedDay, null, null);
  }

  _buildSelectServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT SERVICES",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0.0),
            itemCount: services.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return new GestureDetector(
                onTap: () => selectService(services[index]),
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new Row(
                        children: [
                          new CircularCheckBox(
                            activeColor: Colors.blue,
                            value: services[index].selected,
                            onChanged: (bool value) => selectService(services[index])
                          ),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                services[index].serviceName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              Text(
                                "${services[index].duration} Minutes",
                                style: TextStyle(
                                  color: Colors.grey
                                )
                              )
                            ]
                          )
                        ]
                      ),
                      Text(
                        "\$${services[index].price}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600
                        )
                      )
                    ]
                  )
                )
              );
            },
          )
        )
      ],
    );
  }

  void _onDaySelected(DateTime day, List _, List __) {
    DateTime daySelected = DateTime.parse(DateFormat('yyyy-MM-dd').format(day));
    DateTime currentDay = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    if(daySelected.isAfter(currentDay) || daySelected.isAtSameMomentAs(currentDay)) {
      var result = calculateAvailability(user.availability, user.appointments.calendarFormat, day);
      setState(() {
        _availableTimes = result;
      });
    }
  }

  calculateAvailability(List<Availability> list, Map<DateTime, List<dynamic>> existingAppointments, DateTime day) {
    final df = new DateFormat('hh:mm a');
    var weekday = DateFormat('yyyy-MM-dd').format(day);
    List<RadioModel> timesList = [];

    for(var item in list) {
      if(DateFormat('yyyy-MM-dd').format(item.date) == weekday) {
        if(!item.closed){
          var start = DateTime.parse(DateFormat('Hms', 'en_US').parse(item.start).toString());
          var end = DateTime.parse(DateFormat('Hms', 'en_US').parse(item.end).toString());
          var startDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(day.toString()));
          var startTime = DateFormat('Hms').format(DateTime.parse(start.toString()));
          var newStart = DateTime.parse(startDate + ' ' + startTime);
          var newTime = newStart;

          if(existingAppointments.containsKey(DateTime.parse(DateFormat('yyyy-MM-dd').format(day)))) {
            existingAppointments.forEach((key, value){
              if(DateFormat('yyyy-MM-dd').format(key) == DateFormat('yyyy-MM-dd').format(day)) {
                Map<String, String> appointmentTimes = {};
                for(var appointment in value) {
                  var amPMTimeFormat = DateFormat('hh:mm a').format(DateTime.parse(appointment['date']));
                  var time = DateFormat('Hms').format(DateTime.parse(DateFormat('hh:mm a', 'en_US').parse(amPMTimeFormat).toString()));
                  appointmentTimes[time] = appointment['duration'].toString();
                }

                // if(!appointmentTimes.containsKey(DateFormat('Hms').format(newTime).toString())) {
                //   if(newTime.isAfter(DateTime.now())){
                //     timesList.add(new RadioModel(false, df.format(DateTime.parse(newTime.toString()))));
                //   }
                // }

                int iterate = end.difference(start).inMinutes - 15;
                DateTime startingTime = newTime;

                for (int i = 0; i <= end.difference(start).inMinutes; i+=15) {
                  if(newTime.isAfter(DateTime.now()) && newTime.isBefore(startingTime.add(Duration(minutes: iterate)))){
                    if(appointmentTimes.containsKey(DateFormat('Hms').format(newTime).toString())) {
                      appointmentTimes.forEach((k,v){
                        if(k == DateFormat('Hms').format(newTime).toString()) {
                          timesList.removeWhere((element) => element.buttonText == df.format(DateTime.parse(newTime.toString())));
                          newTime = newTime.add(Duration(minutes: int.parse(v)));
                        }
                      });
                    }else {
                      bool shouldAdd = true;
                      DateTime mmm;
                      int val;

                      appointmentTimes.forEach((k, v){
                        var eDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(newTime.toString()));
                        DateTime eTime = DateTime.parse(eDate + ' ' + k);

                        if(newTime.add(Duration(minutes: overallDuration)).isAfter(eTime) && newTime.add(Duration(minutes: overallDuration)).isBefore(eTime.add(Duration(minutes: int.parse(v))))) {
                          shouldAdd = false;
                          mmm = eTime;
                          val = int.parse(v);
                        }
                      });

                      if(shouldAdd) {
                        var convertTime = df.format(DateTime.parse(newTime.toString()));
                        timesList.add(new RadioModel(false, convertTime));
                        newTime = newTime.add(Duration(minutes: 15));
                      }else {
                        newTime = mmm.add(Duration(minutes: val));
                      }
                    }
                  }else {
                    newTime = newTime.add(Duration(minutes: 15));
                  }
                }
              }
            });
          }else {
            if(newTime.isAfter(DateTime.now())){
              timesList.add(new RadioModel(false, df.format(DateTime.parse(newTime.toString()))));
            }

            for (int i = 0; i <= end.difference(start.add(Duration(minutes: 45))).inMinutes; i+=15) {
              newTime = newTime.add(Duration(minutes: 15));
              if(newTime.isAfter(DateTime.now())){
                var convertTime = df.format(DateTime.parse(newTime.toString()));
                timesList.add(new RadioModel(false, convertTime));
              }
            }
          }
          return timesList;    
        }else {
          return timesList = [];
        }
      }
    }
  }

  _buildCalendar() {
    return TableCalendar(
      locale: 'en_US',
      events: times,
      onDaySelected: _onDaySelected,
      availableGestures: AvailableGestures.horizontalSwipe,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black),
        weekendStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black)
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        centerHeaderTitle: true
      ),
      calendarStyle: CalendarStyle(
        weekendStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
        outsideWeekendStyle: TextStyle(color: Color(0xFF9E9E9E))
      ),
      headerVisible: true,
      calendarController: calendarController,
      initialCalendarFormat: CalendarFormat.week,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[500]
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0),
                ),
              )
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(animation),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[350]
              ),
              child: Center(
                child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
              )
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          return children;
        }
      ),
    );
  }

  _buildTimeList() {
    if(_availableTimes != null && _availableTimes.length > 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        child: new ListView.builder(
          itemCount: _availableTimes.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            return Container(
              child: new GestureDetector(
                onTap: () {
                  // var date = DateFormat('yyyy-MM-dd').format(DateTime.parse(calendarController.selectedDay.toString()));
                  // var time = DateFormat('HH:mm:ss').format(DateFormat('hh:mm a').parse(_availableTimes[i].buttonText));
                  // setState(() {
                  //   _availableTimes.forEach((element) => element.isSelected = false);
                  //   _availableTimes[i].isSelected = true;
                  //   appointmentDateTime = DateTime.parse(date + ' ' + time);
                  // });
                },
                child: new RadioItem(_availableTimes[i]),
              )
            );
          }
        )
      );
    }else {
      return Container(
        padding: EdgeInsets.all(10),
        child: Center(child: Text('No Available Times'))
      );
    }
  }

  _buildSelectDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SELECT DATE & TIME",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: Column(
            children: [
              _buildCalendar(),
              Divider(),
              _buildTimeList()
            ]
          )
        )
      ],
    );
  }

  _buildPaymentOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              cardPaymentSelected = true;
              expandableController.expanded = true;
            });
          },
          child: Row(
            children: [
              CircularCheckBox(
                activeColor: Colors.blue,
                value: cardPaymentSelected,
                onChanged: (bool value) {
                  setState(() {
                    cardPaymentSelected = true;
                    expandableController.expanded = true;
                  });
                }
              ),
              Text(
                "Mobile Pay",
                style: TextStyle(
                  fontWeight: FontWeight.w600
                )
              )
            ]
          )
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              cardPaymentSelected = false;
              expandableController.expanded = false;
            });
          },
          child: Row(
            children: [
              CircularCheckBox(
                activeColor: Colors.blue,
                value: !cardPaymentSelected,
                onChanged: (bool value) {
                  setState(() {
                    cardPaymentSelected = false;
                    expandableController.expanded = false;
                  });
                }
              ),
              Text(
                "In Shop",
                style: TextStyle(
                  fontWeight: FontWeight.w600
                )
              )
            ]
          )
        )
      ],
    );
  }

  _buildPaymentMethodExpansion() {
    List<Widget> _children = [];
    for(var item in tipOptions) {
      _children.add(
        GestureDetector(
          onTap: () {
            if(item.key != "Custom") {
              setState(() {
                tipTFController.text = (overallSubTotal * item.value).toStringAsFixed(2);
              });
            }
            setState(() {
              tipOptions.forEach((element) => element.selected = false);
              item.selected = true;
            });
          },
          child: new RadioItem(new RadioModel(item.selected, item.key))
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentMethodCard(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: tipTFController,
                decoration: InputDecoration(
                  labelText: "Tip",
                  labelStyle: TextStyle(
                    color: Colors.white70
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              children: _children
            )
          ]
        )
      ],
    );
  }

  _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PAYMENT METHOD",
          style: TextStyle(
            fontWeight: FontWeight.w600
          ),
        ),
        Padding(padding: EdgeInsets.all(3.0)),
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xff0a0a0a).withAlpha(225),
            borderRadius: BorderRadius.circular(15.0)
          ),
          child: user.cardPaymentOnly ?
            _buildPaymentMethodExpansion():
            ExpandablePanel(
              controller: expandableController,
              tapHeaderToExpand: false,
              tapBodyToCollapse: false,
              hasIcon: false,
              header: _buildPaymentOptions(),
              expanded: _buildPaymentMethodExpansion(),
            )
        )
      ],
    );
  }

  _buildScreen() {
    return Container(
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                child: Column(
                  children: [
                    _buildUserIntro(),
                    Padding(padding: EdgeInsets.all(8.0)),
                    _buildSelectServices(),
                    Padding(padding: EdgeInsets.all(8.0)),
                    _buildSelectDateTime(),
                    Padding(padding: EdgeInsets.all(8.0)),
                    _buildPaymentMethod(),
                    Padding(padding: EdgeInsets.all(8.0))
                  ],
                ),
              )
            )
          ),
          Container(
            padding: EdgeInsets.only(bottom: 20, top: 20, left: 25, right: 25),
            decoration: BoxDecoration(
              color: Color(0xff0a0a0a),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.w600
                  ),
                ),
                Padding(padding: EdgeInsets.all(5.0)),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Sub Total', 
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.0
                          ),
                        )
                      ),
                      new Container(
                        width: 1.0,
                        color: Colors.grey,
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                      ),
                      Expanded(
                        flex: 5,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "\$${overallSubTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        )
                      ),
                    ]
                  )
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Processing Fees',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13.0
                          ),
                        )
                      ),
                      new Container(
                        width: 1.0,
                        color: Colors.grey,
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                      ),
                      Expanded(
                        flex: 5,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "\$${processingFee.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        )
                      ),
                    ]
                  )
                ),
                Divider(),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Total Fees',
                          style: TextStyle(
                            // fontSize: 13.0
                          ),
                        )
                      ),
                      new Container(
                        width: 1.0,
                        color: Colors.grey,
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 0.0),
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                      ),
                      Expanded(
                        flex: 5,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "\$${overallTotal.toStringAsFixed(2)}",
                            style: TextStyle(
                              // fontSize: 13.0,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        )
                      ),
                    ]
                  )
                ),
                Padding(padding: EdgeInsets.all(10.0)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: globals.darkModeEnabled ? Color(0xff0a0a0a).withAlpha(225) : Color.fromARGB(110, 0, 0, 0),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          border: Border.all(
                            color: CustomColors1.mystic.withAlpha(100)
                          )
                        ),
                        child: RippleButton(
                          splashColor: CustomColors1.mystic.withAlpha(100),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                            child: Center(
                              child: Text(
                                "Book Appointment",
                                style: TextStyle(
                                  color: Colors.white
                                )
                              ),
                            )
                          )
                        )
                      ),
                    )
                  ]
                )
              ],
            ),
          ),
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        primaryColor: globals.darkModeEnabled ? Colors.black : Colors.white,
        brightness: globals.userBrightness,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          brightness: globals.userBrightness,
          backgroundColor: globals.darkModeEnabled ? richBlack : Colors.white,
          centerTitle: true,
          title: new Text(
            "Booking Appointment",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: new Container(
              color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
              child: new Stack(
                children: [
                  _buildScreen(),
                  _progressHUD,
                ]
              )
            )
          )
        )
      )
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);
  @override
  Widget build(BuildContext context) {

    return new Container(
      padding: EdgeInsets.all(5.0),
      margin: new EdgeInsets.all(5.0),
      child: new Center(
        child: new Text(_item.buttonText,
          style: new TextStyle(
            fontSize: 16.0
          )
        ),
      ),
      decoration: new BoxDecoration(
        color: _item.isSelected ? Colors.blue : globals.darkModeEnabled ? Color(0xff0a0a0a) : Colors.grey[400],
        border: new Border.all(
          width: 1.0,
          color: _item.isSelected ? Colors.blue : CustomColors1.mystic.withAlpha(100)),
        borderRadius: const BorderRadius.all(const Radius.circular(5.0)),
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  RadioModel(this.isSelected, this.buttonText);
}

class ServiceOption {
  bool selected = false;
  int serviceId;
  String serviceName;
  int duration;
  int price;

  ServiceOption(Service input) {
    this.serviceId = input.id;
    this.serviceName = input.name;
    this.duration = input.duration;
    this.price = input.price;
  }
}

class OptionType{
  String key;
  var value;
  bool selected;

  OptionType({
    this.key,
    this.value,
    this.selected
  });
}