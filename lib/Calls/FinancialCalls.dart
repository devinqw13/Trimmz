import 'package:http/http.dart' as http;
import '../dialogs.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'StripeConfig.dart';
import '../Model/ClientPaymentMethod.dart';

Future<Map> spGetClientPaymentMethod(BuildContext context, String customerId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer $stripeSecretKey', 
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${stripeURL}customers/$customerId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (023)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  print(response.body);
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (023)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  return jsonResponse;
}