import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/Model/AppointmentRequests.dart';
import 'package:trimmz/Model/BarberPolicies.dart';
import 'globals.dart' as globals;
import 'dialogs.dart';
import 'Model/availability.dart';
import 'Model/SuggestedBarbers.dart';
import 'Model/ClientBarbers.dart';
import 'Model/Packages.dart';
import 'package:intl/intl.dart';
import 'jsonConvert.dart';
import 'Model/Appointment.dart';
import 'Model/Reviews.dart';

Future<Map> loginPost(String url, Map jsonData, BuildContext context, ) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };
  http.Response response;
  Map jsonResponse = {};
  try {
    response = await http.post(url, body: json.encode(jsonData), headers: headers);
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
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonMap;

  if(accountType == '1') {
    jsonMap = {
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'type': accountType
    };
  }else {
    jsonMap = {
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
  
  if(jsonResponse['error'] == false) {
    return true;
  }else {
    return false;
  }
}

Future<int> getDashType(int token, BuildContext context) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {"userid": token};

  String url = "${globals.baseUrl}getDashType/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (002)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (002)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['error'] == false) {
    var dashType = jsonResponse['timeline']['token'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('dashType', dashType);
    return dashType;
  }else {
    return null;
  }
}

Future<ClientBarbers> getUserDetailsPost(int token, BuildContext context) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {"userid": token};

  String url = "${globals.baseUrl}getUser/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if (jsonResponse['error'] == false) {
    ClientBarbers userDetails = new ClientBarbers();
    for(var item1 in jsonResponse['user']){
      userDetails.id = item1['id'];
      userDetails.username = item1['username'];
      userDetails.email = item1['email'];
      userDetails.phone = item1['phone'];
      userDetails.name = item1['name'];
      userDetails.shopName = item1['shop_name'];
      userDetails.shopAddress = item1['shop_address'];
      userDetails.created = DateTime.parse(item1['created']);
      userDetails.city = item1['city'];
      userDetails.state = item1['state'];
      userDetails.zipcode = item1['zipcode'];
      userDetails.rating = item1['rating'] ?? '0';
    }

    return userDetails;
  }else {
    return null;
  }
}

Future<List<SuggestedBarbers>> getSuggestions(BuildContext context, int userid, int type, [List location]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap;
  if(location == null) {
    jsonMap = {
      "userid" : userid,
      "type" : type
    };
  }else {
    jsonMap = {
      "userid" : userid,
      "type" : type,
      "city" : location[0],
      "state" : location[1]
    };
  }

  String url = "${globals.baseUrl}suggestions/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if(jsonResponse['error'] == false){
    if(jsonResponse['type'] == 1){
      List<SuggestedBarbers> suggestedBarbers = [];
      for(var item in jsonResponse['suggestions']){
        var suggestedBarber = new SuggestedBarbers();
        suggestedBarber.id = item['id'];
        suggestedBarber.name = item['name'];
        suggestedBarber.username = item['username'];
        suggestedBarber.email = item['email'];
        suggestedBarber.phone = item['phone'];
        suggestedBarber.shopName = item['shop_name'];
        suggestedBarber.shopAddress = item['shop_address'];
        suggestedBarber.city = item['city'];
        suggestedBarber.state = item['state'];
        suggestedBarber.zipcode = item['zipcode'];
        suggestedBarber.rating = item['rating'] ?? '0';
        List<ClientBarbers> clientBarbers = await getUserBarbers(context, globals.token);
        for(var item2 in clientBarbers) {
          if(item2.id.contains(item['id'])){
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
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
  };

  String url = "${globals.baseUrl}getAddedBarbers/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if(jsonResponse['error'] == false){
    List<ClientBarbers> clientBarbers = [];
    for(var item in jsonResponse['barbers']){
      var clientBarber = new ClientBarbers();
      clientBarber.id = item['id'];
      clientBarber.name = item['name'];
      clientBarber.username = item['username'];
      clientBarber.email = item['email'];
      clientBarber.phone = item['phone'];
      clientBarber.shopName = item['shop_name'];
      clientBarber.shopAddress = item['shopAddress'];
      clientBarber.city = item['city'];
      clientBarber.state = item['state'];
      clientBarber.zipcode = item['zipcode'];
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
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "barberid" : barberid
  };

  String url = "${globals.baseUrl}addBarbers/";

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

  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }

}

Future<bool> removeBarber(BuildContext context, int userid, int barberid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "barberid" : barberid
  };

  String url = "${globals.baseUrl}removeBarbers/";

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

  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }

}

