import 'package:flutter/material.dart';
import '../Calls/GeneralCalls.dart';
import 'package:trimmz/dialogs.dart';
import '../globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'dart:io';
import 'BarberHubController.dart';
import '../Model/Packages.dart';
import '../Model/availability.dart';
import '../Model/AppointmentRequests.dart';
import '../Model/BarberPolicies.dart';

class ShareImage extends StatefulWidget {
  final String image;
  final List selectedEvents;
  final List<Packages> packages;
  final Map<DateTime, List> events;
  final List<Availability> availability;
  final List<AppointmentRequest> appointmentReq;
  final BarberPolicies policies;
  ShareImage({Key key, this.image, this.appointmentReq, this.availability, this.events, this.packages, this.policies, this.selectedEvents}) : super (key: key);

  @override
  ShareImageState createState() => new ShareImageState();
}

class ShareImageState extends State<ShareImage> {
  TextEditingController captionController = new TextEditingController();
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  String image = '';

  void initState() {
    super.initState();

    image = widget.image;

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

  share() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * .2,
            height: MediaQuery.of(context).size.width * .2,
            child: Image.file(File(image))
          ),
          Padding(padding: EdgeInsets.all(5)),
          Expanded(
            child: TextField(
              controller: captionController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Caption',
                hintStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
            )
          )
        ]
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
                  share(),
                  Container(padding: EdgeInsets.all(10), child: Divider(color: Colors.grey))
                ],
              ),
            )
          ),
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
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new Text('Share'),
          actions: <Widget>[
            FlatButton(
              child: new Text('Share', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                progressHUD();
                var res = await uploadImage(context, image, 2, captionController.text);
                progressHUD();
                if(res != 'false') {
                  final barberHubScreen = new BarberHubScreen(selectedEvents: widget.selectedEvents, packages: widget.packages, events: widget.events, availability: widget.availability, appointmentReq: widget.appointmentReq, policies: widget.policies);
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => barberHubScreen));
                }else {
                  showErrorDialog(context, 'Unable to post', 'Your image was unable to post. Try again.');
                }
              }
            )
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