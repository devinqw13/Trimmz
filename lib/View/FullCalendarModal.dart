import 'package:flutter/material.dart';
import 'package:trimmz/Model/availability.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

class FullCalendarModal extends StatefulWidget {
  FullCalendarModal({@required this.appointments, this.showAppointmentOptions, this.selectDate, this.showManualAddAppointment});
  final appointments;
  final DateTime selectDate;
  final ValueChanged showAppointmentOptions;
  final ValueChanged showManualAddAppointment;

  @override
  _FullCalendarModal createState() => _FullCalendarModal();
}

class _FullCalendarModal extends State<FullCalendarModal> with TickerProviderStateMixin{
  CalendarController _calendarController;
  AnimationController _animationController;
  List _selectedEvents = [];
  Map<DateTime, List> _events;
  Availability aDay;
  final df = new DateFormat('yyyy-MM-dd');
  DateTime selectedDate;

  @override
  void initState() {
    final _selectedDay = DateTime.parse(df.format(DateTime.parse(DateTime.now().toString())));
    _events = widget.appointments;

    if(widget.selectDate != null){
      DateTime previousDateSelected = DateTime.parse(df.format(DateTime.parse(widget.selectDate.toString())));
      _selectedEvents = _events[previousDateSelected];
    }else {
      _selectedEvents = _events[_selectedDay] ?? [];
    }

    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();  
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      selectedDate = day;
      _selectedEvents = events;
    });
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.blue[700]
      ),
      width: 20.0,
      height: 20.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 13.0,
          ),
        ),
      ),
    );
  }

  buildList() {
    if(_selectedEvents != null && _selectedEvents.length > 0){
      return Expanded(
        child: new ListView.builder(
          shrinkWrap: true,
          itemCount: _selectedEvents.length,
          itemBuilder: (context, i) {
            Color statusColor;
            if(_selectedEvents[i]['status'] == '0'){
              var time = _selectedEvents[i]['full_time'];
              if(DateTime.now().isAfter(DateTime.parse(time))) {
                statusColor = Colors.grey;
              }else {
                statusColor = Colors.blue;
              }
            }else if(_selectedEvents[i]['status'] == '1'){
              statusColor = Colors.green;
            }else if(_selectedEvents[i]['status'] == '2'){
              statusColor = Colors.red;
            }
            return new GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.showAppointmentOptions(_selectedEvents[i]);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 1),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: new LinearGradient(
                    begin: Alignment(1.0, .5),
                    colors: [Colors.black, Colors.black26]
                  )
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _selectedEvents[i]['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Text(_selectedEvents[i]['package']),
                        Text('\$'+(int.parse(_selectedEvents[i]['price']) + int.parse(_selectedEvents[i]['tip'])).toString())
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(_selectedEvents[i]['time']),
                        Text(
                          statusColor == Colors.grey ? 'Pending' : statusColor == Colors.blue ? 'Upcoming' : statusColor == Colors.green ? 'Completed' : 'Cancelled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor == Colors.grey ? Colors.grey : statusColor == Colors.blue ? Colors.blue : statusColor == Colors.green ? Colors.green : Colors.red
                          )
                        )
                      ]
                    )
                  ]
                )
              )
            );
          },
        )
      );
    }else {
      return new Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(LineIcons.frown_o, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
            new Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: new Text(
                "No Appointments",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * .018,
                  color: Colors.grey[600]
                )
              ),
            ),
          ],
        )
      );
    }
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
        child: Column(
          children: <Widget> [
            TableCalendar(
              locale: 'en_US',
              events: _events,
              onDaySelected: _onDaySelected,
              availableGestures: AvailableGestures.horizontalSwipe,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: const TextStyle(color: const Color(0xFFf2f2f2)),
                weekendStyle: const TextStyle(color: const Color(0xFFf2f2f2))
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.blue),
                rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.blue)
              ),
              calendarStyle: CalendarStyle(
                weekendStyle: const TextStyle(color: Colors.white),
                outsideWeekendStyle: TextStyle(color: Color(0xFF9E9E9E)),
              ),
              headerVisible: true,
              calendarController: _calendarController,
              initialSelectedDay: widget.selectDate != null ? widget.selectDate : DateTime.now(),
              initialCalendarFormat: CalendarFormat.month,
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

                  if (events.isNotEmpty) {
                    children.add(
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(date, events),
                      ),
                    );
                  }
                  return children;
                },
              ),
            ),
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    widget.showManualAddAppointment(selectedDate);
                  },
                  child: Icon(LineIcons.calendar_plus_o, color: Colors.blue, size: 30)
                )
              ],
            ),
            Padding(padding: EdgeInsets.all(5)),
            buildList(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close')
                    ),
                  ),
                ),
              ],
            ),
          ]
        )
      )
    );
  }
}