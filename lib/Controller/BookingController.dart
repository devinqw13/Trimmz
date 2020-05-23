import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/Model/ClientPaymentMethod.dart';
import 'package:trimmz/dialogs.dart';
import '../Model/ClientBarbers.dart';
import '../View/Widgets.dart';
import '../globals.dart' as globals;
import 'package:table_calendar/table_calendar.dart';
import 'HomeHubController.dart';
import '../Calls/GeneralCalls.dart';
import 'SelectBarberController.dart';
import 'BarberHubController.dart';
import '../Model/Packages.dart';
import 'package:intl/intl.dart';
import '../Model/availability.dart';
import '../View/BookingTimeRadioButton.dart';
import 'package:stripe_payment/stripe_payment.dart';
import '../Calls/StripeConfig.dart';
import '../Calls/FinancialCalls.dart';
import 'package:progress_hud/progress_hud.dart';
import '../functions.dart';
import  'package:keyboard_actions/keyboard_actions.dart';
import '../Model/AppointmentRequests.dart';
import '../Model/BarberPolicies.dart';

class BookingController extends StatefulWidget {
  final ClientBarbers barberInfo;

  final List selectedEvents;
  final List<Packages> packages;
  final Map<DateTime, List> events;
  final List<Availability> availability;
  final List<AppointmentRequest> appointmentReq;
  final BarberPolicies policies;
  BookingController({Key key, this.barberInfo, this.appointmentReq, this.availability, this.events, this.packages, this.policies, this.selectedEvents}) : super (key: key);

  @override
  BookingControllerState createState() => new BookingControllerState();
}

class BookingControllerState extends State<BookingController> with TickerProviderStateMixin {
  ScrollController _scrollController = new ScrollController();
  ClientBarbers barberInfo = new ClientBarbers();
  CalendarController _calendarController;
  List<Packages> packages = [];
  String _packageId = '';
  String packageName = '';
  List<RadioModel> _availableTimes = new List<RadioModel>();
  Map<DateTime, List<RadioModel>> _times;
  AnimationController _animationController;
  String currentDate = '';
  String currentTime = '';
  TextEditingController _tipController = new TextEditingController();
  int finalTip = 0;
  int finalPackagePrice = 0;
  DateTime selectedDate;
  DateTime finalDateTime;
  ClientPaymentMethod paymentCard;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  final FocusNode _numberFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    barberInfo = widget.barberInfo;
    _calendarController = CalendarController();

    getBarberPackages(int.parse(barberInfo.id));
    stripeInit();

    getClientPaymentCard();

