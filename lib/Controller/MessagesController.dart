import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/Conversation.dart';
import 'dart:async';
import 'package:trimmz/Model/TrimmzWebSocket.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class MessagesController extends StatefulWidget {
  final Conversation conversation;
  final StreamController streamController;
  MessagesController({Key key, this.conversation, this.streamController}) : super (key: key);

  @override
  MessagesControllerState createState() => new MessagesControllerState();
}

class MessagesControllerState extends State<MessagesController> with TickerProviderStateMixin {
  final TextEditingController messageTFController = new TextEditingController();
  Conversation conversation;
  bool _visible = false;
  List<MessageBubble> messageWidgets = [];
  List<Message> messages = [];
  TrimmzWebSocket webSocket = new TrimmzWebSocket();

  @override
  void initState() {
    conversation = widget.conversation;
    widget.conversation.messages.forEach((element) {messages.add(element);});

    for (var message in messages) {
      String msgText = message.message;
      String msgSender = message.senderId == globals.user.token ? globals.user.username : conversation.username;
      String currentUser = globals.user.username;

      MessageBubble msgBubble = MessageBubble(
        msgText: msgText,
        msgSender: msgSender,
        user: currentUser == msgSender
      );
      messageWidgets.add(msgBubble);
    }

    webSocket.channel.stream.listen((event) {
      webSocketAddMessage(event);
    }, onDone: webSocketReconnect);

    messageTFController.addListener(() {
      if(messageTFController.text != "") {
        setState(() {
          _visible = true;
        });
      }
      if(messageTFController.text == "") {
        _visible = false;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    webSocket.channel.sink.close(status.goingAway);
    super.dispose();
  }

  wserror(err) async {
    await webSocketReconnect();
  }

  webSocketReconnect() async {
    if(this.mounted) {
      setState(() {
        webSocket = new TrimmzWebSocket();
      });
      webSocket.channel.stream.listen((event) async {
        webSocketAddMessage(event);
      }, onDone: webSocketReconnect);
    }
  }

  void webSocketAddMessage(var event) async {
    var jsonData = json.decode(event);
    var data = jsonData['data'];
    if(data['conversationId'] == conversation.id) {
      Map messageJson = {
        "id": data['id'],
        "conversationId": data['conversationId'],
        "message": data['message'],
        "senderId": data['senderId'],
        "created": data['created']
      };
      Message message = new Message(messageJson);
      setState(() {
        messages.insert(0, message);
      });
    }
  }

  sendMessage() {
    var data = {
      "action": "onaction",
      "key": "sendMessage",
      "token": conversation.userId,
      "senderId": globals.user.token,
      "conversationId": conversation.id,
      "message": messageTFController.text,
      "created": DateTime.now().toString()
    };
    webSocket.channel.sink.add(json.encode(data));
    messageTFController.clear();
  }

  Widget _buildScreen() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                String msgSender = messages[index].senderId == globals.user.token ? globals.user.username : conversation.username;
                return new MessageBubble(
                  msgText: messages[index].message,
                  msgSender: messages[index].senderId == globals.user.token ? globals.user.username : conversation.username,
                  user: globals.user.username == msgSender
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      color: globals.darkModeEnabled ? darkBackgroundGrey : Color.fromARGB(255, 232, 232, 232),
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: messageTFController,
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
                  )
                ),
                FlatButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(0.0),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if(_visible) {
                      sendMessage();
                    }
                  },
                  child: Text(
                    "Send",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                      color: _visible ? Colors.blue : Colors.grey
                    )
                  )
                )
              ]
            )
          )
        ]
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
            "${conversation.username}",
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
                ]
              )
            )
          )
        )
      )
    );
  }
}

// class ChatStream extends StatefulWidget {
//   final List<Message> messages;
//   ChatStream({@required this.messages});

//   @override
//   _ChatStream createState() => _ChatStream();
// }

// class _ChatStream extends State<ChatStream> {


//   @override
//   Widget build(BuildContext context) {

//     List<MessageBubble> messageWidgets = [];
//     for (var message in widget.messages) {
//       final msgText = message.message;
//       final msgSender = message.senderId == globals.user.token ? globals.user.username : "TESTING";
//       final currentUser = globals.user.username;

//       final msgBubble = MessageBubble(
//         msgText: msgText,
//         msgSender: msgSender,
//         user: currentUser == msgSender
//       );
//       messageWidgets.insert(0, msgBubble);
//     }

//     return Expanded(
//       child: ListView(
//         reverse: true,
//         padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
//         children: messageWidgets,
//       ),
//     );
//   }
// }

class MessageBubble extends StatefulWidget {
  final String msgText;
  final String msgSender;
  final bool user;
  MessageBubble({@required this.msgText, @required this.msgSender, @required this.user});

  @override
  _MessageBubble createState() => _MessageBubble();
}


class _MessageBubble extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment:
            widget.user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 10),
          //   child: Text(
          //     msgSender,
          //     style: TextStyle(
          //         fontSize: 13, fontFamily: 'Poppins', color: globals.darkModeEnabled ? Colors.white : Colors.black),
          //   ),
          // ),

          // Material(
          //   borderRadius: BorderRadius.only(
          //     bottomLeft: Radius.circular(50),
          //     topLeft: widget.user ? Radius.circular(50) : Radius.circular(0),
          //     bottomRight: Radius.circular(50),
          //     topRight: widget.user ? Radius.circular(0) : Radius.circular(50),
          //   ),
          //   color: widget.user ? Colors.blue : Colors.white,
          //   elevation: 5,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          //     child: Text(
          //       widget.msgText,
          //       style: TextStyle(
          //         color: widget.user ? Colors.white : Colors.black,
          //         fontFamily: 'Poppins',
          //         fontSize: 15,
          //       ),
          //     ),
          //   ),
          // ),

          Container(
            decoration: widget.user ?
            BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                topLeft: widget.user ? Radius.circular(50) : Radius.circular(0),
                bottomRight: Radius.circular(50),
                topRight: widget.user ? Radius.circular(0) : Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: globals.darkModeEnabled ? Colors.black : Colors.grey[400],
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(2.0, 2.0),
                )
              ],
            ) :
            BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                topLeft: widget.user ? Radius.circular(50) : Radius.circular(0),
                bottomRight: Radius.circular(50),
                topRight: widget.user ? Radius.circular(0) : Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: globals.darkModeEnabled ? Colors.black : Colors.grey[400],
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(2.0, 2.0),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                widget.msgText,
                style: TextStyle(
                  color: widget.user ? Colors.white : Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}