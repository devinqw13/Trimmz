import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> showCustomDialog({
  @required BuildContext context, 
  @required String title,
  @required String description, 
  @required TextAlign descAlignment, 
  @required Map<String, dynamic> buttons
}) async {
  var response = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialogBox(
        title: title,
        description: description,
        descAlignment: descAlignment,
        buttons: buttons,
      );
    }
  );
  return response;
}

class Constants{
  Constants._();
  static const double padding = 20;
  static const double avatarRadius = 45;
}

class CustomDialogBox extends StatefulWidget {
  final String title;
  final String description;
  final TextAlign descAlignment;
  final Map<String, dynamic> buttons;

  CustomDialogBox({
    @required this.title,
    @required this.description,
    @required this.descAlignment,
    @required this.buttons
  });

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding)
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.padding
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          // margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: [
              BoxShadow(color: Colors.black,offset: Offset(0,10),
              blurRadius: 10
              ),
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(widget.title, textAlign: TextAlign.center, style: TextStyle(color:Colors.black, fontSize: 22,fontWeight: FontWeight.w600)),
              SizedBox(height: 15,),
              Flexible(child: SingleChildScrollView(child: Text(widget.description,style: TextStyle(color: Colors.black, fontSize: 14),textAlign: widget.descAlignment))),
              SizedBox(height: 22,),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buildButtons()
              )
            ],
          ),
        ),
      ],
    );
  }

  buildButtons() {
    List<Widget> buttons = [];
    widget.buttons.forEach((k,v) {
      buttons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: MaterialButton(
              onPressed: v['action'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: v['color'],
              child: Text(k,
                style: TextStyle(color: v['textColor'])
              ),
            ),
          ),
        )
      );
    });
    return buttons;
  }
}