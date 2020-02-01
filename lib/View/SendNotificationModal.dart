import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../calls.dart';
import '../globals.dart' as globals;

class SendNotificationModal extends StatefulWidget {
  SendNotificationModal({this.addRecipients, this.recipients, this.success});
  final ValueChanged addRecipients;
  final ValueChanged success;
  final List<Map<dynamic, dynamic>> recipients;

  @override
  _SendNotificationModal createState() => _SendNotificationModal();
}

class _SendNotificationModal extends State<SendNotificationModal> {
  List<Map<dynamic, dynamic>> recipients = [];
  TextEditingController messageController = new TextEditingController();

  void initState() {
    super.initState();
    recipients = widget.recipients ?? [];
  }

  sendMessage(String message) async {
    for(var item in recipients) {
      List tokens = await getNotificationTokens(context, item['id']);
      for(var token in tokens){
        Map<String, dynamic> dataMap =  {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'action': 'BOOK_APPOINTMENT',
          'title': '${globals.username}',
          'body': '$message',
          'sender': '${globals.token}',
          'recipient': '$token',
        };
        await sendPushNotification(context, '${globals.username}', '$message', item['id'], token, dataMap);
      }
    }
    Navigator.pop(context);
    widget.success(true);
  }

  buildRecipients() {
    if(recipients.length == 0) {
      return Container(
        child: FlatButton(
          textColor: Colors.blue,
          child: Text('Add People'),
          onPressed: () {
            Navigator.pop(context);
            widget.addRecipients(recipients);
          },
        ),
      );
    }else {
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
                    child: Text(
                      recipients[i]['username']
                    )
                  )
                );
              },
            )
          ),
          IconButton(
            icon: Icon(LineIcons.plus,color: Colors.blue),
            onPressed: () {
              widget.addRecipients(recipients);
            },
          )
        ]
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 400,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                blurRadius: 2, color: Colors.grey[400], spreadRadius: 0)
          ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
                      buildRecipients()
                    ]
                  )
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        child: TextField(
                          controller: messageController,
                          onChanged: (val) {
                            setState(() {
                              messageController.text = val;
                            });
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: 8,
                          maxLength: 100,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    ],
                  )
                )
              ],
            ),
            Column(
              children: <Widget>[
                (recipients.length > 0 && messageController.text.length > 0) ?
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () async {
                            sendMessage(messageController.text);
                          },
                          child: Text('Send Annoucement')
                        )
                      )
                    )
                  ]
                ) : Container(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FlatButton(
                          color: Colors.blue,
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel')
                        )
                      )
                    )
                  ]
                )
              ]
            )
          ]
        ),
      )
    );
  }
}