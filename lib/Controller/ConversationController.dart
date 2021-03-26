import 'package:flutter/material.dart';
import 'package:trimmz/RippleButton.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/Conversation.dart';
import 'package:trimmz/Controller/MessagesController.dart';
import 'package:trimmz/Controller/NewMessageController.dart';
import 'package:trimmz/Model/TrimmzWebSocket.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:line_icons/line_icons.dart';
import 'package:trimmz/Model/WidgetStatus.dart';
import 'package:trimmz/Model/User.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'dart:ui' as ui;

class ConversationController extends StatefulWidget {
  final List<Conversation> cachedConversations;
  final User user;
  final screenHeight;
  ConversationController({Key key, this.cachedConversations, this.screenHeight, this.user}) : super (key: key);

  @override
  ConversationControllerState createState() => new ConversationControllerState();
}

class ConversationControllerState extends State<ConversationController> with TickerProviderStateMixin {
  WidgetStatus _newMessageWidgetStatus = WidgetStatus.HIDDEN;
  AnimationController newMessageAnimationController, opacityAnimationController;
  Animation newMessagePositionAnimation, newMessageOpacityAnimation;
  bool newMessageActive = true;
  final duration = new Duration(milliseconds: 200);
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<Conversation> conversationList = [];
  List<NewMessageUser> newMessageUsers = [];
  TrimmzWebSocket webSocket = new TrimmzWebSocket("Conversation", 0);
  TextEditingController searchRecipientsTFController = new TextEditingController();
  String filter;

