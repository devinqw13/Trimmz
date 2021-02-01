import 'package:flutter/material.dart';
import 'package:trimmz/Controller/UserController.dart';

LoginUser user;
StripeUser stripe;
String strpk;

String baseUrl = "";
String baseImageUrl = "";

String stripeUrl = "";
String stripeSecretKey = "";
String stripePublishablekey = "";
String stripeMerchantId = "";

Brightness userBrightness;
bool darkModeEnabled;

UserControllerState userControllerState;

double processingFee;
double standardPayoutFee;
double instantPayoutFee;

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
  PaymentMethod payoutMethod;
  String paymentMethodType;
  String payoutId;
  String accountId;
  String paymentId;
}

class PaymentMethod {
  String id;
  String brand;
  String last4;
  String fingerPrint;

  PaymentMethod(Map input) {
    this.id = input['id'];
    this.brand = input['brand'];
    this.last4 = input['last4'];
    this.fingerPrint = input['fingerprint'];
  }
}