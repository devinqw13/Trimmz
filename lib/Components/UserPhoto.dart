import 'package:flutter/material.dart';
import 'package:trimmz/Model/User.dart';

class UserPhoto extends StatelessWidget {
  const UserPhoto({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(User().photoUrl != '') {
      return Container();
    }else {
      return Container();
    }
  }
}