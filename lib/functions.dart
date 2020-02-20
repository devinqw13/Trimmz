import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

setGlobals(Map results) async {
  globals.LoginUser user = new globals.LoginUser();
  user.token = results['user'][0]['id'];
  user.username = results['user'][0]['username'];
  user.name = results['user'][0]['name'];
  user.userEmail = results['user'][0]['email'];
  user.userAdmin = results['user'][0]['type'] == 3 ? true : false;
  user.userType = results['user'][0]['type'];
  user.spCustomerId = results['user'][0]['sp_customerid'];
  user.spPayoutId = results['user'][0]['payoutId'];
  user.spPaymentId = results['user'][0]['sp_paymentid'];
  user.spPayoutMethod = results['user'][0]['payoutMethod'] ?? 'standard';
  user.profilePic = results['user'][0]['profile_picture'];

  user.shopName = results['user'][0]['shop_name'] ?? '';
  user.shopAddress = results['user'][0]['shop_address'];
  user.city = results['user'][0]['city'];
  user.state = results['user'][0]['state'];

  globals.user = user;
  globals.token = user.token;
  globals.username = user.username;
  globals.name = user.name;
  globals.email = user.userEmail;
  globals.userAdmin = user.userAdmin;
  globals.userType = user.userType;
  globals.spCustomerId = user.spCustomerId;
  globals.spPayoutId = user.spPayoutId;
  globals.spPaymentId = user.spPaymentId;
  globals.spPayoutMethod = user.spPayoutMethod;

  globals.shopName = user.shopName;
  globals.shopAddress = user.shopAddress;
  globals.city = user.city;
  globals.state = user.state;

  globals.profilePic = user.profilePic;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? true : prefs.getBool('darkModeEnabled');
  if (globals.darkModeEnabled) {
    globals.userBrightness = Brightness.dark;
    globals.userColor = Color.fromARGB(255, 0, 0, 0); //20
  }
  else {
    globals.userBrightness = Brightness.light;
    globals.userColor = Color.fromARGB(255, 255, 255, 255);
  }

  prefs.setInt('userToken', globals.user.token);
  prefs.setString('userUsername', globals.user.username);
  prefs.setString('userName', globals.user.name);
  prefs.setString('userUserEmail', globals.user.userEmail);
  prefs.setBool('userIsAdmin', globals.user.userAdmin);
  prefs.setInt('userType', globals.user.userType);
  prefs.setString('spCustomerId', globals.user.spCustomerId);
  prefs.setString('spPayoutId', globals.user.spPayoutId);
  prefs.setString('spPaymentId', globals.user.spPaymentId);
  prefs.setString('spPayoutMethod', globals.user.spPayoutMethod);

  prefs.setString('shopName', globals.user.shopName);
  prefs.setString('shopAddress', globals.user.shopAddress);
  prefs.setString('city', globals.user.city);
  prefs.setString('state', globals.user.state);

  prefs.setString('profilePic', globals.user.profilePic);
}

getUserLocation() async {
  return await _getCurrentLocation();
}

_getCurrentLocation() async {
  Position _currentPosition;
  List location;
  await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low).then((Position position) async {
    _currentPosition = position;
    var result = await _getAddressFromLatLng(_currentPosition);
    location = result;
    return result;
  }).catchError((e) {
    print(e);
  });
  return location;
}

getCurrentLocation() async {
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  return position;
}

_getAddressFromLatLng(Position currentPosition) async {
  List _currentAddress;
  try {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(currentPosition.latitude, currentPosition.longitude);
    Placemark place = p[0];
    _currentAddress = [place.locality, place.administrativeArea, place.postalCode];
    return _currentAddress;
  } catch (e) {
    print(e);
  }
}

Future<String> getDistanceFromBarber(String shopLocation) async {
  var endPosition = await getEndLocation(shopLocation);
  var meters = await geolocator.distanceBetween(globals.currentLocation.latitude, globals.currentLocation.longitude, endPosition.latitude, endPosition.longitude);

  var distance = (meters * 0.000621).toStringAsFixed(1);
  return distance;
}

getStartLocation() async {
  Position _currentPosition;
  await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) async {
    _currentPosition = position;
  }).catchError((e) {
    print(e);
  });
  return _currentPosition;
}

getEndLocation(String shopLocation) async {
  Position endDistance;
  List<Placemark> p = await geolocator.placemarkFromAddress(shopLocation);
  for(var item in p) {
    endDistance = item.position;
  }
  return endDistance;
}

buildTimeAgo(String dateString, {bool numericDates = true}) {
  DateTime date = DateTime.parse(dateString);
  final date2 = DateTime.now();
  final difference = date2.difference(date);

  if ((difference.inDays / 365).floor() >= 2) {
    return Text('${(difference.inDays / 365).floor()}yr', style: TextStyle(fontSize: 13));
  } else if ((difference.inDays / 365).floor() >= 1) {
    return (numericDates) ? Text('1yr', style: TextStyle(fontSize: 13)) : Text('Last year', style: TextStyle(fontSize: 13));
  } else if ((difference.inDays / 30).floor() >= 2) {
    return Text('${((difference.inDays / 365) * 10).floor()}mo', style: TextStyle(fontSize: 13));
  } else if ((difference.inDays / 30).floor() >= 1) {
    return (numericDates) ? Text('1mo', style: TextStyle(fontSize: 13)) : Text('Last month', style: TextStyle(fontSize: 13));
  } else if ((difference.inDays / 7).floor() >= 2) {
    return Text('${(difference.inDays / 7).floor()}w', style: TextStyle(fontSize: 13));
  } else if ((difference.inDays / 7).floor() >= 1) {
    return (numericDates) ? Text('1w', style: TextStyle(fontSize: 13)) : Text('Last week', style: TextStyle(fontSize: 13));
  } else if (difference.inDays >= 2) {
    return Text('${difference.inDays}d', style: TextStyle(fontSize: 13));
  } else if (difference.inDays >= 1) {
    return (numericDates) ? Text('1d', style: TextStyle(fontSize: 13)) : Text('Yesterday', style: TextStyle(fontSize: 13));
  } else if (difference.inHours >= 2) {
    return Text('${difference.inHours}h', style: TextStyle(fontSize: 13));
  } else if (difference.inHours >= 1) {
    return (numericDates) ? Text('1h', style: TextStyle(fontSize: 13)) : Text('An hour ago', style: TextStyle(fontSize: 13));
  } else if (difference.inMinutes >= 2) {
    return Text('${difference.inMinutes}m', style: TextStyle(fontSize: 13));
  } else if (difference.inMinutes >= 1) {
    return (numericDates) ? Text('1m', style: TextStyle(fontSize: 13)) : Text('A minute ago', style: TextStyle(fontSize: 13));
  } else if (difference.inSeconds >= 3) {
    return Text('${difference.inSeconds}s', style: TextStyle(fontSize: 13));
  } else {
    return Text('Just now', style: TextStyle(fontSize: 13));
  }
}

validateAddress(String address) async {
  try {
    await geolocator.placemarkFromAddress(address);
    return true;
  } on Exception {
    print(Exception);
    return false;
  }
}