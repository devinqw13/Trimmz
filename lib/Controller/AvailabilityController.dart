import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trimmz/Model/Availability.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/helpers.dart';

class AvailabilityController extends StatefulWidget {
  final List<Availability> availability;
  AvailabilityController({Key key, this.availability}) : super (key: key);

  @override
  AvailabilityControllerState createState() => new AvailabilityControllerState();
}

class AvailabilityControllerState extends State<AvailabilityController> with TickerProviderStateMixin {
  CalendarController _calendarAvailabilityController = new CalendarController();
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<Availability> availability = [];
  Map<DateTime, List> _availability = {};
  AnimationController _animationAvailabilityController;
  bool isSelected = false;
  DateTime selectedDay;
  List availabilityDay;

  @override
  void initState() {
    availability = widget.availability;

    setAvailabilityToCalendar();

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    _animationAvailabilityController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationAvailabilityController.forward();

    super.initState();
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

  setAvailabilityToCalendar() {
    Map<DateTime, List<dynamic>> list = {};

    for(Availability item in availability) {
      if(!list.containsKey(item.date)) {
        list[item.date] = [Map.from({"id": item.id, "date": item.date, "start": item.start, "end": item.end, "closed": item.closed})];
      }else {
        list[item.date].add(Map.from({"id": item.id, "date": item.date, "start": item.start, "end": item.end, "closed": item.closed}));
      }
    }

    setState(() {
      _availability = list;
    });
  }

  _onAvailabilityDaySelect(DateTime day, List availDayList, _) {
    DateTime startDate = availDayList.length > 0 ?
      DateTime.parse(DateFormat('Hms', 'en_US').parse(availDayList.first['start']).toString()):
      DateTime.parse(DateFormat('Hms', 'en_US').parse("09:00:00").toString());
    DateTime endDate = availDayList.length > 0 ?
      DateTime.parse(DateFormat('Hms', 'en_US').parse(availDayList.first['end']).toString()):
      DateTime.parse(DateFormat('Hms', 'en_US').parse("17:00:00").toString());
    bool closed = availDayList.length > 0 ?
      availDayList.first['closed']:
      false;

    var date = DateFormat('yyyy-MM-dd').format(DateTime.parse(day.toString()));
    final tf = DateFormat('Hms', 'en_US');

    DateTime startDateTime = DateTime.parse("$date ${tf.format(startDate)}");
    DateTime endDateTime = DateTime.parse("$date ${tf.format(endDate)}");

    showDialog(
      context: context,
      builder: (context) => SetAvailabilityPopup(
        start: startDateTime,
        end: endDateTime,
        date: day,
        closed: closed,
        onSetAvailability: (List value) async {
          String startVal = DateFormat.Hms().format(value[0]);
          String endVal = DateFormat.Hms().format(value[1]);

          progressHUD();
          var result = await setUserAvailability(
            context,
            globals.user.token,
            day.toString(),
            startVal,
            endVal,
            value[2]
          );
          
          var availDayData = availability.where((element) => element.id == result.id);
          if(availDayData.length > 0) {
            setState(() {
              availability[availability.indexWhere((element) => element.id == result.id)] = result;
            });
          }else {
            setState(() {
              availability.add(result);
            });
          }

          setAvailabilityToCalendar();
          progressHUD();
        },
      )
    );
  }

  buildAvailabilityCalendar() {
    return TableCalendar(
      locale: 'en_US',
      events: _availability,
      onDaySelected: _onAvailabilityDaySelect,
      availableGestures: AvailableGestures.horizontalSwipe,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: globals.darkModeEnabled ? Color(0xFFf2f2f2) : Colors.black),
        weekendStyle: TextStyle(color: globals.darkModeEnabled ?  Color(0xFFf2f2f2) : Colors.black)
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
      calendarController: _calendarAvailabilityController,
      initialSelectedDay: DateTime.now(),
      initialCalendarFormat: CalendarFormat.month,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationAvailabilityController),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[400] : Colors.transparent
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                ),
              )
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationAvailabilityController),
            child: Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: globals.darkModeEnabled ? Colors.grey[800] : Colors.grey[400]
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
          var children = <Widget>[];
          var start = DateFormat('h').format(DateTime.parse(DateFormat('Hms', 'en_US').parse(events.first['start']).toString()));
          var end = DateFormat('h').format(DateTime.parse(DateFormat('Hms', 'en_US').parse(events.first['end']).toString()));

          if (events.isNotEmpty) {
            children.add(
              AnimatedContainer(
                margin: EdgeInsets.only(top: 29, left: 2),
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                  color: globals.darkModeEnabled ? Colors.blue[700] : Colors.lightBlue
                ),
                width: 46.0,
                height: 20.0,
                child: Center(
                  child: Text(
                    !events.first['closed'] ? '$start-$end' : 'Closed',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle().copyWith(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              )
            );
          }
          return children;
        },
      ),
    );
  }

  buildWeekAvailability(List<Availability> availability) {
    List<Widget> children = [];
    List<Availability> currentWeekAvailability = [];
    List<DateTime> weekList = [];
    for(int i=0 ; i<7;i++){
      weekList.add(DateTime.parse(DateFormat('yyyy-MM-dd 12:00:00').format(DateTime.now().add(new Duration(days: i)))));
    }
    for(var item in weekList) {
      var currentDate = availability.where((element) => element.date == item);
      if(currentDate.length > 0) {
        currentWeekAvailability.add(currentDate.first);
      }else {
        var avail = new Availability({}, otherDate: item);
        currentWeekAvailability.add(avail);
      }
    }
    
    currentWeekAvailability.forEach((element) {
      String weekDay;

      if(DateFormat.EEEE().format(element.date) == DateFormat.EEEE().format(DateTime.now())) {
        weekDay = "Today";
      }else if(DateFormat.EEEE().format(element.date) == DateFormat.EEEE().format(DateTime.now().add(Duration(days: 1)))) {
        weekDay = "Tomorrow";
      }else {
        weekDay = DateFormat.EEEE().format(element.date).toString();
      }

      Widget widget = new Container(
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                weekDay,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                )
              ),
            ),
            Expanded(
              flex: 9,
              child: Text(
                element.id == null || element.closed ? "Closed" : "${formatTime(element.start, false)} - ${formatTime(element.end, false)}",
                style: TextStyle(
                  color: globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80),
                  fontWeight: FontWeight.normal,
                )
              ),
            )
          ]
        )
      );
      children.add(widget);
    });

    return children;
  }

  _buildScreen() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          buildAvailabilityCalendar(),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Next 7-Day Availability Schedule",
                  style: TextStyle(
                    fontWeight: FontWeight.w600
                  )
                ),
                Expanded(
                  child: ListView(
                    children: buildWeekAvailability(widget.availability),
                  )
                )
              ]
            )
          )
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
            "Availability",
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

