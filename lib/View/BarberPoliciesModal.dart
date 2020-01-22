import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Model/BarberPolicies.dart';
import '../globals.dart' as globals;
import '../calls.dart';

class BarberPoliciesModal extends StatefulWidget {
  BarberPoliciesModal({@required this.policies, this.updatePolicies,});
  final BarberPolicies policies;
  final ValueChanged updatePolicies;

  @override
  _BarberPoliciesModal createState() => _BarberPoliciesModal();
}

class _BarberPoliciesModal extends State<BarberPoliciesModal> {
  BarberPolicies policies;

  @override
  void initState() {
    setState(() {
      policies = widget.policies;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(10.0),
        height: 415,
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
                Container()
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FlatButton(
                      color: Colors.blue,
                      onPressed: () async {
                        Navigator.pop(context);
                        //widget.updatePolicies(true);
                      },
                      child: Text('Cancel')
                    )
                  )
                )
              ]
            )
          ]
        ),
      )
    );
  }
}