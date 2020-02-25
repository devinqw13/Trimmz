import 'package:http/http.dart' as http;
import '../dialogs.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../Model/ClientPaymentMethod.dart';
import '../globals.dart' as globals;

Future<dynamic> spGetClientPaymentMethod(BuildContext context, String customerId, int type) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer ${globals.stripeSecretKey}', 
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.stripeURL}payment_methods?customer=$customerId&type=card";

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

  if(!jsonResponse.containsKey('error')) {
    if(type == 1) {
      ClientPaymentMethod paymentMethod = new ClientPaymentMethod();
      paymentMethod.id = jsonResponse['data'][0]['id'];
      paymentMethod.brand = jsonResponse['data'][0]['card']['brand'];
      paymentMethod.lastFour = jsonResponse['data'][0]['card']['last4'];
      paymentMethod.fingerprint = jsonResponse['data'][0]['card']['fingerprint'];

      if(paymentMethod.brand == 'visa') {
        paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/visa1.png'),fit: BoxFit.cover),height: 25));
      }else if(paymentMethod.brand == 'discover'){
        paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/discover1.png'),fit: BoxFit.cover),height: 25));
      }else if(paymentMethod.brand == 'amex'){
        paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/amex1.png'),fit: BoxFit.cover),height: 25));
      }else if(paymentMethod.brand == 'mastercard'){
        paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/mastercard1.png'),fit: BoxFit.cover),height: 25));
      }

      return paymentMethod;
    } else {
      List<ClientPaymentMethod> paymentList = [];
      for(var item in jsonResponse['data']) {
        ClientPaymentMethod payment = new ClientPaymentMethod();
        payment.id = item['id'];
        payment.brand = item['card']['brand'];
        payment.lastFour = item['card']['last4'];
        payment.fingerprint = item['card']['fingerprint'];

        if(payment.brand == 'visa') {
          payment.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/visa1.png'),fit: BoxFit.cover),height: 25));
        }else if(payment.brand == 'discover'){
          payment.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/discover1.png'),fit: BoxFit.cover),height: 25));
        }else if(payment.brand == 'amex'){
          payment.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/amex1.png'),fit: BoxFit.cover),height: 25));
        }else if(payment.brand == 'mastercard'){
          payment.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/mastercard1.png'),fit: BoxFit.cover),height: 25));
        }

        paymentList.add(payment);
      }
      return paymentList;
    }
  }else {
    return {};
  }
}

Future<Map> spCreateCustomer(BuildContext context, String paymentId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer ${globals.stripeSecretKey}', 
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "name": "${globals.username}",
    "email": "${globals.email}",
    "description": "${globals.token}",
    "payment_method": "$paymentId"
  };

  String url = "${globals.stripeURL}customers";

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

Future<Map> spCreatePaymentIntent(BuildContext context, String paymentId, String customerId, String amount, [String email]) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer ${globals.stripeSecretKey}', 
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "amount": "$amount",
    "currency": "USD",
    "confirm": "true",
    "customer": "$customerId",
    "payment_method": "$paymentId",
    'capture_method': 'automatic'
  };

  if(email != null) {
    jsonMap['email'] = '$email';
  }
  
  String url = "${globals.stripeURL}payment_intents";

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
    'Authorization' : 'Bearer ${globals.stripeSecretKey}', 
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.stripeURL}payment_methods/$paymentId/detach";

  try {
    response = await http.post(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P03)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 

  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P03)", "Please try again.");
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
    'Authorization' : 'Bearer ${globals.stripeSecretKey}', 
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "customer": "$customerId"
  };

  String url = "${globals.stripeURL}payment_methods/$paymentId/attach";

  try {
    response = await http.post(url, body: jsonMap, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P04)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P04)", "Please try again.");
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

Future<Map> spCreateConnectAccount(BuildContext context, String firstName, String lastName, String expMonth, String expYear, String number, String method, List dob, String ssn) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer ${globals.stripeSecretKey}', 
  };

  Map jsonResponse = {};
  http.Response response;

  var unixTime = DateTime.now().toUtc().millisecondsSinceEpoch;
  var currentTime = (unixTime / 1000).round();

  String payoutSchedule = method == 'standard' ? 'daily' : 'manual';

  var jsonMap = {
    'type': 'custom',
    'email': '${globals.email}',
    'business_type': 'individual',
    'requested_capabilities[0]': 'transfers',
    'requested_capabilities[1]': 'card_payments',
    'individual[first_name]': '$firstName',
    'individual[last_name]': '$lastName',
    'individual[ssn_last_4]': '$ssn',
    'individual[email]': '${globals.email}',
    'individual[phone]': '5135077135',
    'individual[dob][day]': '${dob[2]}',
    'individual[dob][month]': '${dob[1]}',
    'individual[dob][year]': '${dob[0]}',
    'individual[address][city]': '${globals.city}',
    'individual[address][state]': '${globals.state}',
    'individual[address][postal_code]': '${globals.zipcode}',
    'individual[address][line1]': '${globals.shopAddress}',
    'individual[address][country]': 'US',
    'business_profile[url]': 'https://book.trimmz.app/${globals.username}',
    'business_profile[mcc]': '7230',
    'external_account[object]': 'card',
    'external_account[currency]': 'USD',
    'external_account[number]': '$number',
    'external_account[exp_month]': '$expMonth',
    'external_account[exp_year]': '$expYear',
    'settings[payouts][schedule][interval]': '$payoutSchedule',
    'tos_acceptance[date]': '$currentTime',
    'tos_acceptance[ip]': '8.8.8.8'
  };

  String url = "${globals.stripeURL}accounts";

  try {
    response = await http.post(url, body: jsonMap, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P05)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  print(response.body);
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P05)", "Please try again.");
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

