import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import 'globals.dart' as globals;
import 'Model/Packages.dart';

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

Future<List<Packages>> showPkgsOpts(BuildContext context, String name, String price, String duration, String packageid) async {
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController priceController = new TextEditingController();
  final TextEditingController durationController = new TextEditingController();
  List<Packages> results;
  await showDialog(
    context: context,
    builder: (context) => new AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      title: new Center(child: Text(name,
        style: TextStyle(fontSize: 19.0),)),
        content: new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text('Name'),
            new TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: name
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
            ),
            new Text('Price'),
            new TextField(
              controller: priceController,
              decoration: InputDecoration(
                hintText: price
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
            ),
            new Text('Duration (mins)'),
            new TextField(
              controller: durationController,
              decoration: InputDecoration(
                hintText: duration
              ),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
            ),
            new Center (
              child: GestureDetector(
                onTap: () async {
                  bool res = await removePackage(context, globals.token, int.parse(packageid));
                  if(res) {
                    var res = await getBarberPkgs(context, globals.token);
                    Navigator.pop(context);
                    results = res;
                  }else {
                    return;
                  }
                },
                child: Text('Remove Package', style: TextStyle(color: Colors.red))
              )
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
            ),
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new RaisedButton(
                    color: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: new Text("Save",
                    textAlign: TextAlign.center),
                    onPressed: () { 
                      
                    },
                  )
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                ),
                new Expanded(
                  child: new RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: new Text("Cancel",
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
  return results;
}