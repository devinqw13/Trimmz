import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  static final User _user = User._();
  int userKey;
  int userType;
  String name = '';
  String username = '';
  String email = '';
  String phone = '';
  String photoUrl = '';

  factory User() => _user;

  User._();

  void onChange() {
    notifyListeners();
  }

  clear() {
    this.userKey = 0;
    this.name = "";
    this.email = "";
    this.phone = "";
    this.photoUrl = "";
  }
}