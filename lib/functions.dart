import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

setGlobals(Map results) async {
  globals.LoginUser user = new globals.LoginUser();
  user.token = results['user']['id'];
  user.username = results['user']['username'];
  user.name = results['user']['name'];
  user.userEmail = results['user']['email'];
  user.userAdmin = results['user']['type'] == 3 ? true : false;
  user.userType = results['user']['type'];

  globals.user = user;
  globals.token = user.token;
  globals.username = user.username;
  globals.name = user.name;
  globals.email = user.userEmail;
  globals.userAdmin = user.userAdmin;
  globals.userType = user.userType;

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
}

getUserLocation() async {
  return await _getCurrentLocation();
}

_getCurrentLocation() async {
  Position _currentPosition;
  List location;
  await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) async {
    _currentPosition = position;
    var result = await _getAddressFromLatLng(_currentPosition);
    location = result;
    return result;
  }).catchError((e) {
    print(e);
  });
  return location;
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
  var currentPosition = await getStartLocation();
  var endPosition = await getEndLocation(shopLocation);
  var meters = await geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude, endPosition.latitude, endPosition.longitude);

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