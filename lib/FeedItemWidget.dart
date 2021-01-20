import 'package:flutter/material.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/Model/FeedItem.dart';
import 'package:trimmz/globals.dart' as globals;

class FeedItemWidget extends StatefulWidget {
  final FeedItem item;
  FeedItemWidget({this.item});

  @override
  _FeedItemWidget createState() => _FeedItemWidget();
}

class _FeedItemWidget extends State<FeedItemWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                buildSmallUserProfilePicture(context, widget.item.profilePicture, widget.item.name),
                Padding(padding: EdgeInsets.all(5)),
                Text(
                  widget.item.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w500
                  ),
                )
              ]
            )
          ),
          ClipRRect(
            // borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              "${globals.baseImageUrl}${widget.item.url}",
              fit: BoxFit.cover,
            ),
          ),
        ]
      )
    );
  }
}