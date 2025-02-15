import 'package:flutter/material.dart';
import '../calls.dart';
import '../Model/BarberClients.dart';
import '../globals.dart' as globals;
import 'package:line_icons/line_icons.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:stream_transform/stream_transform.dart';
import 'dart:async';
import '../Model/Packages.dart';
import '../Model/availability.dart';
import '../Model/AppointmentRequests.dart';
import '../Model/BarberPolicies.dart';
import 'SendAnnoucementController.dart';

class AddAnnoucementRecipients extends StatefulWidget {
  final List selectedEvents;
  final List<Packages> packages;
  final Map<DateTime, List> events;
  final List<Availability> availability;
  final List<AppointmentRequest> appointmentReq;
  final BarberPolicies policies;
  AddAnnoucementRecipients({Key key, this.appointmentReq, this.availability, this.events, this.packages, this.policies, this.selectedEvents}) : super (key: key);

  @override
  AddAnnoucementRecipientsState createState() => new AddAnnoucementRecipientsState();
}

class AddAnnoucementRecipientsState extends State<AddAnnoucementRecipients> {
  TextEditingController searchRecipientController = new TextEditingController();
  StreamController<String> searchStreamController = StreamController();
  List<Map<dynamic, dynamic>> recipients = [];
  List<BarberClients> suggested = [];
  List<BarberClients> searched = [];

  void initState() {
    super.initState();

    initGetSuggested();

    searchStreamController.stream
    .debounce(Duration(milliseconds: 100))
    .listen((s) => _searchValue(s));
  }

  initGetSuggested() async {
    var res = await getBarberClients(context, globals.token, 2);
    setState(() {
      suggested = res;
    });

    for(var client in res) {
      var res1 = recipients.where((item) => item.containsValue(client.username));
      if(res1.length > 0) {
        setState(() {
          client.selected = true;
        });
      }
    }
  }

  _searchValue(String string) async {
    if(searchRecipientController.text.length > 2) {
      var res = await getSearchClients(context, searchRecipientController.text);
      setState(() {
        searched = res;
      });
      for(var client in searched) {
        var res1 = recipients.where((item) => item.containsValue(client.username));
        if(res1.length > 0) {
          setState(() {
            client.selected = true;
          });
        }
      }
    }
    if(searchRecipientController.text.length <= 2) {
      setState(() {
        searched = [];
      });
    }
  }

