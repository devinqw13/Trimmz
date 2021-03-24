import 'package:flutter/material.dart';
import 'package:trimmz/Controller/ClientAppointmentsController.dart';
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

ClientAppointmentsControllerState clientAppointmentsControllerState;

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
  StripePaymentMethod payoutMethod;
  String paymentMethodType;
  String payoutId;
  String accountId;
  String paymentId;
}

class StripePaymentMethod {
  String id;
  String brand;
  String last4;
  String fingerPrint;
  Widget brandIcon;

  StripePaymentMethod(Map input) {
    this.id = input['id'];
    this.brand = input['brand'];
    this.last4 = input['last4'];
    this.fingerPrint = input['fingerprint'];

    if(input['brand'] == 'visa') {
      this.brandIcon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/visa1.png'),fit: BoxFit.cover),height: 17));
    }else if(input['brand'] == 'discover'){
      this.brandIcon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/discover1.png'),fit: BoxFit.cover),height: 17));
    }else if(input['brand'] == 'amex'){
      this.brandIcon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/amex1.png'),fit: BoxFit.cover),height: 17));
    }else if(input['brand'] == 'mastercard'){
      this.brandIcon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/mastercard1.png'),fit: BoxFit.cover),height: 17));
    }
  }
}