import 'package:flutter/material.dart';
import 'package:trimmz/Model/availability.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import '../calls.dart';
import '../globals.dart' as globals;

class AvailabilityBottomSheet extends StatefulWidget {
  AvailabilityBottomSheet({@required this.switchValue, @required this.valueChanged, @required this.avail, @required this.getAvailability});

  final bool switchValue;
  final Availability avail;
  final ValueChanged valueChanged;
  final ValueChanged getAvailability;

  @override
  _AvailabilityBottomSheet createState() => _AvailabilityBottomSheet();
}

class _AvailabilityBottomSheet extends State<AvailabilityBottomSheet> {
  bool _switchValue;
  Availability aDay;

  @override
  void initState() {
    _switchValue = widget.switchValue;
    aDay = widget.avail;
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var start;
    var end;
    if(aDay.start == null && aDay.end == null){
      start = DateTime.parse(DateFormat('Hms', 'en_US').parse('00:00:00').toString());
      end = DateTime.parse(DateFormat('Hms', 'en_US').parse('12:00:00').toString());
    }else {
      start = DateTime.parse(DateFormat('Hms', 'en_US').parse(aDay.start).toString());
      end = DateTime.parse(DateFormat('Hms', 'en_US').parse(aDay.end).toString());
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  aDay.day,
                  style: TextStyle(
                    fontSize: 20.0
                  )
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TimePickerSpinner(
                  normalTextStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0
                  ),
                  highlightedTextStyle: TextStyle(
                    color: _switchValue ? Colors.grey : Colors.white,
                    fontSize: 30.0
                  ),
                  spacing: 0.0,
                  time: start,
                  is24HourMode: false,
                  isForce2Digits: true,
                  onTimeChange: (dateTime) {
                    start = dateTime;
                  },
                ),
                Text(' to ', style: TextStyle(fontSize: 20.0, color: _switchValue ? Colors.grey : Colors.white)),
                TimePickerSpinner(
                  normalTextStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0
                  ),
                  highlightedTextStyle: TextStyle(
                    color: _switchValue ? Colors.grey : Colors.white,
                    fontSize: 30.0
                  ),
                  spacing: 0.0,
                  time: end,
                  is24HourMode: false,
                  isForce2Digits: true,
                  onTimeChange: (dateTime) {
                    end = dateTime;
                  },
                )
              ]
            ),
            Row(
              children: <Widget>[
                Container(
                  child: Checkbox(
                    activeColor: Colors.blue,
                    value: _switchValue,
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue = value;
                        widget.valueChanged(value);
                      });
                    },
                  )
                ),
                Text('Mark as closed', style: TextStyle(fontSize: 20.0))
              ],
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')
                    )
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Expanded(
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        var res = await setTimeAvailability(context, globals.token, aDay.day, start, end, _switchValue);
                        if(res){
                          var res1 = await getBarberAvailability(context, globals.token);
                          setState(() {
                            widget.getAvailability(res1);
                          });
                          Navigator.pop(context);
                        }else {
                          return;
                        }
                      },
                      child: Text('Confirm')
                    )
                  )
                ],
              )
            )
          ]
        )
      )
    );
  }
}