class SetAvailabilityPopup extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final DateTime date;
  final bool closed;
  final ValueChanged<List> onSetAvailability;
  SetAvailabilityPopup({Key key, this.start, this.end, this.date, this.closed, @required this.onSetAvailability}) : super (key: key);

  @override
  _SetAvailabilityPopup createState() => new _SetAvailabilityPopup();
}

class _SetAvailabilityPopup extends State<SetAvailabilityPopup> {
  DateTime start;
  DateTime end;
  bool startIsAM;
  bool endIsAM;
  bool closed;

  @override
  void initState() {
    start = widget.start;
    end = widget.end;
    closed = widget.closed ?? false;

    startIsAM = start.hour >= 12 ? false : true;
    endIsAM = end.hour >= 12 ? false : true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMM d, yyyy').format(widget.date);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: new AlertDialog(
      title: new Text(formattedDate,
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontSize: 16.0),
        ),
        content: Container(
          constraints: BoxConstraints(
            maxHeight: 180,
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Start Time",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600
                                  )
                                ),
                                Row(
                                  children: [
                                    CustomTimePicker(
                                      initialTime: start,
                                      onTimeChange: (Duration value) {
                                        DateTime date = DateTime.parse(DateFormat('yyyy-MM-dd').format(widget.date));
                                        DateTime newStartDateTime = date.add(value);

                                        if(!startIsAM) {
                                          Duration duration = Duration(
                                            hours: value.inHours + 12,
                                            minutes: value.inMinutes.remainder(60),
                                            seconds: 0
                                          );
                                          newStartDateTime = date.add(duration);
                                        }

                                        setState(() {
                                          start = newStartDateTime;
                                        });
                                      },
                                    ),
                                    Padding(padding: EdgeInsets.all(5.0)),
                                    ToggleButton(
                                      initialTime: start,
                                      onChange: (bool value) {
                                        if(!value && start.hour <= 12) {
                                          DateTime x = start.add(new Duration(hours: 12));
                                          setState(() {
                                            start = x;
                                            startIsAM = value;
                                          });
                                        }else if(value && start.hour > 12) {
                                          DateTime x = start.add(new Duration(hours: 12));
                                          setState(() {
                                            start = x;
                                            startIsAM = value;
                                          });
                                        }else if(value && end.hour == 12) {
                                          DateTime x = end.subtract(new Duration(hours: 12));
                                          setState(() {
                                            end = x;
                                            endIsAM = value;
                                          });
                                        }
                                      },
                                    )
                                  ],
                                )
                              ]
                            ),
                            Padding(padding: EdgeInsets.all(5.0)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "End Time",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600
                                  )
                                ),
                                Row(
                                  children: [
                                    CustomTimePicker(
                                      initialTime: end,
                                      onTimeChange: (Duration value) {
                                        DateTime date = DateTime.parse(DateFormat('yyyy-MM-dd').format(widget.date));
                                        DateTime newEndDateTime = date.add(value);

                                        if(!endIsAM) {
                                          Duration duration = Duration(
                                            hours: value.inHours + 12,
                                            minutes: value.inMinutes.remainder(60),
                                            seconds: 0
                                          );
                                          newEndDateTime = date.add(duration);
                                        }

                                        setState(() {
                                          end = newEndDateTime;
                                        });
                                      },
                                    ),
                                    Padding(padding: EdgeInsets.all(5.0)),
                                    ToggleButton(
                                      initialTime: end,
                                      onChange: (value) {
                                        if(!value && end.hour <= 12) {
                                          DateTime x = end.add(new Duration(hours: 12));
                                          setState(() {
                                            end = x;
                                            endIsAM = value;
                                          });
                                        }else if(value && end.hour > 12) {
                                          DateTime x = end.add(new Duration(hours: 12));
                                          setState(() {
                                            end = x;
                                            endIsAM = value;
                                          });
                                        }else if(value && end.hour == 12) {
                                          DateTime x = end.subtract(new Duration(hours: 12));
                                          setState(() {
                                            end = x;
                                            endIsAM = value;
                                          });
                                        }
                                      },
                                    )
                                  ],
                                )
                              ]
                            ),
                          ]
                        ),
                      )
                    ),
                    closed ? Positioned.fill(
                      child: Container(
                        color: Colors.black.withAlpha(220),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "CLOSED",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ) : Container()
                  ]
                )
              ),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          activeColor: Colors.blue,
                          value: closed,
                          onChanged: (bool value) {
                            setState(() {
                              closed = value;
                            });
                          },
                        )
                      ),
                      Text('Closed', style: TextStyle(fontWeight: FontWeight.w600))
                    ]
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          child: Text("Cancel",
                          textAlign: TextAlign.center),
                          onPressed: () { 
                            Navigator.of(context).pop();
                          },
                        )
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Expanded(
                        child: RaisedButton(
                          child: Text("Set Availability",
                          textAlign: TextAlign.center),
                          onPressed: () {
                            setState(() {
                              widget.onSetAvailability([start, end, closed]);
                            });
                            Navigator.of(context).pop();
                          },
                        )
                      ),
                    ]
                  )
                ]
              )
            ]
          )
        ),
      ),
    );
  }
}

