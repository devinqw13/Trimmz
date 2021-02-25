import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/helpers.dart';
import 'package:trimmz/palette.dart';
import 'package:trimmz/Model/Conversation.dart';
import 'dart:async';
import 'package:trimmz/Model/TrimmzWebSocket.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:trimmz/Model/User.dart';

class NewMessagesController extends StatefulWidget {
  final User user;
  NewMessagesController({Key key, this.user}) : super (key: key);

  @override
  NewMessagesControllerState createState() => new NewMessagesControllerState();
}

class NewMessagesControllerState extends State<NewMessagesController> with TickerProviderStateMixin {
  final TextEditingController messageTFController = new TextEditingController();
  Conversation conversation;
  bool _visible = false;
  List<MessageBubble> messageWidgets = [];
  List<Message> messages = [];
  TrimmzWebSocket webSocket;

  @override
  void initState() {
    webSocket = new TrimmzWebSocket("Messages", null);

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
        webSocket = new TrimmzWebSocket("Messages", conversation != null ? conversation.id : null);
      });
      webSocket.channel.stream.listen((event) async {
        webSocketAddMessage(event);
      }, onDone: webSocketReconnect);
    }
  }

  void webSocketAddMessage(var event) async {
    var jsonData = json.decode(event);

    if(conversation == null) {
      var result = await onWebSocketAction(jsonData['key'], jsonData['data'], other: List<Conversation>());
      setState(() {
        conversation = result[0];
      });
    }

    if(jsonData['key'] == "newConversation") {
      if(jsonData['data']['conversation']['id'] == conversation.id) {
        Map messageJson = {
          "id": jsonData['data']['message'][0]['id'],
          "conversationId": jsonData['data']['message'][0]['conversationId'],
          "message": jsonData['data']['message'][0]['message'],
          "senderId": jsonData['data']['message'][0]['senderId'],
          "created": jsonData['data']['message'][0]['created']
        };
        Message message = new Message(messageJson);
        setState(() {
          messages.insert(0, message);
        });
      }
    }else {
      Map messageJson = {
        "id": jsonData['data']['id'],
        "conversationId": jsonData['data']['conversationId'],
        "message": jsonData['data']['message'],
        "senderId": jsonData['data']['senderId'],
        "created": jsonData['data']['created']
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
      "recipientUsername": conversation.username,
      "senderId": globals.user.token,
      "conversationId": conversation.id,
      "message": messageTFController.text,
      "created": DateTime.now().toString()
    };
    webSocket.channel.sink.add(json.encode(data));
    messageTFController.clear();
  }

  createConversation() {
    var data = {
      "action": "onaction",
      "key": "createConversation",
      "recipientUsername": widget.user.username,
      "recipientName": widget.user.name,
      "profile_picture": widget.user.profilePicture,
      "senderid": globals.user.token.toString(),
      "recipientid": widget.user.id.toString(),
      "message": messageTFController.text,
      "created": DateTime.now().toString()
    };

    if(globals.user.userType == 2) {
      data['userid'] = globals.user.token.toString();
      data['clientid'] = widget.user.id.toString();
    }else {
      data['clientid'] = globals.user.token.toString();
      data['userid'] = widget.user.id.toString();
    }

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
                  conversation: conversation,
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
                      if(conversation != null) {
                        sendMessage();
                      }else {
                        createConversation();
                      }
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSmallUserProfilePicture(context, widget.user.profilePicture, widget.user.username),
              Padding(padding: EdgeInsets.all(5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.user.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0
                    ),
                  ),
                  Text(
                    "@${widget.user.username}",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      fontSize: 13.0
                    ),
                  ),
                ]
              )
            ]
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
  final Conversation conversation;
  final String msgText;
  final String msgSender;
  final bool user;
  MessageBubble({@required this.conversation, @required this.msgText, @required this.msgSender, @required this.user});

  @override
  _MessageBubble createState() => _MessageBubble();
}


class _MessageBubble extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 0.0, right: 0.0),
      child: Column(
        crossAxisAlignment: widget.user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: widget.user ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              !widget.user ? Container(
                padding: EdgeInsets.only(right: 5.0),
                child: buildSmallUserProfilePicture(context, widget.conversation.profilePicture, widget.conversation.username)
              ):
              Container(),
              Flexible(
                child: Container(
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
              )
            ],
          )
          // Container(
          //   decoration: widget.user ?
          //   BoxDecoration(
          //     gradient: primaryGradient,
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(50),
          //       topLeft: widget.user ? Radius.circular(50) : Radius.circular(0),
          //       bottomRight: Radius.circular(50),
          //       topRight: widget.user ? Radius.circular(0) : Radius.circular(50),
          //     ),
          //     boxShadow: [
          //       BoxShadow(
          //         color: globals.darkModeEnabled ? Colors.black : Colors.grey[400],
          //         blurRadius: 2.0,
          //         spreadRadius: 0.0,
          //         offset: Offset(2.0, 2.0),
          //       )
          //     ],
          //   ) :
          //   BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(50),
          //       topLeft: widget.user ? Radius.circular(50) : Radius.circular(0),
          //       bottomRight: Radius.circular(50),
          //       topRight: widget.user ? Radius.circular(0) : Radius.circular(50),
          //     ),
          //     boxShadow: [
          //       BoxShadow(
          //         color: globals.darkModeEnabled ? Colors.black : Colors.grey[400],
          //         blurRadius: 2.0,
          //         spreadRadius: 0.0,
          //         offset: Offset(2.0, 2.0),
          //       )
          //     ],
          //   ),
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
          // )
        ],
      ),
    );
  }
}