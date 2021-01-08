import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;

final darkGrey = const Color.fromARGB(255, 66, 66, 66);
final mediumGrey = const Color.fromARGB(255, 128, 128, 128);
final lightGrey = const Color.fromARGB(255, 168, 168, 168);
final pureWhite = const Color.fromARGB(255, 255, 255, 255);
final mainPurple = const Color.fromARGB(255, 132, 91, 132);
final menuPurple = const Color.fromARGB(255, 171, 135, 171);
final lightBackgroundGrey = const Color.fromARGB(255, 242, 242, 242);
final buttonGrey = const Color.fromARGB(255, 224, 224, 224);
final darkBackgroundGrey = const Color.fromARGB(255, 42, 42, 42);
final textGrey = globals.darkModeEnabled ? Colors.grey : Color.fromARGB(255, 80, 80, 80);
final richBlack = const Color(0xff010203);
final defaultDarkGrey = const Color.fromARGB(255, 48, 48, 48);
final keyboardGrey = const Color.fromARGB(255, 209, 212, 217);
final underlineGrey = const Color.fromARGB(255, 235, 235, 235);
final primaryColor = const Color(0xFF206f98); //0xFF03A9F4

final defaultButtonColor = const Color.fromARGB(255, 52, 152, 219);
final blueButtonColor = const Color.fromARGB(255, 123, 167, 207);
final redButtonColor = const Color.fromARGB(255, 239, 167, 84);

Color colorFromName(String name) {
  switch (name) {
    case 'main':
      return defaultButtonColor;
    case 'secondary':
      return blueButtonColor;
    case 'red':
      return redButtonColor;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    default:
      return darkGrey;
  }
}

class TwitterColor {
  static final Color bondiBlue = Color.fromRGBO(0, 132, 180, 1.0);
  static final Color cerulean = Color.fromRGBO(0, 172, 237, 1.0);
  static final Color spindle = Color.fromRGBO(192, 222, 237, 1.0);
  static final Color white = Color.fromRGBO(255, 255, 255, 1.0);
  static final Color black = Color.fromRGBO(0, 0, 0, 1.0);
  static final Color woodsmoke = Color.fromRGBO(20, 23, 2, 1.0);
  static final Color woodsmoke_50 = Color.fromRGBO(20, 23, 2, 0.5);
  static final Color mystic = Color.fromRGBO(230, 236, 240, 1.0);
  static final Color dodgetBlue = Color.fromRGBO(29, 162, 240, 1.0);
  static final Color dodgetBlue_50 = Color.fromRGBO(29, 162, 240, 0.5);
  static final Color paleSky = Color.fromRGBO(101, 119, 133, 1.0);
  static final Color ceriseRed = Color.fromRGBO(224, 36, 94, 1.0);
  static final Color paleSky50 = Color.fromRGBO(101, 118, 133, 0.5);
}