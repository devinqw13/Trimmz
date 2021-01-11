import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/palette.dart';

class DashboardItem {
  int cmdID;
  String name;
  Widget icon;
  String cmdCode;
  bool defaultDashboard;
  bool defaultUserDrawer;
  bool defaultClientDrawer;
  bool isDashboard;
  int sort;
  int listNumber;

  DashboardItem(Map input) {
    this.cmdID = input['id'];
    this.cmdCode = input['cmd_code'];
    this.name = input['cmd_name'];
    this.defaultDashboard = input['default_dashboard'] == 1 ? true : false;
    this.defaultUserDrawer = input ['default_user_drawer'] == 1 ? true : false;
    this.defaultClientDrawer = input ['default_client_drawer'] == 1 ? true : false;
    this.isDashboard = input ['is_dashboard'] == 1 ? true : false;
    this.sort = input['sort'];
    this.listNumber = input['list_number'];

    if(input['icon'] != null) {
      if(input['default_icon_type'] == 0) {
        icon = new Icon(
          IconData(
            int.parse(input['icon']),
            fontFamily: 'MaterialIcons'
          ),
          size: 80,
          color: globals.darkModeEnabled ? Colors.white : darkBackgroundGrey
        );
      }else {
        icon = new Image.network(
          "${globals.baseImageUrl}${input['icon']}", 
        );
      }
    }else {
      icon = new Container();
    }
  }
}