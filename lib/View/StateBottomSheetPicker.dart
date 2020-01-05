import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../states.dart' as states;

class StateBottomSheet extends StatefulWidget {
  StateBottomSheet({@required this.valueChanged, @required this.value});
  final int value;
  final ValueChanged valueChanged;

  @override
  _StateBottomSheet createState() => _StateBottomSheet();
}

class _StateBottomSheet extends State<StateBottomSheet> {
  int value;

  @override
  void initState() {
    setState(() {
      value = widget.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController = new FixedExtentScrollController(initialItem: value == null ? 0 : value);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 255,
        margin: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2, color: Colors.grey[300], spreadRadius: 0
            )
          ]
        ),
        child: Column(
          children: <Widget> [
            Container(
              height: 235,
              child: CupertinoPicker(
                useMagnifier: true,
                magnification: 0.2,
                squeeze: 5,
                backgroundColor: Colors.transparent,
                scrollController: scrollController,
                itemExtent: 235,
                onSelectedItemChanged: (value) {
                  setState(() {
                    widget.valueChanged(value);
                  });
                },
                children: new List<Widget>.generate(states.states.length, (int index){
                  return new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      Center(
                        child: Text(
                          states.states[index],
                          style: TextStyle(color: Colors.white)
                        )
                      )
                    ]
                  );
                }),
              )
            )
          ]
        )
      )
    );
  }
}