Future<List<Packages>> getBarberPkgs(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
  };

  String url = "${globals.baseUrl}getBarberPkgs/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if(jsonResponse['error'] == false){
    List<Packages> packages = [];
    for(var items in jsonResponse['packages']) {
      var package = new Packages();
      package.id = items['id'];
      package.name = items['name'];
      package.price = items['price'];
      package.duration = items['duration'];
      packages.add(package);
    }
    return packages;
  }else {
    return [];
  }

}

Future<bool> addPackage(BuildContext context, int barberid, String name, int duration, double price) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
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

  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }

}

Future<Map<DateTime, List<dynamic>>> getBarberAppointments(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
  };

  String url = "${globals.baseUrl}getBarberApt/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if(jsonResponse['error'] == false){
    Map<DateTime, List<dynamic>> apt = {};
    final df = new DateFormat('yyyy-MM-dd');
    final df2 = new DateFormat('hh:mm a');

    for(var item in jsonResponse['appointments']) {
      var dateString = item['date'];
      DateTime date = DateTime.parse(df.format(DateTime.parse(dateString)));

      if(!apt.containsKey(date)) {
        apt[date] = [{'id': item['id'], 'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated']}];
      }else {
        apt[date].add({'id': item['id'], 'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated']});
      }
    }

    return apt;
  }else {
    return {};
  }

}

Future<bool> removePackage(BuildContext context, int userid, int packageid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
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

  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }

}

Future<List<Availability>> getBarberAvailability(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
  };

  String url = "${globals.baseUrl}getBarberAvailability/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if(jsonResponse['error'] == false){
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

Future<bool> setTimeAvailability(BuildContext context, int userid, String day, DateTime start, DateTime end, bool isClosed, bool setup) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String startString;
  String endString;

  if(!setup) {
    if(isClosed){
      startString = 'null';
      endString = 'null';
    }else {
      startString = DateFormat.Hms().format(start);
      endString = DateFormat.Hms().format(end);
    }
  }

  var jsonMap;
  if(!setup) {
    jsonMap = {
      "userid" : userid,
      "day" : day,
      "start" : startString,
      "end" : endString
    };
  }else {
    jsonMap = {
      "userid" : userid,
      "day" : '',
      "start" : '',
      "end" : ''
    };
  }

  String url = "${globals.baseUrl}setTimeAvailability/";

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

  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }
}

Future<bool> bookAppointment(BuildContext context, int userId, String barberId, int price, DateTime time, String packageId, int tip) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
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
  
  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }
}

Future<List<AppointmentRequest>> getBarberAppointmentRequests(BuildContext context, int barberId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    //"apiKey": 1018,
    "barberid": barberId,
  };

  String url = "${globals.baseUrl}getBarberAppointmentRequests/";
  //String url = "${globals.baseUrl}";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if(jsonResponse['error'] == false){
    List<AppointmentRequest> appointmentReq = [];
    for(var item in jsonResponse['appointments']) {
      AppointmentRequest request = new AppointmentRequest();
      request.requestId = int.parse(item['id']);
      request.clientId = int.parse(item['client_id']);
      request.clientName = item['cname'];
      request.dateTime = DateTime.parse(item['date']);
      request.packageId = int.parse(item['package_id']);
      request.packageName = item['pname'];
      request.price = int.parse(item['price']);
      appointmentReq.add(request);
    }
    return appointmentReq;
  }else {
    return [];
  }

}

