import 'package:flutter/material.dart';
import 'package:trimmz/SizeConfig.dart';

class Body extends StatefulWidget {
  final Function dismissProgressHUD;

  Body({
    @required this.dismissProgressHUD
  });

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("HELLO WORLD!")
            ],
          ),
        ),
      ),
    );
  }
}