class ToggleButton extends StatefulWidget {
  final ValueChanged<bool> onChange;
  final DateTime initialTime;
  ToggleButton({Key key, @required this.onChange, @required this.initialTime}) : super (key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  final double width = 70.0;
  final double height = 30.0;
  final double amAlign = -1;
  final double pmAlign = 1;
  final Color selectedColor = Colors.white;
  final Color normalColor = Colors.black54;
  double xAlign;
  bool value;

  @override
  void initState() {
    super.initState();
    if(widget.initialTime.hour >= 12) {
      xAlign = pmAlign;
      value = false;
    }else {
      xAlign = amAlign;
      value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(xAlign, 0),
              duration: Duration(milliseconds: 200),
              child: Container(
                width: width * 0.5,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if(value != true) {
                    xAlign = amAlign;
                    value = true;
                    widget.onChange(true);
                  }
                });
              },
              child: Align(
                alignment: Alignment(-1, 0),
                child: Container(
                  width: width * 0.5,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'AM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if(value != false) {
                    xAlign = pmAlign;
                    value = false;
                    widget.onChange(false);
                  }
                });
              },
              child: Align(
                alignment: Alignment(1, 0),
                child: Container(
                  width: width * 0.5,
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    'PM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class CustomTimePicker extends StatefulWidget {
  final ValueChanged<Duration> onTimeChange;
  final DateTime initialTime;
  CustomTimePicker({Key key, @required this.onTimeChange, this.initialTime}) : super (key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  List<Widget> columns = [];
  int selectedHour;
  int selectedMinute;
  int selectedSecond = 0;

  @override
  void initState() {
    selectedHour = widget.initialTime.hour > 12 ? (widget.initialTime.hour - 12) : widget.initialTime.hour ?? 8;
    selectedMinute = widget.initialTime.minute ?? 0;
    super.initState();
  }

  Widget _buildHourPicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: selectedHour - 1),
      offAxisFraction: -0.5 * 1,
      itemExtent: 26.0,
      squeeze: 1.25,
      onSelectedItemChanged: (int index) {
        setState(() {
          final int hour = index + 1;
          selectedHour = hour;
          widget.onTimeChange(
            Duration(
              hours: selectedHour,
              minutes: selectedMinute,
              seconds: selectedSecond ?? 0));
        });
      },
      children: List<Widget>.generate(12, (int index) {
        final int hour = index + 1;

        return Semantics(
          excludeSemantics: true,
          child: Text(hour.toString()),
        );
      }),
    );
  }

  Widget _buildHourColumn() {
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            setState(() { /*lastSelectedHour = selectedHour;*/ });
            return false;
          },
          child: _buildHourPicker(),
        ),
      ],
    );
  }

  Widget _buildMinutePicker() {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(
        initialItem: selectedMinute * 1,
      ),
      offAxisFraction: -0.5 * 1,
      itemExtent: 26.0,
      squeeze: 1.25,
      looping: true,
      onSelectedItemChanged: (int index) {
        setState(() {
          selectedMinute = index * 1;
          widget.onTimeChange(
            Duration(
              hours: selectedHour ?? 0,
              minutes: selectedMinute,
              seconds: selectedSecond ?? 0));
        });
      },
      children: List<Widget>.generate(60 ~/ 1, (int index) {
        // final int minute = index * 1;
        String minuteString = index.toString().length == 1 ? "0$index" : "$index";

        return Semantics(
          excludeSemantics: true,
          child: Text(minuteString),
        );
      }),
    );
  }

  Widget _buildMinuteColumn() {
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) {
            setState(() { /*lastSelectedMinute = selectedMinute;*/ });
            return false;
          },
          child: _buildMinutePicker(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    columns = <Widget>[
      _buildHourColumn(),
      _buildMinuteColumn()
    ];

    return Container(
      width: 70.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(5.0)
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Container(
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: columns.map((Widget child) => Expanded(child: child)).toList(growable: true),
          ),
        )
      )
    );
  }
}