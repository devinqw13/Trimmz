import 'package:flutter/material.dart';
import 'package:trimmz/SizeConfig.dart';

const kTextColor = const Color(0xff121212);
const kLightGreyText = const Color.fromARGB(255, 119, 119, 119);
final Color backgroundGrey = const Color.fromARGB(255, 238, 238, 243);
final Color darkBackgroundGrey = const Color(0xff121212);
final Color lightBackgroundBlue = const Color.fromRGBO(241, 246, 252, 1);
final Color altLightBackgroundBlue = const Color.fromRGBO(218, 227, 242, 1);
const Color primaryBlue = const Color.fromRGBO(61, 68, 130, 1);

const Color iconDarkGrey = const Color.fromRGBO(145, 149, 154, 1);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

final RegExp emailValidatorRegExp = RegExp(r"^[a-zA-Z0-9.+]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email or username";
const String kInvalidEmailError = "Please Enter Valid Email or Username";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNameNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";