import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trimmz/Model/AppointmentRequests.dart';
import 'package:trimmz/Model/BarberClients.dart';
import 'package:trimmz/Model/BarberPolicies.dart';
import 'package:trimmz/Model/FeedItems.dart';
import '../globals.dart' as globals;
import '../dialogs.dart';
import '../Model/availability.dart';
import '../Model/SuggestedBarbers.dart';
import '../Model/ClientBarbers.dart';
import '../Model/Packages.dart';
import 'package:intl/intl.dart';
import '../jsonConvert.dart';
import '../Model/Appointment.dart';
import '../Model/Reviews.dart';
import '../Model/Notifications.dart';
import 'dart:io';
import 'package:device_info/device_info.dart';

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

Future<Map> loginPost(String username, String password, BuildContext context) async {
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

Future<Map> loginPostV2(int token, [BuildContext context]) async {
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

Future<bool> registerUser(BuildContext context, String name, String username, String email, String accountType, String password,[String address, String city, String state, String zipcode]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap;

  if(accountType == '1') {
    jsonMap = {
      "key": "register",
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'type': accountType
    };
  }else {
    jsonMap = {
      "key": "register",
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'type': accountType,
      'address': address,
      'city': city,
      'state': state,
      'zipcode': zipcode
    };
  }

  String url = "${globals.baseUrl}register/";

  http.Response response;
  Map jsonResponse = {};
  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers);
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (001)", "Please try again later.");
    return false;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (001)", "Please try again.");
    return false;
  }
  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false') {
    return true;
  }else {
    return false;
  }
}

Future<ClientBarbers> getUserDetailsPost(int token, BuildContext context) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getUser?token=$token";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (003)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (003)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['error'] == 'false') {
    ClientBarbers userDetails = new ClientBarbers();
    for(var item1 in jsonResponse['user']){
      userDetails.id = item1['id'].toString();
      userDetails.username = item1['username'];
      userDetails.email = item1['email'];
      userDetails.phone = item1['phone'];
      userDetails.name = item1['name'];
      userDetails.shopName = item1['shop_name'];
      userDetails.shopAddress = item1['shop_address'];
      //userDetails.created = DateTime.parse(item1['created']);
      userDetails.city = item1['city'];
      userDetails.state = item1['state'];
      userDetails.zipcode = item1['zipcode'].toString();
      userDetails.rating = item1['rating'] ?? '0';
      userDetails.profilePicture = item1['profile_picture'];
    }

    return userDetails;
  }else {
    return null;
  }
}

Future<List<SuggestedBarbers>> getSuggestions(BuildContext context, int userid, int type, [List location]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = '';

  if(location == null) {
    url = "${globals.baseUrl}suggestions?token=$userid&type=$type";
  }else {
    url = "${globals.baseUrl}suggestions?token=$userid&type=$type&city=${location[0]}&state=${location[1]}";
  }

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (010)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (010)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    if(type == 1){
      List<SuggestedBarbers> suggestedBarbers = [];
      for(var item in jsonResponse['suggestions']){
        var suggestedBarber = new SuggestedBarbers();
        suggestedBarber.id = item['id'].toString();
        suggestedBarber.name = item['name'];
        suggestedBarber.username = item['username'];
        suggestedBarber.email = item['email'];
        suggestedBarber.phone = item['phone'];
        suggestedBarber.shopName = item['shop_name'];
        suggestedBarber.shopAddress = item['shop_address'];
        suggestedBarber.city = item['city'];
        suggestedBarber.state = item['state'];
        suggestedBarber.zipcode = item['zipcode'].toString();
        suggestedBarber.rating = item['rating'] ?? '0';
        suggestedBarber.profilePicture = item['profile_picture'];
        List<ClientBarbers> clientBarbers = await getUserBarbers(context, globals.token);
        for(var item2 in clientBarbers) {
          if(item2.id.contains(item['id'].toString())){
            suggestedBarber.hasAdded = true;
          }
        }
        suggestedBarbers.add(suggestedBarber);
      }

      return suggestedBarbers;
    }else {
      return [];
    }
  }else {
    return [];
  }
}

