import 'package:flutter/material.dart';
import 'package:trimmz/Constants.dart';
import 'package:trimmz/Globals.dart' as globals;
import 'package:trimmz/SizeConfig.dart';
import 'package:trimmz/Calls.dart';
import 'package:trimmz/Screens/LoginScreen/Components/SignInForm.dart';
import 'package:trimmz/Screens/DashboardScreen/DashboardScreen.dart';
import 'package:trimmz/Model/User.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Body extends StatefulWidget {
  final Function dismissProgressHUD;

  Body({
    @required this.dismissProgressHUD
  });

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  goToForgotPassword() {
    // ForgotPasswordScreen forgotPasswordScreen = ForgotPasswordScreen(analytics: widget.analytics, observer: widget.observer);
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => forgotPasswordScreen));
  }

  signInWithEmail() async {
    widget.dismissProgressHUD();
    try {
      await userLogin(emailController.text, passwordController.text);
    } catch (e) {
      //TODO: SHOW SCREENERROR FADE MESSAGE
    }
    widget.dismissProgressHUD();
    if (User() != null) {
      DashboardScreen dashboardScreen = DashboardScreen();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => dashboardScreen));
    }
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                SvgPicture.asset(
                  "assets/icons/User.svg",
                  height: getProportionateScreenWidth(100),
                  width: getProportionateScreenWidth(100),
                  color: primaryBlue,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.18),
                SignInForm(dismissProgressHUD: widget.dismissProgressHUD, signInWithEmail: signInWithEmail, showForgotPassword: goToForgotPassword, emailController: emailController, passwordController: passwordController),
              ],
            ),
          ),
        )
      ),
    );
  }
}