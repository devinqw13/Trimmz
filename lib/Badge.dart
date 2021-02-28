import 'package:flutter/material.dart';

class Badge extends StatefulWidget {
  final Widget widget;
  final int count;
  Badge({this.widget, this.count});

  @override
  _Badge createState() => _Badge();
}

class _Badge extends State<Badge> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Center(
          child: widget.widget,
        ),
        widget.count > 0 ? Positioned(
          top: 5,
          right: -5,
          child: Container(
            padding: EdgeInsets.all(6),
            child: Text(
              widget.count.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12.0
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle
            ),
          ),
        ) : Container()
      ],
    );
  }
}