Future<List<ClientBarbers>> getUserBarbers(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getAddedBarbers?token=$userid";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (011)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (011)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<ClientBarbers> clientBarbers = [];
    for(var item in jsonResponse['barbers']){
      var clientBarber = new ClientBarbers();
      clientBarber.id = item['id'].toString();
      clientBarber.name = item['name'];
      clientBarber.username = item['username'];
      clientBarber.email = item['email'];
      clientBarber.phone = item['phone'];
      clientBarber.shopName = item['shop_name'];
      clientBarber.shopAddress = item['shopAddress'];
      clientBarber.city = item['city'];
      clientBarber.state = item['state'];
      clientBarber.zipcode = item['zipcode'].toString();
      clientBarber.rating = item['rating'];
      clientBarbers.add(clientBarber);
    }

    return clientBarbers;
  }else {
    return [];
  }
}

Future<bool> addBarber(BuildContext context, int userid, int barberid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "barberid" : barberid
  };

  String url = "${globals.baseUrl}addBarber/";

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

Future<bool> removeBarber(BuildContext context, int userid, int barberid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "barberid" : barberid
  };

  String url = "${globals.baseUrl}removeBarber";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (014)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (014)", "Please try again.");
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

Future<List<Packages>> getBarberPkgs(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getBarberPackages?token=$userid";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (015)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (015)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<Packages> packages = [];
    for(var items in jsonResponse['packages']) {
      var package = new Packages();
      package.id = items['id'].toString();
      package.name = items['name'];
      package.price = items['price'].toString();
      package.duration = items['duration'].toString();
      packages.add(package);
    }
    return packages;
  }else {
    return [];
  }

}

Future<bool> addPackage(BuildContext context, int barberid, String name, int duration, double price) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "barberid" : barberid,
    "name" : name,
    "duration" : duration,
    "price" : price
  };

  String url = "${globals.baseUrl}addPackage/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (016)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (016)", "Please try again.");
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

Future<Map<DateTime, List<dynamic>>> getBarberAppointments(BuildContext context, int userid) async {
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
    return {};
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (017)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    Map<DateTime, List<dynamic>> apt = {};
    final df = new DateFormat('yyyy-MM-dd');
    final df2 = new DateFormat('hh:mm a');

    for(var item in jsonResponse['appointments']) {
      var dateString = item['date'];
      DateTime date = DateTime.parse(df.format(DateTime.parse(dateString)));

      if(!apt.containsKey(date)) {
        apt[date] = [{'id': item['id'], 'clientid': item['client_id'], 'barberid': item['barber_id'], 'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated'], 'profile_picture': item['profile_picture'], 'paymentid': item['sp_paymentid'], 'customerid': item['sp_customerid'], 'email': item['email']}];
      }else {
        apt[date].add({'id': item['id'], 'clientid': item['client_id'], 'barberid': item['barber_id'], 'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated'], 'profile_picture': item['profile_picture'], 'paymentid': item['sp_paymentid'], 'customerid': item['sp_customerid'], 'email': item['email']});
      }
    }

    return apt;
  }else {
    return {};
  }

}

Future<bool> removePackage(BuildContext context, int userid, int packageid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token" : userid,
    "packageid" : packageid
  };

  String url = "${globals.baseUrl}removePackage/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (014)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (014)", "Please try again.");
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

