import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import '../Calls/GeneralCalls.dart';
import '../globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';

class AvailabilityV2BottomSheet extends StatefulWidget {
  AvailabilityV2BottomSheet({@required this.switchValue, @required this.valueChanged, @required this.avail, @required this.getAvailability});
  final bool switchValue;
  final List avail;
  final ValueChanged valueChanged;
  final ValueChanged getAvailability;

  @override
  _AvailabilityV2BottomSheet createState() => _AvailabilityV2BottomSheet();
}

class _AvailabilityV2BottomSheet extends State<AvailabilityV2BottomSheet> {
  bool _switchValue;
  List aDay;
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;

  @override
  void initState() {
    _switchValue = widget.switchValue;
    aDay = widget.avail;

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );
    
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

  @override
  Widget build(BuildContext context) {
    var start = DateTime.parse(DateFormat('Hms', 'en_US').parse(aDay.first['start']).toString());
    var end = DateTime.parse(DateFormat('Hms', 'en_US').parse(aDay.first['end']).toString());

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 355,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
            color: globals.darkModeEnabled ? Color.fromARGB(255, 21, 21, 21) : Color(0xFFFAFAFA),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2, color: Colors.grey[400], spreadRadius: 0)
            ]),
        child: Stack(
          children: <Widget> [
            Column(
              children: <Widget> [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      DateFormat('EEE, MMM d').format(aDay.first['date']),
                      //aDay.day,
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
                        color: _switchValue ? Colors.grey : globals.darkModeEnabled ? Colors.white : Colors.black,
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
                    Text(' to ', style: TextStyle(fontSize: 20.0, color: _switchValue ? Colors.grey : globals.darkModeEnabled ? Colors.white : Colors.black)),
                    TimePickerSpinner(
                      normalTextStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 20.0
                      ),
                      highlightedTextStyle: TextStyle(
                        color: _switchValue ? Colors.grey : globals.darkModeEnabled ? Colors.white : Colors.black,
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
                          textColor: Colors.white,
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
                          textColor: Colors.white,
                          onPressed: () async {
                            progressHUD();
                            var res = await setTimeAvailabilityV2(context, globals.token, aDay.first['date'].toString(), start, end, _switchValue);
                            if(res){
                              var res1 = await getBarberAvailabilityV2(context, globals.token);
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
            ),
            _progressHUD
          ]
        )
      )
    );
  }
}