Future<int> aptRequestDecision(BuildContext context, int barberId, int requestId, int decision) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "barberid": barberId,
    "requestid": requestId,
    "decision": decision,
  };

  String url = "${globals.baseUrl}appointmentRequestDecision/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (019)", "Please try again. If this error continues to occur, please contact support.");
    return 0;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (019)", "Please try again.");
    return 0;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == false){
    if(jsonResponse['decision'] == 'accepted'){
      return 1;
    }else {
      return 2;
    }
  }else {
    return 0;
  }
}

Future<Appointment> getUpcomingAppointment(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid": userId,
  };

  String url = "${globals.baseUrl}getUpcomingAppointment/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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
  
  if(jsonResponse['error'] == false){
    if(jsonResponse['appointment'].length > 0) {
      Appointment appointment = new Appointment();
      for(var item in jsonResponse['appointment']){
        appointment.clientId = int.parse(item['client_id']);
        appointment.barberId = int.parse(item['barber_id']);
        //appointment.clientName = globals.username;
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

Future<bool> markAppointment(BuildContext context, int id, int mark) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "appointmentid" : id,
    "mark": mark,
  };

  String url = "${globals.baseUrl}markAppointment/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (021)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (021)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }
  
  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }
}

Future<bool> exists(BuildContext context, String string, int type, [var userid]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;
  var jsonMap;
  if(type == 1){
    jsonMap = {
      "type" : type,
      "string": string,
    };
  }else if(type == 2) {
    jsonMap = {
      "type" : type,
      "string": string,
      "userid": userid
    };
  }

  String url = "${globals.baseUrl}exists/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
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

  if(jsonResponse['error'] == false){
    if(jsonResponse['exist'] == true) {
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
    'Content-Type' : 'application/x-www-form-urlencoded',
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
  
  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }
}

Future<Map> updateSettings(BuildContext context, int userid, int type, [String name, String email, String spCustomerId, String spPaymentId]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "type": type,
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
  
  if(jsonResponse['error'] == false && jsonResponse['message'] == 'Settings Updated'){
    return jsonResponse;
  }else {
    return {};
  }
}

Future<bool> updatePackage(BuildContext context, int userid, int type, [String name, int price, int duration]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "packageid": type,
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
  
  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }
}

Future<bool> updateAppointmentStatus(BuildContext context, int appointmentId, int status) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "id" : appointmentId,
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
  
  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }
}

Future<bool> updatePayoutSettings(BuildContext context, int userid, [String payoutId, String payoutMethod]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid" : userid,
    "payoutId": payoutId != null ? payoutId : null,
    "payoutMethod": payoutMethod != null ? payoutMethod : null,
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
  
  if(jsonResponse['error'] == false){
    return true;
  }else {
    return false;
  }
}

Future<BarberPolicies> getBarberPolicies(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}?key=policies&token=$userId";

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

  if(jsonResponse['error'] == false){
    BarberPolicies policies = new BarberPolicies();
    if(jsonResponse['policies'].length > 0){
      for(var item in jsonResponse['policies']){
        policies.cancelEnabled = item['cancel_enabled'] == '0' ? false : true;
        policies.noShowEnabled = item['noshow_enabled'] == '0' ? false : true;
        policies.cancelFee = item['cancel_fee'];
        policies.cancelWithinTime = int.parse(item['cancel_time']);
        policies.noShowFee = item['noshow_fee'];
      }
      return policies;
    } else {
      return null;
    }
  }else {
    return null;
  }

}

