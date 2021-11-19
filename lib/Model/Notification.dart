import 'package:flutter/material.dart';

class Notification {
  int key;
  String title;
  String message;
  String photoURL;
  String source;
  bool read;
  DateTime time;

  Notification(Map<String, dynamic> input) {
    this.key = input['id'];
    this.title = input['title'];
    this.message = input['message'];
    this.photoURL = input['profile_picture'];
    this.source = input['source'];
    this.read = input['read'] == 1 ? true : false;
  }
}

class Notifications extends ChangeNotifier {
  static final Notifications _notifications = Notifications._();
  List<Notification> notifications = [];

  factory Notifications() => _notifications;

  Notifications._();

  void onChange() {
    notifyListeners();
  }
}