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
import 'package:trimmz/Model/NotificationItem.dart';

Future<List> getDeviceDetails() async {
  String deviceName;
  String deviceVersion;
  String deviceIdentifier;
  String deviceType;
  bool isPhysicalDevice;
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      deviceName = build.model;
      deviceVersion = build.version.toString();
      deviceIdentifier = build.id;
      isPhysicalDevice = build.isPhysicalDevice;
      deviceType = 'Android';
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      deviceName = data.name;
      deviceVersion = data.systemVersion;
      deviceIdentifier = data.identifierForVendor; // UUID for iOS
      isPhysicalDevice = data.isPhysicalDevice;
      deviceType = 'iOS';
    }
  } on Exception {
    print("failed to get platform version");
  }

  return [deviceName, deviceVersion, deviceIdentifier, deviceType, isPhysicalDevice];
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
    showErrorDialog(context, "The Server is not responding", "Please try again later.");
    return {};
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
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
  String url = '${globals.baseUrl}V1/login/$token';
  try {
    response = await http.post(url, headers: headers);
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

Future<Appointments> getAppointments(BuildContext context, int userid, int userType) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/appointments?token=$userid&userType=$userType";

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

Future<User> getUserById(BuildContext context, int token, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/users/id?token=$token&userid=$userid";

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
    return [];
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false'){
    if(jsonResponse['conversations'].length > 0 && jsonResponse['messages'].length > 0) {
      cacheData("conversations", jsonResponse);
      var conversations = Conversations(jsonResponse['conversations'], jsonResponse['messages']);
      return conversations.list;
    }else {
      return [];
    }
  }else {
    return [];
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
  String url = "${globals.baseUrl}getPosts?token=$token&type=1";

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

Future<List<User>> getFollowedUsers(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/users/following?token=$token";

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

Future<globals.StripePaymentMethod> getPaymentMethod(BuildContext context, String token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/payment-method/$token";

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
    if(globals.stripe.customerId == null) {
      globals.stripe.customerId = jsonResponse['customerId'];
    }
    if(jsonResponse['payment_method'].length > 0) {
      return new globals.StripePaymentMethod(jsonResponse['payment_method'][0]);
    }else {
      return null;
    }
  }else {
    return null;
  }
}

Future<globals.StripePaymentMethod> getAppointmentPaymentMethod(BuildContext context, String token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/payment-method?id=$token";

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
    return new globals.StripePaymentMethod(jsonResponse['payment_method']);
  }else {
    return null;
  }
}

Future<Availability> setUserAvailability(BuildContext context, int token, String day, String start, String end, bool isClosed) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "token" : token,
    "day" : day,
    "start" : start,
    "end" : end,
    "closed": isClosed ? 1 : 0
  };

  String url = "${globals.baseUrl}V1/availability";

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
    return new Availability(jsonResponse['results'][0]);
  }else {
    return null;
  }
}

Future<globals.StripePaymentMethod> updatePaymentMethod(BuildContext context, int token, String paymentMethodId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token": token,
    "paymentMethodId": paymentMethodId,
  };

  String url = "${globals.baseUrl}V1/payment-method";

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
    if(globals.stripe.customerId == null) {
      globals.stripe.customerId = jsonResponse['customerId'];
    }
    return new globals.StripePaymentMethod(jsonResponse['payment_method']);
  }else {
    return null;
  }
}

Future<Appointment> bookAppointment(BuildContext context, int token, int userToken, double subTotal, num tip, double processingFee, List<Map> services, DateTime time, {Map paymentMethod, Map manual}) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token": token,
    "userToken": userToken,
    "subTotal": subTotal,
    "tip": tip,
    "processingFee": processingFee,
    "services": services,
    "time": "$time"
  };

  if(paymentMethod != null){
    jsonMap['paymentMethod'] = paymentMethod;
  }
  if(manual != null) {
    jsonMap['manual'] = manual;
  }
  
  String url = "${globals.baseUrl}V1/booking";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    print(Exception);
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
    return new Appointment(jsonResponse['appointment'][0]);
  }else {
    return null;
  }
}

Future<bool> setFirebaseToken(BuildContext context, String firebaseToken, int token) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  var deviceInfo = await getDeviceDetails();
  if(!deviceInfo[4]) return null;

  var jsonData = {
    "userid": token,
    "token": "$firebaseToken",
    "device_type": '${deviceInfo[0]}',
    "device_os_version": '${deviceInfo[1]}',
    "device_id": '${deviceInfo[2]}',
    "device_os": '${deviceInfo[3]}',
    "created": '${DateTime.now()}'
  };

  String url = "${globals.baseUrl}setNotificationToken/";

  Map jsonResponse = {};
  http.Response response;
  try {
    response = await http.post(url, body: jsonEncode(jsonData), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (038)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (038)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    return true;
  }else {
    return false;
  }
}

Future<bool> handleFollowing(BuildContext context, int token, int userId, bool following) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token" : token,
    "userid" : userId,
    "following": following
  };

  String url = "${globals.baseUrl}V1/users/following";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (012)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (012)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    return true;
  }else {
    return false;
  }
}

Future<List<NotificationItem>> getNotifications(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/notifications?token=$token";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return [];
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false'){
    List<NotificationItem> notifications = [];
    for(var item in jsonResponse['notifications']) {
      notifications.add(new NotificationItem(item));
    }
    return notifications;
  }else {
    return [];
  }
}

removeNotification(BuildContext context, int token, int notification) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/notifications?token=$token&notification=$notification";

  try {
    response = await http.delete(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (045)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (045)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
}

setNotificationsRead(BuildContext context, int token) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonData = {
    "token": token,
  };

  String url = "${globals.baseUrl}V1/notifications";

  try {
    response = await http.post(url, body: json.encode(jsonData), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  // if(jsonResponse['error'] == 'false'){
  //   return true;
  // }else {
  //   return false;
  // }
}

Future<bool> validatePassword(BuildContext context, int token, String password) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/validate/password?token=$token&string=$password";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false'){
    return jsonResponse['result'];
  }else {
    return false;
  }
}

Future<bool> validateUsername(BuildContext context, int token, String username) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}V1/validate/username?token=$token&string=$username";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false'){
    return jsonResponse['result'];
  }else {
    return false;
  }
}