Future<List<SuggestedBarbers>> getSearchUsers(BuildContext context, String username) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}?key=search_user&username=$username";

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

  if(jsonResponse['error'] == false){
    if(jsonResponse['users'].length > 0){
      List<SuggestedBarbers> suggestedBarbers = [];
      for(var item in jsonResponse['users']){
        var suggestedBarber = new SuggestedBarbers();
        suggestedBarber.id = item['id'];
        suggestedBarber.name = item['name'];
        suggestedBarber.username = item['username'];
        suggestedBarber.email = item['email'];
        suggestedBarber.phone = item['phone'];
        suggestedBarber.shopName = item['shop_name'];
        suggestedBarber.shopAddress = item['shop_address'];
        suggestedBarber.city = item['city'];
        suggestedBarber.state = item['state'];
        suggestedBarber.zipcode = item['zipcode'];
        suggestedBarber.rating = item['rating'] ?? '0';
        List<ClientBarbers> clientBarbers = await getUserBarbers(context, globals.token);
        for(var item2 in clientBarbers) {
          if(item2.id.contains(item['id'])){
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

Future<List<BarberReviews>> getUserReviews(BuildContext context, int userId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}?key=user_reviews&token=$userId";

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

  if(jsonResponse['error'] == false){
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
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}?key=num_user_reviews&token=$userId&barberid=$barberid";

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

  if(jsonResponse['error'] == false){
    return jsonResponse['number'];
  }else {
    return null;
  }
}

Future<bool> submitReview(BuildContext context, String comment, int barberId, int userId, double rating) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonData = {
    "key": "submit_review",
    "barberId": barberId,
    "userId": userId,
    "rating": rating,
    "comment": comment
  };

  String url = "${globals.baseUrl}";

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

  if(jsonResponse['error'] == false){
    return jsonResponse['results'];
  }else {
    return false;
  }
}

Future<Map<DateTime, List<dynamic>>> getUserAppointments(BuildContext context, int userid) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.baseUrl}?key=user_appointments&token=$userid";

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

  if(jsonResponse['error'] == false){
    Map<DateTime, List<dynamic>> apt = {};
    final df = new DateFormat('yyyy-MM-dd');
    final df2 = new DateFormat('hh:mm a');

    for(var item in jsonResponse['appointments']) {
      var dateString = item['date'];
      DateTime date = DateTime.parse(df.format(DateTime.parse(dateString)));

      if(!apt.containsKey(date)) {
        apt[date] = [{'id': item['id'], 'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated']}];
      }else {
        apt[date].add({'id': item['id'], 'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status'], 'price': item['price'], 'tip': item['tip'], 'duration': item['duration'], 'updated': item['updated']});
      }
    }

    return apt;
  }else {
    return {};
  }
}

Future<BarberPolicies> updateBarberPolicies(BuildContext context, int userId, [String cancelFee, bool isCancelPercent, int cancelTime, String noShowFee, bool isNoShowPercent, bool cancelEnabled, bool noShowEnabled]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "key": "policies",
    "token": userId,
    "cancelFee": cancelFee != null ? '${isCancelPercent ? '' : '\$'}$cancelFee${isCancelPercent ? '%' : ''}' : null,
    "cancelTime": cancelTime != null ? cancelTime : null,
    "noShowFee": noShowFee != null ? '${isNoShowPercent ? '' : '\$'}$noShowFee${isNoShowPercent ? '%' : ''}' : null,
    "cancelEnabled": cancelEnabled != null ? cancelEnabled ? 1 : 0 : null,
    "noShowEnabled": noShowEnabled != null ? noShowEnabled ? 1 : 0 : null,
  };

  String url = "${globals.baseUrl}";

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

  if(jsonResponse['error'] == false){
    BarberPolicies policies = new BarberPolicies();
    if(jsonResponse['policies'].length > 0){
      for(var item in jsonResponse['policies']){
        policies.cancelEnabled = item['cancel_enabled'] == '0' ? false : true;
        policies.noShowEnabled = item['noshow_enabled'] == '0' ? false : true;
        policies.cancelFee = item['cancel_fee'];
        policies.cancelWithinTime = int.parse(item['cancel_time']);
        policies.noShowFee = item['noshow_fee'];
      }
      return policies;
    } else {
      return null;
    }
  }else {
    return null;
  }
}