Future<List<Availability>> getBarberAvailability(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getBarberAvailability?token=$userid";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (015)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (015)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    if(jsonResponse['availability'].length > 0) {
      List<Availability> availability = [];
      for(var item in jsonResponse['availability']){
        var map = {
          'id': item['id'],
          'DayTime': [
            {
              'Sunday': {
                'start': item['sunday_start'],
                'end': item['sunday_end']
              },
            },
            {
              'Monday': {
                'start': item['monday_start'],
                'end': item['monday_end']
              }
            },
            {
              'Tuesday': {
                'start': item['tuesday_start'],
                'end': item['tuesday_end']
              }
            },
            {
              'Wednesday': {
                'start': item['wednesday_start'],
                'end': item['wednesday_end']
              }
            },
            {
              'Thursday': {
                'start': item['thursday_start'],
                'end': item['thursday_end']
              }
            },
            {
              'Friday': {
                'start': item['friday_start'],
                'end': item['friday_end']
              }
            },
            {
              'Saturday': {
                'start': item['saturday_start'],
                'end': item['saturday_end']
              }
            }
          ]
        };
        for(var item2 in map['DayTime']){
          item2.forEach((key, value){
            Availability avail = new Availability();
            avail.day = key;
            avail.start = value['start'];
            avail.end = value['end'];

            availability.add(avail);
          });
        }
      }
      return availability;
    }else {
      List<Availability> availability = [];
      var map = jsonAvailability(1);
      for(var item2 in map['DayTime']){
        item2.forEach((key, value){
          Availability avail = new Availability();
          avail.day = key;
          avail.start = value['start'];
          avail.end = value['end'];

          availability.add(avail);
        });
      }
      return availability;
    }
  }else {
    return [];
  }

}

Future<bool> setTimeAvailability(BuildContext context, int userid, String day, DateTime start, DateTime end, bool isClosed) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String startString;
  String endString;

  if(isClosed){
    startString = 'null';
    endString = 'null';
  }else {
    startString = DateFormat.Hms().format(start);
    endString = DateFormat.Hms().format(end);
  }

  Map jsonMap = {
    "token" : userid,
    "day" : day,
    "start" : startString,
    "end" : endString
  };

  String url = "${globals.baseUrl}updateAvailability/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (016)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (016)", "Please try again.");
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

Future<bool> bookAppointment(BuildContext context, int userId, String barberId, int price, DateTime time, String packageId, int tip) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userId,
    "barberid": barberId,
    "price": price,
    "time": time.toString(),
    "packageid" : packageId,
    "tip": tip
  };

  String url = "${globals.baseUrl}bookAppointment/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (017)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (017)", "Please try again.");
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

Future<List<AppointmentRequest>> getBarberAppointmentRequests(BuildContext context, int barberId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getBarberAppointmentReq?token=$barberId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (018)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (018)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<AppointmentRequest> appointmentReq = [];
    for(var item in jsonResponse['appointments']) {
      AppointmentRequest request = new AppointmentRequest();
      request.requestId = item['id'];
      request.clientId = item['client_id'];
      request.clientName = item['cname'];
      request.dateTime = DateTime.parse(item['date']);
      request.packageId = int.parse(item['package_id']);
      request.packageName = item['pname'];
      request.price = item['price'];
      request.tip = item['tip'];
      appointmentReq.add(request);
    }
    return appointmentReq;
  }else {
    return [];
  }

}

Future<bool> aptRequestDecision(BuildContext context, int barberId, int requestId, int decision) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "barberid": barberId,
    "requestid": requestId,
    "decision": decision,
  };

  String url = "${globals.baseUrl}appointmentReqDecision/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (019)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (019)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  if(jsonResponse['error'] == 'false'){
    if(jsonResponse['results'] == 'true'){
      return true;
    }else {
      return false;
    }
  }else {
    return false;
  }
}

Future<Appointment> getUpcomingAppointment(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getUpcomingAppointment?token=$userId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (020)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (020)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false'){
    if(jsonResponse['appointment'].length > 0) {
      Appointment appointment = new Appointment();
      for(var item in jsonResponse['appointment']){
        appointment.clientId = int.parse(item['client_id']);
        appointment.barberId = int.parse(item['barber_id']);
        appointment.barberName = item['barber_name'];
        appointment.dateTime = DateTime.parse(item['date']);
        appointment.status = int.parse(item['status']);
        appointment.packageId = int.parse(item['package_id']);
        appointment.packageName = item['package_name'];
        appointment.locationAddress = item['shop_address'];
        appointment.geoAddress = item['geo'];
        appointment.price = int.parse(item['price']);
        appointment.updated = item['updated'];
      }
      return appointment;
    }else {
      return null;
    }
  }else {
    return null;
  }
}

