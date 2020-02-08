import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Controller/LoginController.dart';
import 'Controller/HomeHubController.dart';
import 'Controller/BarberHubController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  globals.baseUrl = "https://trimmz.app/dev_api/";
  globals.stripeURL = "https://api.stripe.com/v1/";
  globals.stripeSecretKey = "sk_test_5h8VY4cc8ZUKHpIHO0TQWNkN00KJNxvrgY";
  globals.stripePublishablekey = "pk_test_X7T99aRCpPlsEHCjm7TOHnuO00JlKLGdal";
  globals.stripeMerchantId = "Test";
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var token = prefs.getInt('userToken');
  globals.LoginUser user;
  if(token != null){
    user = new globals.LoginUser();
    user.token = prefs.getInt('userToken');
    user.username = prefs.getString('userUsername');
    user.name = prefs.getString('userName');
    user.userEmail = prefs.getString('userUserEmail');
    user.userAdmin = prefs.getBool('userIsAdmin');
    user.userType = prefs.getInt('userType');
    user.spCustomerId = prefs.getString('spCustomerId');
    user.spPayoutId = prefs.getString('spPayoutId');
    user.spPaymentId = prefs.getString('spPaymentId');
    user.spPayoutMethod= prefs.getString('spPayoutMethod');
    user.profilePic = prefs.getString('profilePic');

    user.shopName = prefs.getString('shopName');
    user.shopAddress = prefs.getString('shopAddress');
    user.city = prefs.getString('city');
    user.state = prefs.getString('state');

    globals.user = user;
    globals.token = user.token;
    globals.username = user.username;
    globals.name = user.name;
    globals.email = user.userEmail;
    globals.userAdmin = user.userAdmin == true ? true : false;
    globals.userType = user.userType;
    globals.spCustomerId = user.spCustomerId;
    globals.spPayoutId = user.spPayoutId;
    globals.spPaymentId = user.spPaymentId;
    globals.spPayoutMethod = user.spPayoutMethod;
    globals.profilePic = user.profilePic;

    globals.shopAddress = user.shopAddress;
    globals.shopName = user.shopName;
    globals.city = user.city;
    globals.state = user.state;

    globals.darkModeEnabled = prefs.getBool('darkModeEnabled') == null ? true : prefs.getBool('darkModeEnabled');
    if (globals.darkModeEnabled) {
      globals.userBrightness = Brightness.dark;
      globals.userColor = Color.fromARGB(255, 0, 0, 0);
    }
    else {
      globals.userBrightness = Brightness.light;
      globals.userColor = lightBackgroundWhite;
    }
  }

  runApp(
    new MaterialApp(
      title: 'Trimmz',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => token == null ? new LoginScreen() : globals.userType == 2 ? BarberHubScreen() : HomeHubScreen(),
      },
      theme: new ThemeData(
        primaryColor: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black87
      )
    )
  );
}