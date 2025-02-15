import 'package:flutter/material.dart';
import '../Model/Packages.dart';
import 'package:table_calendar/table_calendar.dart';
import '../dialogs.dart';
import 'BookingTimeRadioButton.dart';
import '../globals.dart' as globals;
import '../calls.dart';
import 'package:intl/intl.dart';
import '../Model/availability.dart';

class AddManualAppointmentModal extends StatefulWidget {
  AddManualAppointmentModal({@required this.selectedDate, this.updateAppointmentList, this.showFullCalendar, this.packages, this.appointments});
  final DateTime selectedDate;
  final ValueChanged updateAppointmentList;
  final ValueChanged showFullCalendar;
  final List<Packages> packages;
  final Map<DateTime, List<dynamic>> appointments;

  @override
  _AddManualAppointmentModal createState() => _AddManualAppointmentModal();
}

class _AddManualAppointmentModal extends State<AddManualAppointmentModal> with TickerProviderStateMixin {
  bool show = false;
  List<Packages> packages = [];
  String packageName = '';
  String _packageId = '';
  int packagePrice = 0;
  AnimationController _animationController;
  CalendarController _calendarController;
  Map<DateTime, List<RadioModel>> _times;
  DateTime selectedDate;
  List<RadioModel> _availableTimes = new List<RadioModel>();
  DateTime finalDateTime;
  Map<DateTime, List<dynamic>> appointments;

  void initState() {
    super.initState();
    appointments = widget.appointments;
    packages = widget.packages;

    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  buildClient() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Colors.grey[850]]
        )
      ),
      margin: EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Client',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ]
      )
    );
  }

  buildPackages() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Colors.grey[850]]
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
                      setState(() {
                        packagePrice = int.parse(packages[i].price);
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
                                setState(() {
                                  packagePrice = int.parse(packages[i].price);
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
                            color: Colors.grey[800]
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
    );
  }

  calculateTime(List<Availability> list, Map<DateTime, List<dynamic>> existing, DateTime day) {
    final df = new DateFormat('hh:mm a');
    //final df2 = new DateFormat('HH:mm');
    var weekday = DateFormat.EEEE().format(day).toString();
    List<RadioModel> timesList = new List<RadioModel>();

    for(var item in list) {
      if(item.day == weekday) {
        if((item.start != null && item.end != null) && (item.start != '00:00:00' && item.end != '00:00:00')){
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
                  appointmentTimes[time] = appointment['duration'];
                }

                if(!appointmentTimes.containsKey(DateFormat('Hms').format(newTime).toString())) {
                  timesList.add(new RadioModel(false, df.format(DateTime.parse(newTime.toString()))));
                }

                for (int i = 0; i <= end.difference(start.add(Duration(minutes: 45))).inMinutes; i+=15) {
                  newTime = newTime.add(Duration(minutes: 15));
                  if(newTime.isAfter(DateTime.now())){
                    if(appointmentTimes.containsKey(DateFormat('Hms').format(newTime).toString())) {
                      appointmentTimes.forEach((k,v){
                        if(k == DateFormat('Hms').format(newTime).toString()) {
                          newTime = newTime.add(Duration(minutes: int.parse(v)));
                          return;
                        }
                      });
                    }else {
                      var convertTime = df.format(DateTime.parse(newTime.toString()));
                      timesList.add(new RadioModel(false, convertTime));
                    }
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

  void _onDaySelected(DateTime day, List times) async {
    var newDay = DateFormat('yyyy-MM-dd').parse(day.toString());
    var currentDay = DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());
    setState(() {
      finalDateTime = null;
      selectedDate = day;
    });
    if(newDay.isAfter(currentDay) || newDay.isAtSameMomentAs(currentDay)){
      var res = await getBarberAvailability(context, globals.token);
      //var res2 = await getBarberAppointments(context, globals.token);
      var newTimes = await calculateTime(res, appointments, day);

      setState(() {
        _availableTimes = newTimes;
      });
    }else {
      setState(() {
        _availableTimes = [];
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

  buildCalendar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment(0.0, -2.0),
          colors: [Colors.black, Colors.grey[850]]
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
              weekdayStyle: const TextStyle(color: const Color(0xFFf2f2f2)),
              weekendStyle: const TextStyle(color: const Color(0xFFf2f2f2))
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white)
            ),
            calendarStyle: CalendarStyle(
              weekendStyle: const TextStyle(color: Colors.white),
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
                    margin: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue
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
                      color: Colors.grey[800]
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: MediaQuery.of(context).size.height * .9,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                blurRadius: 2, color: Colors.grey[400], spreadRadius: 0)
          ]),
        child: new Stack(
          children: [
            Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: <Widget>[
                          buildClient(),
                          buildPackages(),
                          buildCalendar()
                        ]
                      ),
                    )
                  ),
                  Column(
                    children: <Widget> [
                      (!show) ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FlatButton(
                                color: Colors.blue,
                                onPressed: () async {
                                  if(_packageId != '' && finalDateTime != null) {
                                    //Navigator.pop(context);
                                    //widget.updateAppointmentList();
                                    //widget.showFullCalendar(widget.selectedDate);
                                  }else {
                                    showErrorDialog(context, 'Missing Information', 'Enter or select all fields');
                                  }
                                },
                                child: Text('Book Appointment')
                              )
                            )
                          )
                        ]
                      ) : Container(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FlatButton(
                                color: Colors.blue,
                                onPressed: () async {
                                  Navigator.pop(context);
                                  widget.showFullCalendar(widget.selectedDate);
                                },
                                child: Text('Cancel')
                              )
                            )
                          )
                        ]
                      )
                    ]
                  )
                ]
              )
            ),
          ]
        ),
      )
    );
  }
}