import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trimmz/Model/Availability.dart';
import 'package:trimmz/globals.dart' as globals;
import 'dart:convert';
import 'package:trimmz/dialogs.dart';
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:trimmz/Model/User.dart';
import 'package:trimmz/Model/Conversation.dart';
import 'package:trimmz/helpers.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:trimmz/Model/FeedItem.dart';

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

  String url = "${globals.baseUrl}V1/dashboard?token=$token";
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
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
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

Future<List<User>> getUsersByLocation(BuildContext context, int zipcode) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/users/zipcode?zipcode=$zipcode";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    var users = Users(jsonResponse['users']);
    return users.list;
  }else {
    return null;
  }
}

Future<User> getUserById(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/users/id?token=$token";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    var user = User(jsonResponse['user'][0]);
    return user;
  }else {
    return null;
  }
}

Future<List<Conversation>> getConversations(BuildContext context) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/conversations?token=${globals.user.token}&usertype=${globals.user.userType}";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    cacheData("conversations", jsonResponse);
    var conversations = Conversations(jsonResponse['conversations'], jsonResponse['messages']);
    return conversations.list;
  }else {
    return null;
  }
}

Future<Appointment> appointmentHandler(BuildContext context, int barberId, int appointmentId, int status) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token": barberId,
    "status": "$status",
  };

  String url = "${globals.baseUrl}V1/appointments/$appointmentId";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  if(jsonResponse['error'] == 'false'){
    Appointment appointment = new Appointment(jsonResponse['appointment']);
    return appointment;
  }else {
    return null;
  }
}

Future<List<Service>> getServices(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/services?token=$token";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<Service> services = [];
    for(var item in jsonResponse['services']) {
      services.add(new Service(item));
    }
    return services;
  }else {
    return null;
  }
}

Future<Service> addService(BuildContext context, int token, String name, int price, int duration) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "token": token,
    "name": name,
    "duration": duration,
    "price": price
  };

  String url = "${globals.baseUrl}V1/services";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    Service service = new Service(jsonResponse['results'][0]);
    return service;
  }else {
    return null;
  }
}

Future<Map> editService(BuildContext context, int token, int packageId, {String name, int price, int duration}) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "token": token,
    "packageid": packageId,
  };

  if(name != null) jsonMap['name'] = name;
  if(price != null) jsonMap['price'] = price;
  if(duration != null) jsonMap['duration'] = duration;

  String url = "${globals.baseUrl}V1/services/id";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    return jsonResponse;
  }else {
    return null;
  }
}

Future<List<Availability>> getAvailability(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/availability?token=$token";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<Availability> availability = [];
    for(var item in jsonResponse['availability']) {
      availability.add(new Availability(item));
    }
    return availability;
  }else {
    return null;
  }
}

Future<List<FeedItem>> getUserFeed(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  // String url = "${globals.baseUrl}V1/userFeed?token=$token";
  String url = "${globals.baseUrl}getPosts?token=$token&type=2";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<FeedItem> feed = [];
    for(var item in jsonResponse['posts']) {
      feed.add(new FeedItem(item));
    }
    return feed;
  }else {
    return null;
  }
}

Future<Map> deleteService(BuildContext context, int token, int serviceId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/services?token=$token&serviceId=$serviceId";

  try {
    response = await http.delete(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    return {
      "results": jsonResponse['results'],
      "serviceId": serviceId
    };
  }else {
    return null;
  }
}