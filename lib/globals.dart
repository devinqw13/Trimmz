import 'package:flutter/material.dart';

String baseUrl = "";
int token;
String username;
String name;
String email;
bool userAdmin;
int userType;

LoginUser user;

Color userColor;
Brightness userBrightness;
bool darkModeEnabled;
Color textColor = darkModeEnabled ? Colors.white : Colors.black;
Color textColorAlt = darkModeEnabled ? Colors.black : Colors.white;

class LoginUser {
  int token;
  String username;
  String name;
  String userEmail;
  bool userAdmin;
  int userType;
}