import 'package:flutter/material.dart';

final darkGrey = const Color.fromARGB(255, 66, 66, 66);
final mediumGrey = const Color.fromARGB(255, 128, 128, 128);
final lightGrey = const Color.fromARGB(255, 168, 168, 168);
final pureWhite = const Color.fromARGB(255, 255, 255, 255);
final mainPurple = const Color.fromARGB(255, 132, 91, 132);
final menuPurple = const Color.fromARGB(255, 171, 135, 171);
final lightBackgroundGrey = const Color.fromARGB(255, 242, 242, 242);
final lightBackgroundWhite = const Color.fromARGB(255, 255, 255, 255);
final buttonGrey = const Color.fromARGB(255, 224, 224, 224);
final darkBackgroundGrey = const Color.fromARGB(255, 42, 42, 42);
final mediumBackgroundGrey = const Color.fromARGB(255, 47, 47, 47);

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