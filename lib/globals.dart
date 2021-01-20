import 'package:flutter/material.dart';
import 'package:trimmz/Controller/UserController.dart';

LoginUser user;
StripeUser stripe;

String baseUrl = "";
String baseImageUrl = "";

String stripeUrl = "";
String stripeSecretKey = "";
String stripePublishablekey = "";
String stripeMerchantId = "";

Brightness userBrightness;
bool darkModeEnabled;

UserControllerState userControllerState;

class LoginUser {
  int token;
  String username;
  String name;
  String userEmail;
  String phone;
  bool userAdmin;
  int userType;
  String shopName;
  String shopAddress;
  String city;
  String state;
  int zipcode;
  String profilePic;
  String headerPicture;
}

class StripeUser {
  String customerId;
  String payoutMethod;
  String payoutId;
  String accountId;
  String paymentId;
}