Future<bool> exists(BuildContext context, String string, int type, [var userid]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url;
  if(type == 1){
    url = "${globals.baseUrl}exists?string=$string&type=1";
  }else if(type == 2){
    url = "${globals.baseUrl}exists?string=$string&type=2&token=$userid";
  }

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (022)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (022)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    if(jsonResponse['exist'] == 'true') {
      return true;
    }else {
      return false;
    }
  }else {
    return false;
  }
}

Future<bool> changePassword(BuildContext context, String newPassword, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "password": newPassword,
  };

  String url = "${globals.baseUrl}changePassword/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (023)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (023)", "Please try again.");
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

Future<Map> updateSettings(BuildContext context, int userid, int type, [String name, String email, String spCustomerId, String spPaymentId]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token" : userid,
    "name": name != null ? name : null,
    "email": email != null ? email : null,
    "sp_customerid": spCustomerId != null ? spCustomerId : null,
    "sp_paymentid": spPaymentId != null ? spPaymentId : null
  };

  String url = "${globals.baseUrl}updateSettings/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (024)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (024)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == 'false'){
    return jsonResponse['user'];
  }else {
    return {};
  }
}

Future<Map> updateBarberSettings(BuildContext context, int userid, [String shopName, String address, String state, String city]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token" : userid,
    "shop_name": shopName != null ? shopName : null,
    "address": address != null ? address : null,
    "city": city != null ? city : null,
    "state": state != null ? state : null
  };

  String url = "${globals.baseUrl}updateBarberSettings/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (024)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (024)", "Please try again.");
    return {};
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
    return {};
  }
}

Future<bool> updatePackage(BuildContext context, int userid, int packageid, [String name, int price, int duration]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token" : userid,
    "packageid": packageid,
    "name": name != null ? name : null,
    "price": price != null ? price : null,
    "duration": duration != null ? duration : null
  };

  String url = "${globals.baseUrl}updatePackage/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (025)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (025)", "Please try again.");
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

Future<bool> updateAppointmentStatus(BuildContext context, int appointmentId, int status) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "appointment" : appointmentId,
    "status": status,
  };

  String url = "${globals.baseUrl}updateAppointmentStatus/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (026)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (026)", "Please try again.");
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

Future<bool> updatePayoutSettings(BuildContext context, int userid, [String payoutId, String payoutMethod, String accountId]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "token" : userid,
    "payoutId": payoutId != null ? payoutId : null,
    "payoutMethod": payoutMethod != null ? payoutMethod : null,
    "accountId": accountId != null ? accountId : null,
  };

  String url = "${globals.baseUrl}updatePayoutSettings/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (027)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (027)", "Please try again.");
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

Future<BarberPolicies> getBarberPolicies(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getPolicies?token=$userId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (028)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (028)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    BarberPolicies policies = new BarberPolicies();
    if(jsonResponse['policies'].length > 0){
      for(var item in jsonResponse['policies']){
        policies.cancelEnabled = item['cancel_enabled'] == 0 ? false : true;
        policies.noShowEnabled = item['noshow_enabled'] == 0 ? false : true;
        policies.cancelFee = item['cancel_fee'] ?? '0%';
        policies.cancelWithinTime = item['cancel_time'] ?? 0;
        policies.noShowFee = item['noshow_fee'] ?? '0%';
      }
      return policies;
    } else {
      return null;
    }
  }else {
    return null;
  }

}

