import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

String baseUrl = "";
String baseUrlImage = "";
int token;
String username;
String name;
String email;
bool userAdmin;
int userType;
String spCustomerId;
String spPayoutMethod;
String spPayoutId;
String spAccountId;
String spPaymentId;
Position currentLocation;
String profilePic;

String shopName;
String shopAddress;
String city;
String state;
String zipcode;

LoginUser user;

Color userColor;
Brightness userBrightness;
bool darkModeEnabled;
Color textColor = darkModeEnabled ? Colors.white : Colors.black;
Color textColorAlt = darkModeEnabled ? Colors.black : Colors.white;

String stripeURL = "";
String stripeSecretKey = "";
String stripePublishablekey = "";
String stripeMerchantId = "";

class LoginUser {
  int token;
  String username;
  String name;
  String userEmail;
  bool userAdmin;
  int userType;
  String spCustomerId;
  String spPayoutMethod;
  String spPayoutId;
  String spAccountId;
  String spPaymentId;
  String shopName;
  String shopAddress;
  String city;
  String state;
  String zipcode;
  String profilePic;
}