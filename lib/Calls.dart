import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:trimmz/Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/Model/User.dart';
import 'package:trimmz/Model/Notification.dart' as nt;

Future<List<String>> getDeviceDetails() async {
  String deviceName = '';
  String deviceVersion = '';
  String deviceIdentifier = '';
  String deviceType = '';
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      deviceName = build.model;
      deviceVersion = build.version.toString();
      deviceIdentifier = build.androidId;
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

Future<Map<String, dynamic>> userLogin(String email, String password) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap = {
    "username": email,
    "password": password
  };

  String url = "${globals.baseUrl}/login";

  Map jsonResponse = {};
  http.Response response;

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } on TimeoutException {
    // showErrorDialog(context, "Request Timeout.", "Please try again. If this error continues to occur, please contact Kaivac.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if (jsonResponse['error'] == 'false') {
    Map<String, dynamic> results = jsonResponse['user'][0];
    User().userKey = results['id'] == null ? 0 : results['id'];
    User().name = results['name'] == null ? "" : results['name'];
    User().username = results['username'] == null ? "" : results['username'];
    User().email = results['email'] == null ? "" : results['email'];
    User().photoUrl = results['profile_picture'] == null ? "" : results['profile_picture'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(results));
    
    return jsonResponse['results'];
  }
  else {
    return {};
  }
}

Future<Map> getUserInfo(int token, [BuildContext context]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  http.Response response;
  Map jsonResponse = {};
  String url = '${globals.baseUrl}/login/$token';
  try {
    response = await http.post(url, headers: headers);
  } catch (Exception) {
    // showErrorDialog(context, "The Server is not responding", "Please try again later.");
    return {};
  }

  if (response == null || response.statusCode != 200) {
    // showErrorDialog(context, "An error has occurred", "Please try to login again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if (jsonResponse['error'] == 'false') {
    Map<String, dynamic> results = jsonResponse['user'][0];
    // User().userKey = results['id'] == null ? 0 : results['id'];
    User().name = results['name'] == null ? "" : results['name'];
    User().username = results['username'] == null ? "" : results['username'];
    User().email = results['email'] == null ? "" : results['email'];
    User().photoUrl = results['profile_picture'] == null ? "" : results['profile_picture'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(results));
    
    return jsonResponse['results'];
  }
  else {
    return {};
  }
}

Future<List<nt.Notification>> getNotifications(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}/notifications?token=$token";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    // showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return [];
  }
  if (response == null || response.statusCode != 200) {
    // showErrorDialog(context, "An error has occurred", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false'){
    List<dynamic> results = jsonResponse['notifications'];
    List<nt.Notification> notifications = [];
    results.forEach((j) {
      notifications.add(nt.Notification(j));
    });
    nt.Notifications().notifications = notifications;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notifications', json.encode(results));

    return notifications;
  }else {
    return [];
  }
}