Future<List<SuggestedBarbers>> getSearchBarbers(BuildContext context, String username) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}searchBarbers?string=$username";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (029)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (029)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    if(jsonResponse['barbers'].length > 0){
      List<SuggestedBarbers> suggestedBarbers = [];
      for(var item in jsonResponse['barbers']){
        var suggestedBarber = new SuggestedBarbers();
        suggestedBarber.id = item['id'].toString();
        suggestedBarber.name = item['name'];
        suggestedBarber.username = item['username'];
        suggestedBarber.email = item['email'];
        suggestedBarber.phone = item['phone'];
        suggestedBarber.shopName = item['shop_name'];
        suggestedBarber.shopAddress = item['shop_address'];
        suggestedBarber.city = item['city'];
        suggestedBarber.state = item['state'];
        suggestedBarber.zipcode = item['zipcode'].toString();
        suggestedBarber.rating = item['rating'] ?? '0';
        suggestedBarber.profilePicture = item['profile_picture'];
        List<ClientBarbers> clientBarbers = await getUserBarbers(context, globals.token);
        for(var item2 in clientBarbers) {
          if(item2.id.contains(item['id'].toString())){
            suggestedBarber.hasAdded = true;
          }
        }
        suggestedBarbers.add(suggestedBarber);
      }

      return suggestedBarbers;
    }else {
      return [];
    }
  }else {
    return [];
  }
}

Future<List<BarberClients>> getSearchClients(BuildContext context, String username) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}searchClients?string=$username";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (029)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (029)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<BarberClients> clients = [];
    for(var item in jsonResponse['clients']){
      BarberClients client = new BarberClients();
      client.token = item['id'];
      client.name = item['name'];
      client.username = item['username'];
      client.profile = item['profile_picture'];
      clients.add(client);
    }

    return clients;
  }else {
    return [];
  }
}

Future<List<BarberReviews>> getUserReviews(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getUserReviews?token=$userId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (030)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (030)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    if(jsonResponse['reviews'].length > 0){
      List<BarberReviews> reviews = [];
      for(var item in jsonResponse['reviews']){
        BarberReviews review = new BarberReviews();
        review.barberId = int.parse(item['barber_id']);
        review.clientId = int.parse(item['user_id']);
        review.clientName = item['client_name'];
        review.comment = item['comment'];
        review.id = int.parse(item['id']);
        review.rating = double.parse(item['rating']);
        review.created = DateTime.parse(item['created']);
        reviews.add(review);
      }

      return reviews;
    }else {
      return [];
    }
  }else {
    return [];
  }
}

Future<int> getNumUserReviews(BuildContext context, int userId, int barberid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getNumUserReviews?token=$userId&barberid=$barberid";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (030)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (030)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    return jsonResponse['number'];
  }else {
    return null;
  }
}

Future<bool> submitReview(BuildContext context, String comment, int barberId, int userId, double rating) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonData = {
    "barberId": barberId,
    "userId": userId,
    "rating": rating,
    "comment": comment
  };

  String url = "${globals.baseUrl}submitReview/";

  try {
    response = await http.post(url, body: json.encode(jsonData), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (031)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (031)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    return jsonResponse['results'];
  }else {
    return false;
  }
}

Future<Map<DateTime, List<dynamic>>> getUserAppointments(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getUserAppointments?token=$userid";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (032)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (032)", "Please try again.");
    return {};
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    Map<DateTime, List<dynamic>> apt = {};
    final df = new DateFormat('yyyy-MM-dd');
    final df2 = new DateFormat('hh:mm a');

    for(var item in jsonResponse['appointments']) {
      var dateString = item['date'];
      DateTime date = DateTime.parse(df.format(DateTime.parse(dateString)));

      if(!apt.containsKey(date)) {
        apt[date] = [{'id': item['id'], 'barberid': item['barber_id'], 'clientid': item['client_id'], 'name': item['client_name'], 'barber_name': item['barber_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated']}];
      }else {
        apt[date].add({'id': item['id'], 'barberid': item['barber_id'], 'clientid': item['client_id'], 'name': item['client_name'], 'barber_name': item['barber_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated']});
      }
    }

    return apt;
  }else {
    return {};
  }
}