  buildRecipientSearch() {
    return Row(
      children: <Widget>[
        Container(
          height: 50,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: recipients.length,
            itemBuilder: (context, i) {
              return Center(
                child: Container(
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.only(top: 5, bottom: 5, left: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        recipients[i]['username']
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            for(var item in suggested) {
                              if(item.username == recipients[i]['username']) {
                                setState(() {
                                  item.selected = false;
                                });
                              }
                            }
                            if(searched.length > 0) {
                              for(var item in searched) {
                                if(item.username == recipients[i]['username']) {
                                  setState(() {
                                    item.selected = false;
                                  });
                                }
                              }
                            }
                            recipients.removeWhere((item) => item.containsValue(recipients[i]['username']));
                          });
                        },
                        child: Icon(LineIcons.close, size: 15),
                      )
                    ]
                  )
                )
              );
            },
          )
        ),
        Expanded(
          child: TextField(
            controller: searchRecipientController,
            onChanged: (val) {
              searchStreamController.add(val);
            },
            autocorrect: false,
            decoration: InputDecoration(
              hintText: recipients.length > 0 ? '' : 'Search',
              hintStyle: TextStyle(fontStyle: FontStyle.italic),
              border: InputBorder.none
            ),
          )
        )
      ]
    );
  }

  buildBody() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
                buildRecipientSearch()
              ]
            )
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: searched.length > 0 ? Text('Searched', style: TextStyle(fontWeight: FontWeight.bold)) : Text('Your Clients', style: TextStyle(fontWeight: FontWeight.bold))
          ),
          searched.length > 0 ? Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: searched.length,
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, i) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          searched[i].selected = !searched[i].selected;
                        });
                        Map map = {'id': searched[i].token, 'username': searched[i].username};
                        var res = recipients.where((item) => item.containsValue(searched[i].username));
                        if(res.length > 0) {
                          recipients.removeWhere((item) => item.containsValue(searched[i].username));
                        }else {
                          recipients.add(map);
                          searchRecipientController.clear();
                          searched = [];
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.purple,
                                  gradient: new LinearGradient(
                                    colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                                  )
                                ),
                                child: Center(child:Text(searched[i].username.substring(0,1), style: TextStyle(fontSize: 20)))
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(searched[i].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * .02)),
                                  Text(searched[i].username, style: TextStyle(color: Colors.grey))
                                ],
                              )
                            ]
                          ),
                          CircularCheckBox(
                            activeColor: Colors.blue,
                            value: searched[i].selected,
                            onChanged: (value) {
                              setState(() {
                                searched[i].selected = value;
                              });
                              Map map = {'id': searched[i].token, 'username': searched[i].username};
                              var res = recipients.where((item) => item.containsValue(searched[i].username));
                              if(res.length > 0) {
                                recipients.removeWhere((item) => item.containsValue(searched[i].username));
                              }else {
                                recipients.add(map);
                                searchRecipientController.clear();
                                searched = [];
                              }
                            },
                          )
                        ]
                      )
                    )
                  );
                }
              )
            )
          ) :
          suggested.length > 0 ? Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: suggested.length,
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, i) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        Map map = {'id': suggested[i].token, 'username': suggested[i].username};
                        var res = recipients.where((item) => item.containsValue(suggested[i].username));
                        if(res.length > 0) {
                          recipients.removeWhere((item) => item.containsValue(suggested[i].username));
                        }else {
                          recipients.add(map);
                        }
                        setState(() {
                          suggested[i].selected = !suggested[i].selected;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.purple,
                                  gradient: new LinearGradient(
                                    colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
                                  )
                                ),
                                child: Center(child:Text(suggested[i].username.substring(0,1), style: TextStyle(fontSize: 20)))
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(suggested[i].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * .02)),
                                  Text(suggested[i].username, style: TextStyle(color: Colors.grey))
                                ],
                              )
                            ]
                          ),
                          CircularCheckBox(
                            activeColor: Colors.blue,
                            value: suggested[i].selected,
                            onChanged: (value) {
                              Map map = {'id': suggested[i].token, 'username': suggested[i].username};
                              var res = recipients.where((item) => item.containsValue(suggested[i].username));
                              if(res.length > 0) {
                                recipients.removeWhere((item) => item.containsValue(suggested[i].username));
                              }else {
                                recipients.add(map);
                              }
                              setState(() {
                                suggested[i].selected = value;
                              });
                            },
                          )
                        ]
                      )
                    )
                  );
                }
              )
            )
          ) : Expanded(
            child: Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    Icon(LineIcons.search, size: MediaQuery.of(context).size.height * .2, color: Colors.grey[600]),
                    Text(
                      'Search for clients to send annoucements to',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * .018,
                        color: Colors.grey[600]
                      )
                    )
                  ]
                )
              )
            )
          ),
        ]
      ),
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
          title: new Text('New Annoucement'),
          actions: <Widget>[
            recipients.length > 0 ? FlatButton(
              onPressed: () {
                final sendAnnoucementScreen = new SendAnnoucement(recipients: recipients, selectedEvents: widget.selectedEvents, packages: widget.packages, events: widget.events, availability: widget.availability, appointmentReq: widget.appointmentReq, policies: widget.policies);
                Navigator.push(context, new MaterialPageRoute(builder: (context) => sendAnnoucementScreen));
              },
              child: Text('Next', style: TextStyle(fontWeight: FontWeight.bold))
            ) : Container()
          ],
        ),
        body: new Stack(
          children: <Widget> [
            buildBody(),
            //_progressHUD
          ]
        )
      )
    );
  }
}