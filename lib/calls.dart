import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/Model/AppointmentRequests.dart';
import 'globals.dart' as globals;
import 'dialogs.dart';
import 'Model/availability.dart';
import 'Model/ClientPaymentMethod.dart';
import 'Model/PaymentMethodConfig.dart';
import 'package:uuid/uuid.dart';
import 'package:square_in_app_payments/models.dart';
import 'Model/SuggestedBarbers.dart';
import 'Model/ClientBarbers.dart';
import 'Model/Packages.dart';
import 'package:intl/intl.dart';
import 'jsonConvert.dart';
import 'Model/Appointment.dart';

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

Future<List<ClientPaymentMethod>> getPaymentMethodItems(BuildContext context) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {"userid": globals.token};

  String url = "${globals.baseUrl}getPaymentMethod/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (004)", "Please try again. If this error continues to occur, please contact support.");
    return new List();
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (004)", "Please try again.");
    return new List();
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if (jsonResponse['error'] == false) {
    List<ClientPaymentMethod> paymentMethodItems = [];
    var paymentMethodItem = new ClientPaymentMethod();
    paymentMethodItem.cardNonce = "";
    paymentMethodItem.brand = "";
    paymentMethodItem.lastFour = 0;
    paymentMethodItem.expMonth = 0;
    paymentMethodItem.expYear = 0;
    paymentMethodItem.type = "";
    paymentMethodItem.prepaidType = "";
    paymentMethodItem.zipcode = 0;
    paymentMethodItems.add(paymentMethodItem);
    return paymentMethodItems;
  }else {
    return [];
  }

}

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

Future<bool> createCustomerTS(BuildContext context) async {
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
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (006)", "Please try again.");
    return false;
  }

  print(jsonResponse);

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  return true;
}

Future<bool> createCustomerCardTS(BuildContext context, String id, String nonce) async {
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
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (007)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  print(jsonResponse);

  return true;
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

  print(jsonResponse);

  return true;
}

Future<bool> savePaymentMethod(BuildContext context, CardDetails card) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "userid": globals.token,
    "nonce": card.nonce,
    "brand": card.card.brand,
    "last_four": card.card.lastFourDigits,
    "exp_month": card.card.expirationMonth,
    "exp_year": card.card.expirationYear,
    "type": card.card.type,
    "prepaid_type": card.card.prepaidType,
    "postal_code": card.card.postalCode,
    "created": "NOW()"
  };

  String url = "${globals.baseUrl}paymentMethod/";

  try {
    response = await http.post(url, body: json.encode(jsonMap), headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (009)", "Please try again. If this error continues to occur, please contact support.");
    return false;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (009)", "Please try again.");
    return false;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  print('JSON FOR SAVING PAYMENT METHOD:');
  print(jsonResponse);

  return true;
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
        apt[date] = [{'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status']}];
      }else {
        apt[date].add({'name': item['client_name'], 'package': item['package_name'], 'time': df2.format(DateTime.parse(dateString)), 'full_time': item['date'], 'status': item['status']});
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

Future<bool> bookAppointment(BuildContext context, int userId, String barberId, int price, DateTime time, String packageId) async {
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
    "packageid" : packageId
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

Future<bool> exists(BuildContext context, String string, int type) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Map jsonResponse = {};
  http.Response response;

  var jsonMap = {
    "type" : type,
    "string": string,
  };

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