Future<BarberPolicies> updateBarberPolicies(BuildContext context, int userId, [String cancelFee, bool isCancelPercent, int cancelTime, String noShowFee, bool isNoShowPercent, bool cancelEnabled, bool noShowEnabled]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "token": userId,
  };

  if(cancelFee != null) {
    jsonMap['cancelFee'] = isCancelPercent ? '$cancelFee%' : '\$$cancelFee';
  }
  if(cancelTime != null) {
    jsonMap['cancelTime'] = cancelTime;
  }
  if(cancelEnabled != null) {
    jsonMap['cancelEnabled'] = cancelEnabled == true ? 1 : 0;
  }
  if(noShowEnabled != null) {
    jsonMap['noShowEnabled'] = noShowEnabled == true ? 1 : 0;
  }
  if(noShowFee != null) {
    jsonMap['noShowFee'] = isNoShowPercent ? '$noShowFee%' : '\$$noShowFee';
  }

  String url = "${globals.baseUrl}updatePolicies/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (033)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (033)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    BarberPolicies policies = new BarberPolicies();
    if(jsonResponse['policies'].length > 0){
      for(var item in jsonResponse['policies']){
        policies.cancelEnabled = item['cancel_enabled'] == 0 ? false : true;
        policies.noShowEnabled = item['noshow_enabled'] == 0 ? false : true;
        policies.cancelFee = item['cancel_fee'] ?? '0%';
        policies.cancelWithinTime = item['cancel_time'] ?? 0;
        policies.noShowFee = item['noshow_fee'] ?? '0%';
      }
      return policies;
    } else {
      return null;
    }
  }else {
    return null;
  }
}

Future<Map> sendPushNotification(BuildContext context, String title, String body, int toUserId, String token, [Map<String, dynamic> data]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Authorization': 'key=AAAAU6aHEg0:APA91bGeJLiMB3qRqmbAKzEfg9M3d-I6Ear-WQ8l7PmVJMA8xcCLklLVfzOp8zZOTCbZ1WzrJbq1pLG7aAxE_aXke6WThoejom1QREterliWuN0k7fDdbw9gCwanXKWzxR2WlJW5O-pv'
  };

  Map jsonResponse = {};
  http.Response response;
  
  Map<String, dynamic> jsonMap = {
    'notification': {
      'body': '$body',
      'title': '$title',
      'sound': 'default'
    },
    'priority': 'high',
    'data': data ?? {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
    'to': '$token'
  };

  String url = "https://fcm.googleapis.com/fcm/send";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (034)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  }

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (034)", "Please try again.");
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

Future<bool> submitNotification(BuildContext context, int from, int recipient, String title, String message) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonData = {
    "from": from,
    "recipient": recipient,
    "title": title,
    "message": message,
    "created": "${DateTime.now()}"
  };

  String url = "${globals.baseUrl}submitNotification";

  try {
    response = await http.post(url, body: json.encode(jsonData), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (035)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (035)", "Please try again.");
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

Future<List<Notifications>> getUnreadNotifications(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}unreadNotifications?token=$userId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (036)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (036)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<Notifications> notifications = [];
    for(var item in jsonResponse['notifications']) {
      Notifications notify = new Notifications();
      notify.from = int.parse(item['from']);
      notify.recipient = int.parse(item['recipient']);
      notify.title = item['title'];
      notify.message = item['message'];
      notify.read = int.parse(item['read']) == 0 ? false : true;
      notify.created = item['created'];

      notifications.add(notify);
    }
    return notifications;
  }else {
    return [];
  }
}

Future<List<Notifications>> getAllNotifications(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getAllNotifications?token=$userId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (036)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (036)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<Notifications> notifications = [];
    for(var item in jsonResponse['notifications']) {
      Notifications notify = new Notifications();
      notify.from = int.parse(item['from']);
      notify.recipient = int.parse(item['recipient']);
      notify.title = item['title'];
      notify.message = item['message'];
      notify.read = int.parse(item['read']) == 0 ? false : true;
      notify.created = item['created'];

      notifications.add(notify);
    }
    return notifications;
  }else {
    return [];
  }
}

