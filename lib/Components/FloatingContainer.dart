import 'package:flutter/material.dart';
import 'package:trimmz/Constants.dart';
import 'package:trimmz/SizeConfig.dart';

class FloatingContainer extends StatelessWidget {
  const FloatingContainer({
    Key key,
    this.child,
    this.backgroundColor = Colors.white,
    this.shadowColor,
    this.spreadRadius = 1.0,
    this.blurRadius = 7.0,
    this.offsetX = 0.0,
    this.offsetY = 2.0,
    this.borderRadius,
    this.padding
  }) : super(key: key);

  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final double spreadRadius;
  final double blurRadius;
  final double offsetX;
  final double offsetY;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: shadowColor == null ? Colors.grey.withOpacity(0.5) : shadowColor,
              spreadRadius: spreadRadius,
              blurRadius: blurRadius,
              offset: Offset(offsetX, offsetY),
            ),
          ],
        ),
        child: child
      ),
    );
  }
}