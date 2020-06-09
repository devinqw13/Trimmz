import 'package:flutter/material.dart';
import '../Calls/GeneralCalls.dart';
import '../functions.dart';
import '../globals.dart' as globals;
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import '../Model/Packages.dart';
import 'package:trimmz/Model/AvailabilityV2.dart';
import '../Model/AppointmentRequests.dart';
import '../Model/BarberPolicies.dart';
import 'BarberHubController.dart';
import 'package:progress_hud/progress_hud.dart';

class SendAnnoucement extends StatefulWidget {
  final List<Map<dynamic, dynamic>> recipients;
  final List selectedEvents;
  final List<Packages> packages;
  final Map<DateTime, List> events;
  final List<AvailabilityV2> availabilityV2;
  final List<AppointmentRequest> appointmentReq;
  final BarberPolicies policies;
  SendAnnoucement({Key key, this.recipients, this.appointmentReq, this.availabilityV2, this.events, this.packages, this.policies, this.selectedEvents}) : super (key: key);

  @override
  SendAnnoucementState createState() => new SendAnnoucementState();
}

class SendAnnoucementState extends State<SendAnnoucement> {
  List<Map<dynamic, dynamic>> recipients = [];
  TextEditingController textController = new TextEditingController();
  StreamController<String> textStreamController = StreamController();
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  bool isEmpty = true;

  @override
  void initState() {
    super.initState();
    recipients = widget.recipients;

    textStreamController.stream
    .debounce(Duration(milliseconds: 100))
    .listen((s) => _textValue(s));

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      containerColor: Color.fromRGBO(21, 21, 21, 0.4),
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
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

  _textValue(String string) async {
    if(textController.text.length > 0) {
      setState(() {
        isEmpty = false;
      });
    }else {
      setState(() {
        isEmpty = true;
      });
    }
  }

  sendMessage(String message) async {
    progressHUD();
    for(var item in recipients) {
      List tokens = await getNotificationTokens(context, item['id']);
      sendNotifications(context, tokens, item['id'], '${globals.username}', '$message', 'BOOK_APPOINTMENT');
    }
    progressHUD();

    final barberHubScreen = new BarberHubScreen(selectedEvents: widget.selectedEvents, packages: widget.packages, events: widget.events, availabilityV2: widget.availabilityV2, appointmentReq: widget.appointmentReq, policies: widget.policies);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => barberHubScreen));
  }

  buildBody() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget> [
          Expanded(
            child: TextField(
              controller: textController,
              onChanged: (val) {
                textStreamController.add(val);
              },
              keyboardType: TextInputType.multiline,
              maxLines: 8,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Annoucement',
                hintStyle: TextStyle(fontStyle: FontStyle.italic),
                border: InputBorder.none,
              ),
            ),
          )
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
          title: new Text('New Annoucement'),
          actions: <Widget>[
            textController.text.length > 0 ? FlatButton(
              onPressed: () {
                sendMessage(textController.text);
              },
              child: Text('Send', style: TextStyle(fontWeight: FontWeight.bold))
            ) : Container()
          ],
        ),
        body: new Stack(
          children: <Widget> [
            buildBody(),
            _progressHUD
          ]
        )
      )
    );
  }
}