    getInitDate();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    _numberFocus.addListener((){
      if(_numberFocus.hasFocus) {
        scrollToBottom();
      }
    });

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: globals.darkModeEnabled ? Color.fromARGB(255, 21, 21, 21) : Color.fromARGB(255, 225, 225, 225),
      nextFocus: true,
      actions: [
        KeyboardAction(
          onTapAction: () {
            if(_tipController.text != ''){
              setState(() {
                finalTip = int.parse(_tipController.text);
              });
            }
          },
          focusNode: _numberFocus,
          closeWidget: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Done', style: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black)),
          ),
        ),
      ],
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

  getClientPaymentCard() async {
    if(globals.spCustomerId != null && globals.spPaymentId != null) {
      if(globals.spCustomerId != '') {
        var res = await spGetClientPaymentMethod(context, globals.spCustomerId, 2);
        if(res != null) {
          if(res != null) {
            for(var item in res) {
              if(item.id == globals.spPaymentId) {
                setState(() {
                  paymentCard = item;
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
            var res4 = await spGetClientPaymentMethod(context, globals.spCustomerId, 2);
            if(res4 != null) {
              for(var item in res4) {
                if(item.id == paymentMethod.id) {
                  var res = await updateSettings(context, globals.token, 1, '', '', '', item.id);
                  if(res.length > 0) {
                    setGlobals(res);
                    setState(() {
                      paymentCard = item;
                    });
                  }
                }
              }
            }
          }
        }else {
          //TODO: LOOK INTO ERROR MESSAGE
          var res1 = await spCreateCustomer(context, paymentMethod.id);
          if(res1.length > 0) {
            String spCustomerId = res1['id'];
            var res2 = await spCreatePaymentIntent(context, paymentMethod.id, spCustomerId, '100');
            if(res2.length > 0) {
              var res3 = await updateSettings(context, globals.token, 1, '', '', spCustomerId);
              if(res3.length > 0) {
                var res4 = await spGetClientPaymentMethod(context, spCustomerId, 2);
                if(res4 != null) {
                  for(var item in res4) {
                    if(item.id == paymentMethod.id) {
                      var res = await updateSettings(context, globals.token, 1, '', '', '', item.id);
                      if(res.length > 0) {
                        setGlobals(res);
                        setState(() {
                          paymentCard = item;
                        });
                      }
                    }
                  }
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
      var res1 = await spDetachCustomerFromPM(context, paymentCard.id);
      if(res1.length > 0) {
        var res2 = await spAttachCustomerToPM(context, paymentMethod.id, globals.spCustomerId);
        if(res2.length > 0) {
          var res3 = await spCreatePaymentIntent(context, paymentMethod.id, globals.spCustomerId, "100");
          if(res3.length > 0){
            var res4 = await spGetClientPaymentMethod(context, globals.spCustomerId, 2);
            if(res4 != null) {
              for(var item in res4) {
                if(item.id == paymentMethod.id) {
                  var res = await updateSettings(context, globals.token, 1, '', '', '', item.id);
                  if(res.length > 0) {
                    setGlobals(res);
                    setState(() {
                      paymentCard = item;
                    });
                  }
                }
              }
            }
          }
        }
      }
      progressHUD();
    }).catchError(setError);
  }

  getBarberPackages(int barberId) async {
    var res = await getBarberPkgs(context, barberId);
    setState(() {
      packages = res;
    });
  }

  calculateTime(List<Availability> list, Map<DateTime, List<dynamic>> existing, DateTime day) {
    final df = new DateFormat('hh:mm a');
    var weekday = DateFormat.EEEE().format(day).toString();
    List<RadioModel> timesList = new List<RadioModel>();

    for(var item in list) {
      if(item.day == weekday) {
        // TODO: IF START / END IS MARKED 12AM (00:00:00) IT DOESNT GO PAST THIS
        if((item.start != null && item.end != null) && ((item.start != '00:00:00' && item.end != '00:00:00') && (item.start != '0:00:00' && item.end != '0:00:00'))){
          print('here2');
          var start = DateTime.parse(DateFormat('Hms', 'en_US').parse(item.start).toString());
          var end = DateTime.parse(DateFormat('Hms', 'en_US').parse(item.end).toString());
          var startDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(day.toString()));
          var startTime = DateFormat('Hms').format(DateTime.parse(start.toString()));
          var newStart = DateTime.parse(startDate + ' ' + startTime);
          var newTime = newStart;

          if(existing.containsKey(DateTime.parse(DateFormat('yyyy-MM-dd').format(day)))) {
            existing.forEach((key, value){
              if(DateFormat('yyyy-MM-dd').format(key) == DateFormat('yyyy-MM-dd').format(day)) {
                Map<String, String> appointmentTimes = {};
                for(var appointment in value) {
                  var time = DateFormat('Hms').format(DateTime.parse(DateFormat('hh:mm a', 'en_US').parse(appointment['time']).toString()));
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
                  print(newTime);
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

                        if(newTime.add(Duration(minutes: 45)).isAfter(eTime) && newTime.add(Duration(minutes: 45)).isBefore(eTime.add(Duration(minutes: int.parse(v))))) {
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

  getInitDate() async {
    final _selectedDay = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(DateTime.now().toString())));
    var res = await getBarberAvailability(context, int.parse(barberInfo.id));
    var res2 = await getBarberBookAppointments(context, int.parse(barberInfo.id));
    var newTimes = await calculateTime(res, res2, _selectedDay);
    setState(() {
      _availableTimes = newTimes;
      selectedDate = _selectedDay;
    });
  }

  void _onDaySelected(DateTime day, List times) async {
    var newDay = DateFormat('yyyy-MM-dd').parse(day.toString());
    var currentDay = DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());
    setState(() {
      selectedDate = day;
    });
    if(newDay.isAfter(currentDay) || newDay.isAtSameMomentAs(currentDay)){
      var res = await getBarberAvailability(context, int.parse(barberInfo.id));
      var res2 = await getBarberBookAppointments(context, int.parse(barberInfo.id));
      var newTimes = await calculateTime(res, res2, day);
      setState(() {
        _availableTimes = newTimes;
      });
    }else {
      setState(() {
        _availableTimes = [];
      });
    }
  }

  handleSelectTime(var item) {
    if(item['isSelected']){
      setState(() {
        item['isSelected'] = false;
      });
    }else {
      setState(() {
        item['isSelected'] = true;
      });
    }
  }

  buildTimeList() {
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
                  var date = DateFormat('yyyy-MM-dd').format(DateTime.parse(selectedDate.toString()));
                  var time = DateFormat('HH:mm:ss').format(DateFormat('hh:mm a').parse(_availableTimes[i].buttonText));
                  setState(() {
                    _availableTimes.forEach((element) => element.isSelected = false);
                    _availableTimes[i].isSelected = true;
                    finalDateTime = DateTime.parse(date + ' ' + time);
                  });
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
        child: Center(child: Text('Unavailable'))
      );
    }
  }

  scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400), curve: Curves.easeOut);
    });
  }

  bookingAppointment(int userId, String barberId, int price, DateTime time, String packageId, int tip) async {
    if(userId == null || barberId == null || price == null || time == null || packageId == null || tip == null || paymentCard == null) {
      showErrorDialog(context, 'Missing Information', 'Enter/Select all required information');
      return;
    }
    progressHUD();
    var res = await bookAppointment(context, userId, barberId, price, time, packageId, tip);
    if(res) {
      List tokens = await getNotificationTokens(context, int.parse(barberId));
      for(var token in tokens){
        Map<String, dynamic> dataMap =  {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'action': 'BOOK_APPOINTMENT',
          'title': 'Appointment Requested',
          'body': '${globals.username} has requested an appointment',
          'sender': '${globals.token}',
          'recipient': '$barberId',
        };
        await sendPushNotification(context, 'Appointment Requested', '${globals.username} has requested an appointment', token, dataMap);
      }
      progressHUD();

      Map message = {'title': 'Appointment Requested', 'body': 'Your appointment request with ${barberInfo.name} has been sent.'};

      if(globals.userType == 1 || globals.userType == 3){
        final homeScreen = new HomeHubScreen(message: message); 
        Navigator.push(context, new MaterialPageRoute(builder: (context) => homeScreen));
      }else if(globals.userType == 2) {
        final homeScreen = new BarberHubScreen(message: message, selectedEvents: widget.selectedEvents, packages: widget.packages, events: widget.events, availability: widget.availability, appointmentReq: widget.appointmentReq, policies: widget.policies); 
        Navigator.push(context, new MaterialPageRoute(builder: (context) => homeScreen));
      }
    }else {
      showErrorDialog(context, "Booking Error", "Was not able to book appointment");
    }
  }

  buildBody(ClientBarbers barber) {
    return new Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(0.0, -8.0),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[850]] : [Colors.grey[500], Colors.grey[50]]
                      )
                    ),
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(5.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            buildProfilePictures(context, barber.profilePicture, barber.name, 25),
                            Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Text(barber.name, style: TextStyle(fontSize: 18))
                            )
                          ],
                        ),
                        FlatButton(
                          onPressed: () async {
                            var barberList = await getUserBarbers(context, globals.token);
                            final selectBarberScreen = new SelectBarberScreen(clientBarbers: barberList); 
                            Navigator.push(context, new MaterialPageRoute(builder: (context) => selectBarberScreen));
                          },
                          textColor: Colors.blue,
                          child: Text('Change'),
                        )
                      ],
                    )
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(0.0, -8.0),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[850]] : [Colors.grey[500], Colors.grey[50]]
                      )
                    ),
                    margin: EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Text(
                          'Services',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        packages.length == 0 ?
                        Container(
                          margin: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Barber doesn\'t have any packages yet. \n Contact barber for info.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17.0,
                              )
                            )
                          )
                        ): Container(
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: packages.length,
                            padding: const EdgeInsets.all(0),
                            itemBuilder: (context, i) {
                              return new Container(
                                color: Colors.transparent,
                                child: GestureDetector(
                                  onTap: () {
                                    var calculatedTip = (int.parse(packages[i].price) * .2).round();
                                    setState(() {
                                      finalPackagePrice = int.parse(packages[i].price);
                                      finalTip = calculatedTip;
                                      _tipController.text = calculatedTip.toString();
                                      _packageId = packages[i].id;
                                      packageName = packages[i].name;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Radio(
                                            activeColor: Colors.blue,
                                            groupValue: _packageId,
                                            value: packages[i].id,
                                            onChanged: (value) {
                                              var calculatedTip = (int.parse(packages[i].price) * .2).round();
                                              setState(() {
                                                finalPackagePrice = int.parse(packages[i].price);
                                                finalTip = calculatedTip;
                                                _tipController.text = calculatedTip.toString();
                                                _packageId = value;
                                                packageName = packages[i].name;
                                              });
                                            },
                                          ),
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
                                        ]
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Center(child: Text('\$' + packages[i].price, textAlign: TextAlign.center,)),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[350]
                                        ),
                                      )
                                    ]
                                  ),
                                )
                              );
                            }
                          )
                        )
                      ]
                    )
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(0.0, -3.0),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[850]] : [Colors.grey[500], Colors.grey[50]]
                      )
                    ),
                    margin: EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Text(
                          'Date & Time',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TableCalendar(
                          locale: 'en_US',
                          events: _times,
                          onDaySelected: _onDaySelected,
                          availableGestures: AvailableGestures.horizontalSwipe,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black),
                            weekendStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black)
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.blue),
                            rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.blue)
                          ),
                          calendarStyle: CalendarStyle(
                            weekendStyle: TextStyle(color: globals.darkModeEnabled ? Colors.white : Colors.black),
                            outsideWeekendStyle: TextStyle(color: Color(0xFF9E9E9E))
                          ),
                          headerVisible: true,
                          calendarController: _calendarController,
                          initialCalendarFormat: CalendarFormat.week,
                          builders: CalendarBuilders(
                            selectedDayBuilder: (context, date, _) {
                              return FadeTransition(
                                opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
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
                                opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
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
                        ),
                        buildTimeList()
                      ]
                    )
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: Alignment(0.0, -4.0),
                        colors: globals.darkModeEnabled ? [Colors.black, Colors.grey[850]] : [Colors.grey[500], Colors.grey[50]]
                      )
                    ),
                    margin: EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              paymentCard != null ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      paymentCard.icon,
                                      Padding(padding: EdgeInsets.all(10)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Padding(padding: EdgeInsets.all(3)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Padding(padding: EdgeInsets.all(3)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Container(margin:EdgeInsets.all(1),width:5,height:5,decoration:BoxDecoration(shape:BoxShape.circle,color: globals.darkModeEnabled ? Colors.white : Colors.black)),
                                      Padding(padding: EdgeInsets.all(3)),
                                      Text(paymentCard.lastFour)
                                    ]
                                  ),
                                  FlatButton(
                                    textColor: Colors.blue,
                                    onPressed: () {
                                      changePaymentMethod();
                                    },
                                    child: Text('Change')
                                  )
                                ],
                              ) : 
                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    addPaymentMethod();
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(LineIcons.plus, color: Colors.blue, size: 18),
                                      Text(
                                        'Add Card',
                                        style: TextStyle(
                                          color: Colors.blue
                                        )
                                      )
                                    ]
                                  )
                                )
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    _tipController.text.length > 0 ? Text('Tip', style: TextStyle(color: Colors.grey)) : Container(),
                                    TextField(
                                      controller: _tipController,
                                      focusNode: _numberFocus,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Tip',
                                        border: InputBorder.none
                                      ),
                                    )
                                  ],
                                )
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Your payment method will be pre-authorized, but it will not be charged until after your appointment has been completed.',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey[400]
                                    )
                                  )
                                ],
                              )
                            ]
                          )
                        )
                      ]
                    )
                  ),
                ],
              ),
            )
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: globals.darkModeEnabled ? Colors.black : Colors.white,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Review', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20, color: Colors.blue)),
                                Text(barberInfo.name),
                                packageName != '' ? Text(packageName) : Container(),
                                finalDateTime != null ?
                                  Text(
                                    DateFormat('Md').format(DateTime.parse(finalDateTime.toString())) + ' at ' + DateFormat('hh:mm a').format(DateTime.parse(finalDateTime.toString()))
                                  ) : Container()
                              ],
                            )
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget> [
                                Text(
                                  '\$' + (finalTip + finalPackagePrice + globals.cusProcessFee).toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 25.0
                                  )
                                ),
                                Text(
                                  'Includes Tip + Processing Fee: \$${globals.cusProcessFee.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12
                                  )
                                )
                              ]
                            )
                          )
                        ]
                      ),
                      GestureDetector(
                        onTap: () {
                          bookingAppointment(globals.token, barberInfo.id, finalPackagePrice, finalDateTime, _packageId, finalTip);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                          constraints: const BoxConstraints(maxHeight: 35.0, minWidth: 200.0, minHeight: 35.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            gradient: new LinearGradient(
                              colors: globals.darkModeEnabled ? [Color.fromARGB(255, 0, 61, 184), Colors.lightBlueAccent] : [Color.fromARGB(255, 54, 121, 255), Colors.lightBlueAccent],
                            )
                          ),
                          child: Center(
                            child: Text(
                              'Book Appointment',
                              style: new TextStyle(
                                fontSize: 19.0,
                                fontWeight: FontWeight.w300
                              )
                            )
                          )
                        )
                      )
                    ]
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
        backgroundColor: globals.darkModeEnabled ? Colors.black : Color(0xFFFAFAFA),
        appBar: new AppBar(
          title: new Text('Booking Appointment')
        ),
        body: KeyboardActions(
          autoScroll: false,
          config: _buildConfig(context),
          child: Stack(
            children: <Widget> [
              buildBody(barberInfo),
              _progressHUD
            ]
          )
        )
      )
    );
  }
}