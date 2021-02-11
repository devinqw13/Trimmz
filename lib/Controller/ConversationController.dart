import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:progress_hud/progress_hud.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/Conversation.dart';
import 'package:trimmz/Controller/MessagesController.dart';
import 'package:trimmz/Model/TrimmzWebSocket.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class ConversationController extends StatefulWidget {
  final List<Conversation> cachedConversations;
  ConversationController({Key key, this.cachedConversations}) : super (key: key);

  @override
  ConversationControllerState createState() => new ConversationControllerState();
}

class ConversationControllerState extends State<ConversationController> with TickerProviderStateMixin {
  ProgressHUD _progressHUD;
  bool _loadingInProgress = false;
  List<Conversation> conversationList = [];
  TrimmzWebSocket webSocket = new TrimmzWebSocket("Conversation", 0);

  @override
  void initState() {
    webSocket.channel.stream.listen((event) async {
      webSocketAddMessage(event);
    }, onDone: webSocketReconnect);

    conversationList = widget.cachedConversations ?? [];

    _progressHUD = new ProgressHUD(
      color: Colors.white,
      borderRadius: 8.0,
      loading: false,
      text: 'Loading...'
    );

    initGetConversations();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    webSocket.channel.sink.close(status.goingAway);
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
    results.sort((a,b) => a.created.compareTo(b.created));
    setState(() {
      conversationList = results;
    });
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
            ListView.builder(
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
            )
          ],
        ),
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
            "Messages",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0
            ),
          ),
          elevation: 0.0,
          actions: [
            IconButton(
              icon: Icon(Icons.drive_file_rename_outline),
              onPressed: () {

              },
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