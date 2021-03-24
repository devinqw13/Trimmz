import 'package:flutter/material.dart';
import 'package:trimmz/Controller/AvailabilityController.dart';
import 'package:trimmz/calls.dart';
import 'package:trimmz/globals.dart' as globals;
import 'package:trimmz/Model/DashboardItem.dart';
import 'package:trimmz/Controller/ConversationController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trimmz/Model/Conversation.dart';
import 'dart:convert';
import 'package:trimmz/Controller/AppointmentRequestController.dart';
import 'package:trimmz/Controller/UserProfileController.dart';
import 'package:trimmz/Controller/ScheduleController.dart';
import 'package:intl/intl.dart';
import 'package:trimmz/Controller/ServicesController.dart';
import 'package:trimmz/Controller/SettingsController.dart';
import 'package:trimmz/Controller/SelectUserBookAppointment.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

setGlobals(Map results) async {
  globals.LoginUser user = new globals.LoginUser();
  user.token = results['user'][0]['id'];
  user.username = results['user'][0]['username'];
  user.name = results['user'][0]['name'];
  user.userEmail = results['user'][0]['email'];
  user.userAdmin = results['user'][0]['type'] == 3 ? true : false;
  user.userType = results['user'][0]['type'];
  user.profilePic = results['user'][0]['profile_picture'];
  user.headerPicture = results['user'][0]['header_image'];
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
  stripe.paymentMethodType = results['user'][0]['payoutMethod'] ?? 'standard';

  globals.stripe = stripe;

  globals.strpk = results['strpk'];

  globals.processingFee = results['processingFee'] ?? 1.00;
  globals.standardPayoutFee = results['standardPayoutFee'] ?? 0.028;
  globals.instantPayoutFee = results['instantPayoutFee'] ?? 0.032;
}

Future<dynamic> buildMicroAppController(BuildContext context, DashboardItem item, {dynamic data}) async {
  switch (item.cmdCode) {
    case "user_schedule": {
      return new ScheduleController(calendarAppointments: data);
    }
    case "user_services": {
      var services = await getServices(context, globals.user.token);
      return new ServicesController(services: services, screenHeight: data);
    }
    case "user_availability": {
      var availability = await getAvailability(context, globals.user.token);
      return new AvailabilityController(availability: availability);
    }
    case "drawer_settings": {
      return new SettingsController();
    }
    case "drawer_apt_requests": {
      return new AppointmentRequestController(requests: data);
    }
    case "drawer_messages": {
      var results = await getCached("conversations");
      return new ConversationController(cachedConversations: results, screenHeight: MediaQuery.of(context).size.height);
    }
    case "drawer_book_appointment": {
      return new SelectUserBookAppointmentController(token: globals.user.token);
    }
    case "drawer_profile": {
      return new UserProfileController(token: globals.user.token);
    }
    default: {
      return;
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
    case 3: {
      return Colors.grey;
    }
    case 4: {
      return Colors.purple[300];
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

Widget buildSmallUserProfilePicture(BuildContext context, String profilePicture, String name) {
  if(profilePicture != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: new Image.network('${globals.baseImageUrl}$profilePicture',
        height: 35.0,
        fit: BoxFit.fill,
      )
    );
  }else {
    return Container(
      child: CircleAvatar(
        child: Center(child:Text(name.substring(0,1).toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 15))),
        radius: 17.5,
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
    case "newConversation": {
      List<Conversation> conversations = other;

      //Convert values to int datatype
      data['conversation']['user_Id'] = int.parse(data['conversation']['user_Id']);
      data['conversation']['recent_sender_id'] = int.parse(data['conversation']['recent_sender_id']);
      data['conversation']['read_conversation'] = int.parse(data['conversation']['read_conversation']);
      data['message'][0]['senderId'] = int.parse(data['message'][0]['senderId']);

      //json name parameter returning as list (ISSUE)
      data['conversation']['name'] = data['conversation']['name'][0];

      var conversation = new Conversation(data['conversation'], data['message']);

      conversations.add(conversation);

      return conversations;
    }
    default: {
      return data;
    }
  }
}

// Future<Appointment> handleAppointmentStatus(BuildContext context, int status, int appointmentId) async {
//   Appointment appointment = await appointmentHandler(context, globals.user.token, appointmentId, status);
//   return appointment;
// }

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

Future<Position> _getPositionCoordinates() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error(
          'Location permissions are denied');
    }
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
}

Future<Placemark> determinePosition() async {
  Position position = await _getPositionCoordinates();
  try {
   List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
   
   return placemarks.first;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<int> getCurrentLocationZipcode() async  {
  var results = await determinePosition();
  return int.parse(results.postalCode);
}