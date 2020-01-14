import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../dialogs.dart';
import 'dart:convert';
import '../globals.dart' as globals;
import 'package:uuid/uuid.dart';

const String squareApplicationId = "sq0idp-Jv5ExH1mQJRgV7W1n-TF_A";
const String squareLocationId = "MMN2THEHY2CM3";
const String squareAccessToken = "EAAAEE2Js57vAMoQQD4aiQmGvy-Kwm-LfxO5Ag_xHL36WlZhLL_1JZgJYUMBvFwq";
const String applePayMerchantId = "REPLACE_ME";
const String squareURL = "https://connect.squareup.com";

Future<List> getCustomerTS(BuildContext context) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Authorization' : 'Bearer $squareAccessToken', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "$squareURL/v2/customers";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (005)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (005)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  return jsonResponse['customers'];
}

Future<Map> createCustomerTS(BuildContext context) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Authorization' : 'Bearer $squareAccessToken', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "given_name" : "${globals.username}",
    "reference_id" : "${globals.token}"
  };

  String url = "$squareURL/v2/customers";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (006)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (006)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  return jsonResponse['customer'];
}

Future<Map> createCustomerCardTS(BuildContext context, String id, String nonce) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Authorization' : 'Bearer $squareAccessToken', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "card_nonce" : "$nonce"
  };

  String url = "$squareURL/v2/customers/$id/cards";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (007)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (007)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse.length > 0) {
    return jsonResponse['card'];
  }else {
    return {};
  }
}

Future<bool> chargeCardTS(BuildContext context, int amount, String nonce) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Authorization' : 'Bearer $squareAccessToken', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var uuid = Uuid().v4();

  var jsonMap = {
    "idempotency_key": "$uuid", 
    "amount_money" : {
      "amount" : amount,
      "currency" : "USD"
    },
    "card_nonce" : "$nonce"
  };

  String url = "$squareURL/v2/locations/$squareLocationId/transactions";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (008)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (008)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  return true;
}

Future<bool> chargeCardV2TS(BuildContext context, int amount, String ccof, String customerId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Authorization' : 'Bearer $squareAccessToken', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var uuid = Uuid().v4();

  var jsonMap = {
    "idempotency_key": "$uuid", 
    "amount_money" : {
      "amount" : amount,
      "currency" : "USD"
    },
    "source_id" : "$ccof",
    "customer_id": "$customerId"
  };

  String url = "$squareURL/v2/payments";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (008)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (008)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  return true;
}