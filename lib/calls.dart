import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trimmz/globals.dart' as globals;
import 'dart:convert';
import 'package:trimmz/dialogs.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/Model/Appointment.dart';

Future<List<String>> getDeviceDetails() async {
  String deviceName;
  String deviceVersion;
  String deviceIdentifier;
  String deviceType;
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      deviceName = build.model;
      deviceVersion = build.version.toString();
      deviceIdentifier = build.id;
      deviceType = 'Android';
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      deviceName = data.name;
      deviceVersion = data.systemVersion;
      deviceIdentifier = data.identifierForVendor; // UUID for iOS
      deviceType = 'iOS';
    }
  } on Exception {
    print("failed to get platform version");
  }

  return [deviceName, deviceVersion, deviceIdentifier, deviceType];
}

Future<Map> login(BuildContext context, String username, String password) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  http.Response response;
  Map jsonResponse = {};

  Map jsonMap = {
    "username": username,
    "password": password
  };

  String url = '${globals.baseUrl}login/';

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers);
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (001)", "Please try again later.");
    return {};
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (001)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  Map results = jsonResponse;
  return results;
}

Future<Map> existingLogin(int token, [BuildContext context]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  http.Response response;
  Map jsonResponse = {};
  String url = '${globals.baseUrl}getLoginId?token=$token';
  try {
    response = await http.get(url, headers: headers);
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again later.");
    return {};
  }

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try to login again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  Map results = jsonResponse;
  return results;
}

Future<List<DashboardItem>> getDashboardItems(int token, BuildContext context) async {
  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}userDashboard?token=$token";
  try {
    response = await http.get(url);
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding.", "Please try again.");
    return new List();
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred.", "Please try again.");
    return new List();
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  List<DashboardItem> returnItems = [];
  if (jsonResponse['error'] == 'false') {
    for (var item in jsonResponse['results']) {
      DashboardItem dashboardItem = new DashboardItem(item);
      returnItems.add(dashboardItem);
    }
  }
  return returnItems;
}

Future<Appointments> getBarberAppointments(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getBarberAppointments?token=$userid";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (017)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (017)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    var appointments = Appointments(jsonResponse['appointments']);

    return appointments;
  }else {
    return null;
  }
}