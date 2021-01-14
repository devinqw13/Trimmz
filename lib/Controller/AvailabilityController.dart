import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trimmz/Model/Availability.dart';
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

    for(Availability item in availability) {
      if(!_availability.containsKey(item.date)) {
        _availability[item.date] = [Map.from({"id": item.id, "date": item.date, "start": item.start, "end": item.end, "closed": item.closed})];
      }else {
        _availability[item.date].add(Map.from({"id": item.id, "date": item.date, "start": item.start, "end": item.end, "closed": item.closed}));
      }
    }

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

  _onAvailabilityDaySelect(DateTime day, List availDayList, _) {
    showDialog(
      context: context,
      builder: (context) => SetAvailabilityPopup(
        start: DateTime.parse(DateFormat('Hms', 'en_US').parse(availDayList.first['start']).toString()),
        end: DateTime.parse(DateFormat('Hms', 'en_US').parse(availDayList.first['end']).toString())
      )
    );
    // setState(() {
    //   availabilityDay = availDayList;
    //   selectedDay = day;
    //   isSelected = true;
    // });
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
          final children = <Widget>[];
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
  SetAvailabilityPopup({Key key, this.start, this.end}) : super (key: key);

  @override
  _SetAvailabilityPopup createState() => new _SetAvailabilityPopup();
}

class _SetAvailabilityPopup extends State<SetAvailabilityPopup> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: new AlertDialog(
      title: new Text(widget.end.toString(),
        textAlign: TextAlign.center,
        style: new TextStyle(
          fontSize: 16.0),
        ),
        content: new Container(
          child: new RaisedButton(
            child: new Text("OK",
            textAlign: TextAlign.center),
            onPressed: () { 
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}