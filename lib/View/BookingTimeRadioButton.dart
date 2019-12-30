import 'package:flutter/material.dart';

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(5.0),
      margin: new EdgeInsets.all(5.0),
      child: new Center(
        child: new Text(_item.buttonText,
          style: new TextStyle(
            color: Colors.white,//_item.isSelected ? Colors.white : Colors.black,
            fontSize: 16.0
          )
        ),
      ),
      decoration: new BoxDecoration(
        color: _item.isSelected ? Colors.blueAccent : Colors.grey[700],
        border: new Border.all(
          width: 1.0,
          color: _item.isSelected ? Colors.blueAccent : Colors.grey[700]),
        borderRadius: const BorderRadius.all(const Radius.circular(5.0)),
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  RadioModel(this.isSelected, this.buttonText);
}