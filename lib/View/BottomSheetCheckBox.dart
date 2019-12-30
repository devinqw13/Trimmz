import 'package:flutter/material.dart';

class BottomSheetCheckBox extends StatefulWidget {
  BottomSheetCheckBox({@required this.switchValue, @required this.valueChanged});

  final bool switchValue;
  final ValueChanged valueChanged;

  @override
  _BottomSheetCheckBox createState() => _BottomSheetCheckBox();
}

class _BottomSheetCheckBox extends State<BottomSheetCheckBox> {
  bool _switchValue;

  @override
  void initState() {
    _switchValue = widget.switchValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Checkbox(
        activeColor: Colors.blue,
        value: _switchValue,
        onChanged: (bool value) {
          setState(() {
            _switchValue = value;
            widget.valueChanged(value);
          });
        },
      )
    );
  }
}