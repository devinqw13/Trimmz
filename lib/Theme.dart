import 'package:flutter/material.dart';
import 'package:trimmz/Constants.dart';

ThemeData theme() {
  return ThemeData(
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: lightBackgroundBlue,
    textTheme: textTheme(),
    appBarTheme: appBarTheme(),
    // inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

// InputDecorationTheme inputDecorationTheme() {
//   OutlineInputBorder outlineInputBorder = OutlineInputBorder(
//     borderRadius: BorderRadius.circular(28),
//     borderSide: BorderSide(color: kTextColor),
//     gapPadding: 10
//   );
//   return InputDecorationTheme(
//     errorStyle: TextStyle(height: 0),
//     floatingLabelBehavior: FloatingLabelBehavior.never,
//     contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
//     enabledBorder: outlineInputBorder,
//     focusedBorder: outlineInputBorder,
//     border: outlineInputBorder
//   );
// }

TextTheme textTheme() {
  return TextTheme(
    bodyText1: TextStyle(color: kTextColor),
    bodyText2: TextStyle(color: kTextColor)
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    elevation: 0,
    brightness: Brightness.light,
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline6: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ),
  );
}