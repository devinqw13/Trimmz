import 'package:flutter/material.dart';

void showOkDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Text(message,
      textAlign: TextAlign.center,
      style: new TextStyle(
        fontSize: 16.0),
      ),
      content: new Container(
        child: new RaisedButton(
          child: new Text("OK",
          textAlign: TextAlign.center),
          onPressed: () { 
            Navigator.of(context).pop();
          },
        ),
      ),
    )
  );
}

showErrorDialog(BuildContext context, String title, String message) {
  return showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Center(child: Text(title,
        style: TextStyle(fontSize: 19.0),)),
      content: new Container(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(message,
              style: new TextStyle(
                fontSize: 13.0
              ),
              textAlign: TextAlign.left,
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new RaisedButton(
                    child: new Text("OK",
                    textAlign: TextAlign.center),
                    onPressed: () { 
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        )
      ),
    )
  );
}

showMultipleErrorDialog(BuildContext context, String title, List<String> messages, {String other}) {
  return showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      title: new Center(child: Text(title,
        style: TextStyle(fontSize: 19.0),)),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          other != null ? Text(other) : Container(),
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
          ),
          Container(
            height: MediaQuery.of(context).size.height * .09,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                return Text(messages[i], style: TextStyle(color: Color.fromARGB(255, 80, 80, 80)));
              },
            )
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                child: new RaisedButton(
                  child: new Text("OK",
                  textAlign: TextAlign.center),
                  onPressed: () { 
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          )
        ],
      )
    )
  );
}