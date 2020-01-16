import 'package:http/http.dart' as http;
import '../dialogs.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'StripeConfig.dart';
import '../Model/ClientPaymentMethod.dart';
import '../globals.dart' as globals;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<dynamic> spGetClientPaymentMethod(BuildContext context, String customerId, int type) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer $stripeSecretKey', 
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${stripeURL}payment_methods?customer=$customerId&type=card";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P00)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P00)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  print(jsonResponse);
  if(!jsonResponse.containsKey('error')) {
    if(type == 1) {
      ClientPaymentMethod paymentMethod = new ClientPaymentMethod();
      paymentMethod.id = jsonResponse['data'][0]['id'];
      paymentMethod.brand = jsonResponse['data'][0]['card']['brand'];
      paymentMethod.lastFour = jsonResponse['data'][0]['card']['last4'];
      paymentMethod.fingerprint = jsonResponse['data'][0]['card']['fingerprint'];

      if(paymentMethod.brand == 'visa') {
        paymentMethod.icon = Icon(FontAwesomeIcons.ccVisa, color: Colors.blue);
      }else if(paymentMethod.brand == 'discover'){
        paymentMethod.icon = Icon(FontAwesomeIcons.ccDiscover, color: Colors.orange);
      }else if(paymentMethod.brand == 'amex'){
        paymentMethod.icon = Icon(FontAwesomeIcons.ccAmex);
      }else if(paymentMethod.brand == 'mastercard'){
        paymentMethod.icon = Icon(FontAwesomeIcons.ccMastercard);
      }else if(paymentMethod.brand == 'stripe'){
        paymentMethod.icon = Icon(FontAwesomeIcons.ccStripe);
      }else if(paymentMethod.brand == 'apple pay'){
        paymentMethod.icon = Icon(FontAwesomeIcons.ccApplePay);
      }





      return paymentMethod;
    }
  }else {
    return {};
  }
}

Future<Map> spCreateCustomer(BuildContext context, String paymentId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer $stripeSecretKey', 
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "name": "${globals.username}",
    "email": "${globals.email}",
    "description": "${globals.token}",
    "payment_method": "$paymentId"
  };

  String url = "${stripeURL}customers";

  try {
    response = await http.post(url, body: jsonMap, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P01)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P01)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(!jsonResponse.containsKey('error')) {
    return jsonResponse;
  }else {
    return {};
  }
}

Future<Map> spCreatePaymentIntent(BuildContext context, String paymentId, String customerId, String amount) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer $stripeSecretKey', 
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "amount": "$amount",
    "currency": "USD",
    "confirm": "true",
    "customer": "$customerId",
    "payment_method": "$paymentId"
  };

  String url = "${stripeURL}payment_intents";

  try {
    response = await http.post(url, body: jsonMap, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P02)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P02)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(!jsonResponse.containsKey('error')) {
    return jsonResponse;
  }else {
    return {};
  }
}

Future<Map> spDetachCustomerFromPM(BuildContext context, String paymentId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer $stripeSecretKey', 
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${stripeURL}payment_methods/$paymentId/detach";

  try {
    response = await http.post(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P01)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P01)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(!jsonResponse.containsKey('error')) {
    return jsonResponse;
  }else {
    return {};
  }
}

Future<Map> spAttachCustomerToPM(BuildContext context, String paymentId, String customerId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer $stripeSecretKey', 
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "customer": "$customerId"
  };

  String url = "${stripeURL}payment_methods/$paymentId/attach";

  try {
    response = await http.post(url, body: jsonMap, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P01)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P01)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(!jsonResponse.containsKey('error')) {
    return jsonResponse;
  }else {
    return {};
  }
}