Future<Map> spTransferToConnectAccount(BuildContext context, int amount, String accountId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer ${globals.stripeSecretKey}',
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "amount": "$amount",
    "currency": "USD",
    "destination": "$accountId",
    "source_type": "card",
  };
  String url = "${globals.stripeURL}transfers";

  try {
    response = await http.post(url, body: jsonMap, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P06)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P06)", "Please try again.");
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

Future<Map> spPayout(BuildContext context, int amount, String payoutId, String accountId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer ${globals.stripeSecretKey}',
    'Stripe-Account': '$accountId'
  };

  Map jsonResponse = {};
  http.Response response;

  Map jsonMap = {
    "amount": "$amount",
    "currency": "USD",
    "destination": "$payoutId",
    "method": "${globals.spPayoutMethod}",
    "source_type": "card",
  };
  String url = "${globals.stripeURL}payouts";

  try {
    response = await http.post(url, body: jsonMap, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P07)", "Please try again. If this error continues to occur, please contact support.");
    return {};
  } 
  print(response.body);
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P07)", "Please try again.");
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

Future<bool> spChargeCard(BuildContext context, int total, String paymentId, String customerId, String cusEmail) async {
  var chargeTotal = (total + 1) * 100;
  double dbl = globals.spPayoutMethod == 'standard' ? 0.025 : 0.03;
  var payoutTotal = int.parse(((double.parse(total.toString()) - (double.parse(total.toString()) * dbl)) * 100).toStringAsFixed(0));

  var res = await spCreatePaymentIntent(context, paymentId, customerId, chargeTotal.toString(), cusEmail);
  if(res.length > 0) {
    var res2 = await spTransferToConnectAccount(context, payoutTotal, globals.spAccountId);
    if(res2.length > 0) {
      if(globals.spPayoutMethod == 'instant') {
        var res3 = await spPayout(context, payoutTotal, globals.spPayoutId, globals.spAccountId);
        if(res3.length > 0){
          return true;
        }else {
          return false;
        }
      }else {
        return true;
      }
    }else {
      return false;
    }
  }else {
    return false;
  }
}

Future<dynamic> spGetAccountPayoutCard(BuildContext context, String accountId, String payoutId) async {
  Map<String, String> headers = {
    'Content-Type' : 'application/x-www-form-urlencoded',
    'Authorization' : 'Bearer ${globals.stripeSecretKey}', 
  };

  Map jsonResponse = {};
  http.Response response;

  String url = "${globals.stripeURL}accounts/$accountId/external_accounts/$payoutId";

  try {
    response = await http.get(url, headers: headers).timeout(Duration(seconds: 60));
  } catch (Exception) {
    showErrorDialog(context, "The Server is not responding (P00)", "Please try again. If this error continues to occur, please contact support.");
    return null;
  } 
  if (response == null || response.statusCode != 200) {
    showErrorDialog(context, "An error has occurred (P00)", "Please try again.");
    return null;
  }

  if (json.decode(response.body) is List) {
    var responseBody = response.body.substring(1, response.body.length - 1);
    jsonResponse = json.decode(responseBody);
  } else {
    jsonResponse = json.decode(response.body);
  }

  if(!jsonResponse.containsKey('error')) {
    ClientPaymentMethod paymentMethod = new ClientPaymentMethod();
    paymentMethod.id = jsonResponse['id'];
    paymentMethod.brand = jsonResponse['brand'].toString().toLowerCase();
    paymentMethod.lastFour = jsonResponse['last4'];
    paymentMethod.fingerprint = jsonResponse['fingerprint'];

    if(paymentMethod.brand == 'visa') {
      paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/visa1.png'),fit: BoxFit.cover),height: 25));
    }else if(paymentMethod.brand == 'discover'){
      paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/discover1.png'),fit: BoxFit.cover),height: 25));
    }else if(paymentMethod.brand == 'amex'){
      paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/amex1.png'),fit: BoxFit.cover),height: 25));
    }else if(paymentMethod.brand == 'mastercard'){
      paymentMethod.icon = Tab(icon: Container(child: Image(image: AssetImage('ccimages/mastercard1.png'),fit: BoxFit.cover),height: 25));
    }

    return paymentMethod;
  }else {
    return null;
  }
}