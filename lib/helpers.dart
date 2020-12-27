import 'package:flutter/material.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/dialogs.dart';
import 'package:trimmz/calls.dart';

setGlobals(Map results) async {
  globals.LoginUser user = new globals.LoginUser();
  user.token = results['user'][0]['id'];
  user.username = results['user'][0]['username'];
  user.name = results['user'][0]['name'];
  user.userEmail = results['user'][0]['email'];
  user.userAdmin = results['user'][0]['type'] == 3 ? true : false;
  user.userType = results['user'][0]['type'];
  user.profilePic = results['user'][0]['profile_picture'];
  user.shopName = results['user'][0]['shop_name'] ?? '';
  user.shopAddress = results['user'][0]['shop_address'];
  user.city = results['user'][0]['city'];
  user.state = results['user'][0]['state'];
  user.zipcode = results['user'][0]['zipcode'];

  globals.user = user;

  globals.StripeUser stripe = new globals.StripeUser();

  stripe.customerId = results['user'][0]['sp_customerid'];
  stripe.payoutId = results['user'][0]['payoutId'];
  stripe.accountId = results['user'][0]['sp_account'];
  stripe.paymentId = results['user'][0]['sp_paymentid'];
  stripe.payoutMethod = results['user'][0]['payoutMethod'] ?? 'standard';
}

Future<dynamic> buildMicroAppController(BuildContext context, DashboardItem item) async {
  switch (item.cmdCode) {
    case "Schedule": {
      showOkDialog(context, "OPENING MICRO APPLICATION");
      break;
    }
    default: {
      showErrorDialog(context, "An error has occurred", "Could not open '${item.name}'. Please try to login again.");
    }
  }
}

getStatusBar(int status, var time) {
  switch(status) {
    case 0: {
      var color;
      if(DateTime.now().isAfter(DateTime.parse(time))) {
        color = Colors.grey;
      }else {
        color = Colors.blue;
      }
      return color;
    }
    case 1: {
      return Colors.green;
    }
    case 2: {
      return Colors.red;
    }
    case 4: {
      return Colors.indigo;
    }
  }
}

onWebSocketAction(message) {
  var actionKey = message['key'];
  switch(actionKey) {
    case 'updateDashboardItems': {
      break;
    }
    case 'updateUserAppointments': {
      break;
    }
  }
}

onCmdAction(BuildContext context, String cmdCode) async {
  switch(cmdCode) {
    case "drawer_apt_requests": {
      //TODO: GO TO REQUEST PAGE.
    }
  }
}

buildCmdWidget(BuildContext context, String cmdCode, {dynamic data}) {
  switch(cmdCode) {
    case "drawer_apt_requests": {
      Widget widget;
      if(data != null) {
        widget = new Container(
          child: Text("5"),
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle
          ),
        );
      }else {
        widget = new Icon(Icons.keyboard_arrow_right);
      }

      return widget;
    }
    default: {
      Widget widget;
      if(data == "default") {
        widget =  new Icon(Icons.keyboard_arrow_right);
      }else if(data == null) {
        widget =  Container();
      }
      return widget;
    }
  }
}