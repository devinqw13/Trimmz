import 'package:flutter/material.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/dialogs.dart';
import 'package:trimmz/Controller/ConversationController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/Model/Conversation.dart';
import 'dart:convert';
import 'package:trimmz/Controller/AppointmentRequestController.dart';
import 'package:trimmz/Model/Appointment.dart';
import 'package:trimmz/Controller/UserProfileController.dart';
import 'package:trimmz/Controller/UserProfileControllerV2.dart';
import 'package:intl/intl.dart';

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
    case "user_schedule": {
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

onCmdAction(BuildContext context, String cmdCode, {dynamic data}) async {
  switch(cmdCode) {
    case "drawer_apt_requests": {
      final appointmentRequestsController = new AppointmentRequestController(requests: data);
      Navigator.push(context, new MaterialPageRoute(builder: (context) => appointmentRequestsController));
      break;
    }
    case "drawer_messages": {
      var results = await getCached("conversations");
      
      final messagesController = new ConversationController(cachedConversations: results);
      Navigator.push(context, new MaterialPageRoute(builder: (context) => messagesController));
      break;
    }
    case "drawer_profile": {
      final userProfileController = new UserProfileController(token: globals.user.token);
      Navigator.push(context, new MaterialPageRoute(builder: (context) => userProfileController));
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

cacheData(String key, dynamic data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  switch(key) {
    case "conversations": {
      List<String> cachedConversations = [];
      List<String> cachedMessages = [];

      for(var item in data['conversations']){
        cachedConversations.add(json.encode(item));
      }
      for(var item in data['messages']){
        cachedMessages.add(json.encode(item));
      }
      prefs.setStringList("conversations", cachedConversations);
      prefs.setStringList("messages", cachedMessages);

      break;
    }
  }
}

Future<dynamic> getCached(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  switch(key) {
    case "conversations": {
      List conversations = [];
      List messages = [];

      var cachedConversations = prefs.getStringList("conversations") ?? [];
      var cachedMessages = prefs.getStringList("messages") ?? [];
      cachedConversations.forEach((element) {
        conversations.add(json.decode(element));
      });
      cachedMessages.forEach((element) {
        messages.add(json.decode(element));
      });

      var results = Conversations(conversations, messages);
      results.list.sort((a,b) => a.created.compareTo(b.created));
      return results.list;
    }
    default: {
      return null;
    }
  }
}

Future<dynamic> onWebSocketAction(String key, Map data, {dynamic other}) async {
  switch(key) {
    case "recieveMessage": {
      List<Conversation> conversations = other;
      Map newData = {
        "id": data['id'],
        "message": data['message'],
        "senderId": data['senderId'],
        "conversationId": data['conversationId'],
        "created": data['created']
      };

      var message = new Message(newData);

      conversations.where((element) => element.id == data['conversationId']).first.recentMessage = data['message'];

      conversations.where((element) => element.id == data['conversationId']).first.recentSenderId = data['senderId'];

      conversations.where((element) => element.id == data['conversationId']).first.messages.insert(0, message);

      return conversations;
    }
    default: {
      return data;
    }
  }
}

Future<Appointment> handleAppointmentStatus(BuildContext context, int status, int appointmentId) async {
  Appointment appointment = await appointmentHandler(context, globals.user.token, appointmentId, status);
  return appointment;
}

String formatTime(String time, bool showMinutes) {
  final df = DateTime.parse(DateFormat('Hms', 'en_US').parse(time).toString());
  String returnTime = "";
  if(df.minute > 0) {
    final i = new DateFormat('h:mma');
    returnTime = i.format(df);

  }else {
    final i = new DateFormat('ha');
    returnTime = i.format(df);
  }
  return returnTime;
}