import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

String baseUrl = "";
int token;
String username;
String name;
String email;
bool userAdmin;
int userType;
String sqccof;
String spCustomerId;
String payoutMethod;
String payoutCard;
Position currentLocation;

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
  String ccof;
  String spCustomerId;
  String payoutMethod;
  String payoutCard;
}