import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/NotificationItem.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/Controller/ComposeAnnoucementController.dart';
import 'package:trimmz/Model/User.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/Model/WidgetStatus.dart';
import 'dart:ui' as ui;
import 'package:circular_check_box/circular_check_box.dart';

class NotificationCenterController extends StatefulWidget {
  final List<NotificationItem> notifications;
  final List<User> clients;
  final screenHeight;
  NotificationCenterController({Key key, this.notifications, this.clients, this.screenHeight}) : super (key: key);

  @override
  NotificationCenterControllerState createState() => new NotificationCenterControllerState();
}

class NotificationCenterControllerState extends State<NotificationCenterController> with TickerProviderStateMixin {
  List<NotificationItem> notifications = [];
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  WidgetStatus _clientsWidgetStatus = WidgetStatus.HIDDEN;
  AnimationController clientsAnimationController, opacityAnimationController;
  Animation clientsPositionAnimation, clientsOpacityAnimation;
  final duration = new Duration(milliseconds: 200);
  bool clientsActive = true;
  final TextEditingController clientSearchController = new TextEditingController();
  String filter;
  bool allClientsSelected = false;
  List<SelectionOption> clients = [];

  @override
  void initState() {
    super.initState();

    readNotifications();
    
    notifications = widget.notifications;

    for(var item in widget.clients) {
      clients.add(new SelectionOption(item));
    }

    clientSearchController.addListener(() {
      setState(() {
        filter = clientSearchController.text;
      });
    });

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    clientsAnimationController = new AnimationController(duration: duration, vsync: this);
    opacityAnimationController = new AnimationController(duration: duration, vsync: this);
    clientsPositionAnimation = new Tween(begin: 0.0, end: widget.screenHeight).animate(
      new CurvedAnimation(parent: clientsAnimationController, curve: Curves.easeInOut)
    );
    clientsOpacityAnimation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: opacityAnimationController, curve: Curves.easeInOut)
    );
    clientsPositionAnimation.addListener(() {
      setState(() {});
    });
    clientsOpacityAnimation.addListener(() {
      setState(() {});
    });
    clientsAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (clientsActive) {
          _clientsWidgetStatus = WidgetStatus.VISIBLE;
        } else {
          _clientsWidgetStatus = WidgetStatus.HIDDEN;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    clientSearchController.dispose();
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

  bool searchFilterText(User result) {
    bool match = false;
    if (result.username.toLowerCase().contains(filter.toLowerCase()) ||result.name.toLowerCase().contains(filter.toLowerCase())) {
      match = true;
      return match;
    }
    return match;
  }

  void onTapDown() {
    if (_clientsWidgetStatus == WidgetStatus.HIDDEN) {
      clientsAnimationController.forward(from: 0.0);
      opacityAnimationController.forward(from: 0.0);
      _clientsWidgetStatus = WidgetStatus.VISIBLE;
    }
    else if (_clientsWidgetStatus == WidgetStatus.VISIBLE) {
      clientsAnimationController.reverse(from: 400.0);
      opacityAnimationController.reverse(from: 1.0);
      _clientsWidgetStatus = WidgetStatus.HIDDEN;
    }
  }

  readNotifications() {
    var _ = setNotificationsRead(context, globals.user.token);
  }

  Widget _buildScreen() {
    return Container(
      height: double.infinity,
      child: notifications.length > 0 ? SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Slidable(
                  actionPane: SlidableStrechActionPane(),
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        buildSmallUserProfilePicture(context, notifications[index].profilePicture, notifications[index].fromUser),
                        Padding(padding: EdgeInsets.all(5)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifications[index].title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text(notifications[index].body)
                            ]
                          )
                        )
                      ]
                    )
                  ),
                  secondaryActions: [
                    IconSlideAction(
                      caption: 'Remove',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        var _ = removeNotification(context, globals.user.token, notifications[index].id);
                        setState(() {
                          notifications.removeAt(index);
                        });
                      },
                    ),
                  ]
                );
              }
            )
          ]
        )
      ): Center(
        child: Text(
          "No Notifications",
        )
      )
    );
  }

  Widget _buildClientsTo() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: <Widget>[
              Container(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: clients.length,
                  itemBuilder: (context, i) {
                    if(!clients[i].selected) {
                      return Container();
                    }else {
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
                                clients[i].user.username,
                                style: TextStyle(color: Colors.white),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    clients[i].selected = false;
                                  });

                                  checkSelections(clients[i]);
                                },
                                child: Icon(Icons.close, size: 15, color: Colors.white),
                              )
                            ]
                          )
                        )
                      );
                    }
                  },
                )
              ),
              Expanded(
                child: TextField(
                  controller: clientSearchController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: clients.where((e) => e.selected == true).length > 0 ? '' : 'Search',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic),
                    border: InputBorder.none
                  ),
                )
              )
            ]
          )
        ]
      )
    );
  }

  Widget _buildSelectAll() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          filter == null || filter == "" ? "Your Clients" : 'Searched',
          style: TextStyle(
            fontWeight: FontWeight.bold
          )
        ),
        Row(
          children: [
            Text("Select all clients"),
            CircularCheckBox(
              activeColor: Colors.blue,
              value: allClientsSelected,
              onChanged: (value) {
                var anyFalseItems = clients.where((e) => e.selected == false);
                if(anyFalseItems.length > 0) {
                  setState(() {
                    clients.forEach((e) {e.selected = true;});
                    allClientsSelected = true;
                  });
                }else {
                  setState(() {
                    clients.forEach((e) {e.selected = false;});
                    allClientsSelected = false;
                  });
                }
              }
            )
          ],
        )
      ],
    );
  }

  checkSelections(SelectionOption option) {
    if(!option.selected) {
      setState(() {
        allClientsSelected = false;
      });
    }else {
      var recipientList = clients.where((e) => e.selected == true);

      if(recipientList.length == clients.length) {
        setState(() {
          allClientsSelected = true;
        });
      }
    }
  }

  Widget _buildClientsList() {
    return Expanded(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: List<Widget>.generate(clients.length, (index) {
            return Container(
              padding: EdgeInsets.all(0),
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: buildUserProfilePicture(context, clients[index].user.profilePicture, clients[index].user.username),
                title: Text(clients[index].user.name),
                subtitle: Text(clients[index].user.username),
                trailing: CircularCheckBox(
                  activeColor: Colors.blue,
                  value: clients[index].selected,
                  onChanged: (value) {
                    setState(() {
                      clients[index].selected = value;
                    });

                    checkSelections(clients[index]);
                  }
                ),
              ),
            );
          })
        ),
      )
    );
  }

  Widget buildAddClients() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Expanded(
            child:  Column(
              children: [
                _buildClientsTo(),
                _buildSelectAll(),
                _buildClientsList(),
                clients.where((e) => e.selected == true).length > 0 ?
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          border: Border.all(
                            color: CustomColors1.mystic.withAlpha(100)
                          )
                        ),
                        child: RippleButton(
                          splashColor: CustomColors1.mystic.withAlpha(100),
                          onPressed: () async {
                            List<int> recipientIds = [];
                            clients.where((e) => e.selected == true).forEach((i) {recipientIds.add(i.user.id);});

                            print(recipientIds);

                            final composeAnnoucementController = new ComposeAnnoucementController(recipients: recipientIds);
                            bool res = await Navigator.push(context, new MaterialPageRoute(builder: (context) => composeAnnoucementController));

                            if(res != null){
                              if(res){
                                onTapDown();

                                for(var item in clients) {
                                  setState(() {
                                    item.selected = false;
                                  });
                                  checkSelections(item);
                                }
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                            child: Center(
                              child: Text(
                                "Create Announcement",
                                style: TextStyle(
                                  color: Colors.white
                                )
                              ),
                            )
                          )
                        )
                      ),
                    )
                  ]
                ): Container()
              ]
            )
          ),
        ]
      )
    );
  }

  Widget getClientsOverlay() {
    var searchHeight = 0.0;
    var searchOpacity = 0.0;
    switch(_clientsWidgetStatus) {
      case WidgetStatus.HIDDEN:
        searchHeight = clientsPositionAnimation.value;
        searchOpacity = clientsOpacityAnimation.value;
        clientsActive = false;
        break;
      case WidgetStatus.VISIBLE:
        searchHeight = clientsPositionAnimation.value;
        searchOpacity = clientsOpacityAnimation.value;
        clientsActive = true;
        break;
    }
    return new BackdropFilter(
      filter: new ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Container(
        padding: EdgeInsets.only(bottom: 25, left: 10, right: 10),
        width: MediaQuery.of(context).size.width,
        height: searchHeight,
        child: new Opacity(
          opacity: searchOpacity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: buildAddClients()
              ),
            ],
          )
        ),
        color: const Color.fromARGB(120, 0, 0, 0),
      )
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
            "Notifications",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
          actions: [
            globals.user.userType == 2 ?
            _clientsWidgetStatus != WidgetStatus.VISIBLE ? IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              icon: Icon(Icons.add),
              onPressed: () {
                onTapDown();
              },
            ):
            FlatButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onPressed: () {
                onTapDown();
              },
              child: Text("Cancel")
            ): Container()
          ]
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
                  getClientsOverlay(),
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

class SelectionOption {
  bool selected;
  User user;

  SelectionOption(User user) {
    this.user = user;
    this.selected = false;
  }
}