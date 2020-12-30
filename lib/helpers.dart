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

Widget buildUserProfilePicture(BuildContext context, String profilePicture, String name) {
  if(profilePicture != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: new Image.network('${globals.baseImageUrl}$profilePicture',
        height: 60.0,
        fit: BoxFit.fill,
      )
    );
  }else {
    return Container(
      child: CircleAvatar(
        child: Center(child:Text(name.substring(0,1).toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 25))),
        radius: 30,
        backgroundColor: Colors.transparent,
      ),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: globals.darkModeEnabled ? Colors.black : Colors.white,
        gradient: new LinearGradient(
          colors: [Color(0xFFF9F295), Color(0xFFB88A44)]
        )
      ),
    );
  }
}