Future<bool> setNotificationsRead(BuildContext context, int recipient) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonData = {
    "recipient": recipient,
  };

  String url = "${globals.baseUrl}readNotifications/";

  try {
    response = await http.post(url, body: json.encode(jsonData), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (037)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (037)", "Please try again.");
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

Future<bool> setFirebaseToken(BuildContext context, String firebaseToken) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  var deviceInfo = await getDeviceDetails();

  var jsonData = {
    "userid": globals.token,
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

Future<bool> removeFirebaseToken(BuildContext context) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  var deviceInfo = await getDeviceDetails();

  var jsonData = {
    "token": globals.token,
    "device_id": "${deviceInfo[2]}",
  };

  String url = "${globals.baseUrl}deleteNotificationToken/";

  Map jsonResponse = {};
  http.Response response;
  try {
    response = await http.post(url, body: jsonEncode(jsonData), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (039)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (039)", "Please try again.");
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

Future<List> getNotificationTokens(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;
  
  String url = "${globals.baseUrl}getNotificationToken?token=$userId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (040)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  }
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (040)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List tokens = [];
    for(var item in jsonResponse['tokens']) {
      tokens.add(item['token']);
    }
    return tokens;
  }else {
    return [];
  }
}

Future<List<BarberClients>> getBarberClients(BuildContext context, int token, int type) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getBarberClients?token=$token&type=$type";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (041)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (041)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<BarberClients> clients = [];
    for(var item in jsonResponse['clients']) {
      BarberClients client = new BarberClients();
      client.token = item['id'];
      client.name = item['name'];
      client.username = item['username'];
      client.profile = item['profile_picture'];
      clients.add(client);
    }
    return clients;
  }else {
    return [];
  }
}

Future<String> uploadImage(BuildContext context, String filePath, int type, [String caption]) async {
  Map<String, String>jsonData = {
    "token": globals.token.toString(),
    "type": type.toString(),
    "name": filePath.substring(filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.')) + '.png',
    "caption": caption != null ? caption : ''
  };

  String url = "${globals.baseUrl}uploadImages";
  var encodedUrl = Uri.encodeFull(url);

  Map jsonResponse = {};
  http.StreamedResponse response;
  try {
    var request = new http.MultipartRequest("POST", Uri.parse(encodedUrl));
    request.fields.addAll(jsonData);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    response = await request.send();
    jsonResponse = await json.decode(await response.stream.bytesToString());
  } catch (Exception) {
    showErrorDialog(context, "The server is not responding (042)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  }

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (042)", "Please try again.");
    return null;
  }
  print(jsonResponse);
  if(jsonResponse['error'] == 'false'){
    return jsonResponse['results'];
  }else {
    return null;
  }
}

Future<bool> removeImage(BuildContext context, String image, int type) async {
  Map<String, String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  var jsonData = {
    "image": image,
    "type": type,
  };

  String url = "${globals.baseUrl}removeImage";

  Map jsonResponse = {};
  http.Response response;
  try {
    response = await http.post(url, body: jsonEncode(jsonData), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (043)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  }
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (043)", "Please try again.");
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

Future<List<FeedItem>> getPosts(BuildContext context, int userId, int type) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/json',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}getPosts?token=$userId&type=$type";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (028)", "Please try again. If this error continues to occur, please contact support.");
    return [];
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (028)", "Please try again.");
    return [];
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(jsonResponse['error'] == 'false'){
    List<FeedItem> feed = [];
    for(var item in jsonResponse['posts']){
      FeedItem feedItem = new FeedItem();
      feedItem.id = item['id'];
      feedItem.userId = int.parse(item['userid']);
      feedItem.imageUrl = '${globals.baseUrlImage}${item['url']}';
      feedItem.name = item['name'];
      feedItem.username = item['username'];
      feedItem.created = DateTime.parse(item['created']);
      feedItem.caption = item['caption'];
      feedItem.profilePic = item['profile_picture'];
      feed.add(feedItem);
    }
    return feed;
  }else {
    return [];
  }

}