  @override
  void initState() {
    webSocket.channel.stream.listen((event) async {
      webSocketAddMessage(event);
    }, onDone: webSocketReconnect);

    conversationList = widget.cachedConversations ?? [];

    searchRecipientsTFController.addListener(() {
      setState(() {
        filter = searchRecipientsTFController.text;
      });
    });

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    initGetConversations();
    getNewMessageUsers();

    newMessageAnimationController = new AnimationController(duration: duration, vsync: this);
    opacityAnimationController = new AnimationController(duration: duration, vsync: this);
    newMessagePositionAnimation = new Tween(begin: 0.0, end: widget.screenHeight).animate(
      new CurvedAnimation(parent: newMessageAnimationController, curve: Curves.easeInOut)
    );
    newMessageOpacityAnimation = new Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: opacityAnimationController, curve: Curves.easeInOut)
    );
    newMessagePositionAnimation.addListener(() {
      setState(() {});
    });
    newMessageOpacityAnimation.addListener(() {
      setState(() {});
    });
    newMessageAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (newMessageActive) {
          _newMessageWidgetStatus = WidgetStatus.VISIBLE;
        } else {
          _newMessageWidgetStatus = WidgetStatus.HIDDEN;
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    webSocket.channel.sink.close(status.goingAway);
  }

  bool searchFilterText(User result) {
    bool match = false;
    if (result.username.toLowerCase().contains(filter.toLowerCase()) ||result.name.toLowerCase().contains(filter.toLowerCase())) {
      match = true;
      return match;
    }
    return match;
  }

  getNewMessageUsers() async {
    List<User> results = await getConversationUsers(context, globals.user.token);

    for(User item in results) {
      setState(() {
        newMessageUsers.add(new NewMessageUser(item));
      });
    }
  }

  void onTapDownAdd() {
    if (_newMessageWidgetStatus == WidgetStatus.HIDDEN) {
      newMessageAnimationController.forward(from: 0.0);
      opacityAnimationController.forward(from: 0.0);
      _newMessageWidgetStatus = WidgetStatus.VISIBLE;
    }
    else if (_newMessageWidgetStatus == WidgetStatus.VISIBLE) {
      newMessageAnimationController.reverse(from: 400.0);
      opacityAnimationController.reverse(from: 1.0);
      _newMessageWidgetStatus = WidgetStatus.HIDDEN;
    }

    setState(() {
      newMessageUsers.forEach((element) => element.selected = false);
    });
  }

  wserror(err) async {
    await webSocketReconnect();
  }

  webSocketReconnect() async {
    if(this.mounted) {
      setState(() {
        webSocket = new TrimmzWebSocket("Conversation", 0);
      });
      webSocket.channel.stream.listen((event) async {
        webSocketAddMessage(event);
      }, onDone: webSocketReconnect);
    }
  }

  void webSocketAddMessage(var event) async {
    var data = json.decode(event);
    var result = await onWebSocketAction(data['key'], data['data'], other: conversationList);
    setState(() {
      conversationList = result;
    });
  }

  initGetConversations() async {
    List<Conversation> results = await getConversations(context);
    setState(() {
      conversationList = results;
    });
    conversationList.sort((a,b) => a.created.compareTo(b.created));

    if(widget.user != null) {
      var selectedConversation = conversationList.where((e) => e.userId == widget.user.id);
      
      if(selectedConversation.length > 0) {
        goToMessages(selectedConversation.first);
      }else {
        final newMessagesController = new NewMessagesController(user: widget.user);
        Navigator.push(context, new MaterialPageRoute(builder: (context) => newMessagesController));
      }
    }
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

  goToMessages(Conversation conversation) {
    setState(() {
      conversation.readConversation = true;
    });
    
    final messagesController = new MessagesController(conversation: conversation);
    Navigator.push(context, new MaterialPageRoute(builder: (context) => messagesController));
  }

  Widget _buildScreen() {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Container(
            //   margin: EdgeInsets.only(bottom: 10.0),
            //   decoration: BoxDecoration(
            //     color: globals.darkModeEnabled ? darkBackgroundGrey : Color.fromARGB(255, 232, 232, 232),
            //     borderRadius: BorderRadius.circular(50.0),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black12,
            //         blurRadius: 2.0,
            //         offset: Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: TextField(
            //     keyboardType: TextInputType.text,
            //     autocorrect: false,
            //     style: TextStyle(
            //       color: globals.darkModeEnabled ? Colors.white : Colors.black,
            //       fontFamily: 'OpenSans',
            //     ),
            //     decoration: InputDecoration(
            //       border: UnderlineInputBorder(borderSide: BorderSide.none),
            //       isDense: true,
            //       contentPadding: EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8),
            //       hintText: 'Search',
            //       hintStyle: TextStyle(
            //         color: globals.darkModeEnabled ? Colors.white54 : Colors.black54,
            //         fontFamily: 'OpenSans',
            //       ),
            //     ),
            //   )
            // ),
            conversationList.length > 0 ? ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: conversationList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => goToMessages(conversationList[index]),
                  child: Container(
                    child: Card(
                      color: globals.userBrightness == Brightness.light ? Colors.white : richBlack,
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            buildUserProfilePicture(context, conversationList[index].profilePicture, conversationList[index].username),
                            Padding(padding: EdgeInsets.all(5)),
                            Expanded(
                              flex: 9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conversationList[index].username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.0
                                    ),
                                  ),
                                  RichText(
                                    softWrap: false,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: !conversationList[index].readConversation ? 
                                        globals.darkModeEnabled ? Colors.white : Colors.black : Colors.grey,
                                        fontWeight: !conversationList[index].readConversation ? FontWeight.w600 : FontWeight.normal
                                      ),
                                      children: [
                                        TextSpan(
                                          text: conversationList[index].messages.first.senderId == globals.user.token ? "You: " : "${conversationList[index].username}: ",
                                        ),
                                        TextSpan(
                                          text: conversationList[index].recentMessage,
                                        )
                                      ]
                                    ),
                                  ),
                                ]
                              )
                            ),
                            !conversationList[index].readConversation ?
                            Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.only(left: 5, right: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle
                              )
                            ): Container()
                          ]
                        )
                      ),
                    )
                  )
                );
              },
            ):
            Center(child: Text("No Messages"))
          ],
        ),
      ),
    );
  }

  buildUsersList() {
    return new ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: newMessageUsers.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return filter == null || filter == "" ? new Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    buildSmallUserProfilePicture(context, newMessageUsers[index].user.profilePicture, newMessageUsers[index].user.username),
                    Padding(padding: EdgeInsets.all(5)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newMessageUsers[index].user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          )
                        ),
                        Text(newMessageUsers[index].user.username)
                      ]
                    )
                  ],
                ),
                new CircularCheckBox(
                  activeColor: Colors.blue,
                  value: newMessageUsers[index].selected,
                  onChanged: (bool value) {
                    setState(() {
                      newMessageUsers.forEach((element) => element.selected = false);
                      newMessageUsers[index].selected = !newMessageUsers[index].selected;
                    });
                  }
                ),
              ]
            )
          )
        ) : searchFilterText(newMessageUsers[index].user) ? 
        new Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    buildSmallUserProfilePicture(context, newMessageUsers[index].user.profilePicture, newMessageUsers[index].user.username),
                    Padding(padding: EdgeInsets.all(5)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newMessageUsers[index].user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          )
                        ),
                        Text(newMessageUsers[index].user.username)
                      ]
                    )
                  ],
                ),
                new CircularCheckBox(
                  activeColor: Colors.blue,
                  value: newMessageUsers[index].selected,
                  onChanged: (bool value) {
                    setState(() {
                      newMessageUsers.forEach((element) => element.selected = false);
                      newMessageUsers[index].selected = !newMessageUsers[index].selected;
                    });
                  }
                ),
              ]
            )
          )
        ) : Container();
      },
    );
  }

  buildNewMessageBody() {
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            color: globals.darkModeEnabled ? darkBackgroundGrey : Color.fromARGB(255, 232, 232, 232),
            borderRadius: BorderRadius.circular(50.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchRecipientsTFController,
            keyboardType: TextInputType.text,
            autocorrect: false,
            style: TextStyle(
              color: globals.darkModeEnabled ? Colors.white : Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: UnderlineInputBorder(borderSide: BorderSide.none),
              isDense: true,
              contentPadding: EdgeInsets.only(left: 15, right: 8, top: 8, bottom: 8),
              hintText: 'Search',
              hintStyle: TextStyle(
                color: globals.darkModeEnabled ? Colors.white54 : Colors.black54,
                fontFamily: 'OpenSans',
              ),
            ),
          )
        ),
        buildUsersList()
      ]
    );
  }

  getNewMessageOverlay() {
    var newMessageHeight = 0.0;
    var newMessageOpacity = 0.0;
    switch(_newMessageWidgetStatus) {
      case WidgetStatus.HIDDEN:
        newMessageHeight = newMessagePositionAnimation.value;
        newMessageOpacity = newMessageOpacityAnimation.value;
        newMessageActive = false;
        break;
      case WidgetStatus.VISIBLE:
        newMessageHeight = newMessagePositionAnimation.value;
        newMessageOpacity = newMessageOpacityAnimation.value;
        newMessageActive = true;
        break;
    }
    return new BackdropFilter(
      filter: new ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Container(
        padding: EdgeInsets.only(bottom: 25, left: 10, right: 10),
        width: MediaQuery.of(context).size.width,
        height: newMessageHeight,
        child: new Opacity(
          opacity: newMessageOpacity,
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    child: buildNewMessageBody()
                  ),
                ],
              ),
              newMessageUsers.where((e) => e.selected == true).length > 0 ? Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: globals.darkModeEnabled ? Color.fromARGB(225, 0, 0, 0) : Color.fromARGB(110, 0, 0, 0),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          border: Border.all(
                            color: CustomColors1.mystic.withAlpha(100)
                          )
                        ),
                        child: RippleButton(
                          splashColor: CustomColors1.mystic.withAlpha(100),
                          onPressed: () {
                            User selectedUser = newMessageUsers.firstWhere((e) => e.selected == true).user;

                            var existItem = conversationList.where((e) => e.userId == selectedUser.id);

                            setState(() {
                              newMessageUsers.forEach((element) => element.selected = false);
                            });

                            onTapDownAdd();

                            if(existItem.length > 0) {
                              final messagesController = new MessagesController(conversation: existItem.first);
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => messagesController));
                            }else {
                              final newMessagesController = new NewMessagesController(user: selectedUser);
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => newMessagesController));
                            }

                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                            child: Center(
                              child: Text(
                                "Chat",
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
                )
              ): Container()
            ]
          )
        ),
        color: const Color.fromARGB(255, 0, 0, 0),
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
            "Messages",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
          actions: [
            _newMessageWidgetStatus != WidgetStatus.VISIBLE ? IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(LineIcons.pencil_square),
              onPressed: () {
                onTapDownAdd();
              },
            ) :
            FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () {
                FocusScope.of(context).unfocus();
                onTapDownAdd();
              },
              child: Text("Cancel")
            )
          ],
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
                  getNewMessageOverlay(),
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

class NewMessageUser {
  User user;
  bool selected;

  NewMessageUser(User input) {
    this.user = input;
    this.selected = false;
  }
}