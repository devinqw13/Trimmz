import 'package:flutter/material.dart';

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

class LoginUser {
  int token;
  String username;
  String name;
  String userEmail;
  bool userAdmin;
  int userType;
  String shopName;
  String shopAddress;
  String city;
  String state;
  int zipcode;
  String profilePic;
}

class StripeUser {
  String customerId;
  String payoutMethod;
  String payoutId;
  String accountId;
  String paymentId;
}