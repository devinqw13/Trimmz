import 'package:flutter/material.dart';
import 'package:trimmz/Constants.dart';
import 'package:trimmz/SizeConfig.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key key,
    this.text,
    this.onPressed,
    this.buttonColor = primaryBlue,
    this.textColor = Colors.white,
    this.textStyle
  }) : super(key: key);

  final String text;
  final Function onPressed;
  final Color buttonColor;
  final Color textColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(50),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        color: buttonColor,
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle
        ),
      ),
    );
  }
}