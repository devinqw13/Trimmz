import 'package:flutter/material.dart';
import 'package:trimmz/Components/CustomSuffixIcon.dart';
import 'package:trimmz/Components/DefaultButton.dart';
import 'package:trimmz/Components/FormError.dart';
import 'package:trimmz/Constants.dart';
import 'package:trimmz/Helpers/Keyboard.dart';
import 'package:trimmz/SizeConfig.dart';

class SignInForm extends StatefulWidget {
  final Function dismissProgressHUD;
  final Function signInWithEmail;
  final Function showForgotPassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  SignInForm({
    @required this.dismissProgressHUD,
    @required this.signInWithEmail,
    @required this.showForgotPassword,
    @required this.emailController,
    @required this.passwordController
  });

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  void addError({String error = ''}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String error = ''}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(widget.emailController),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(widget.passwordController),
          SizedBox(height: getProportionateScreenHeight(20)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(10)),
          DefaultButton(
            text: "Login",
            textStyle: TextStyle(
            fontSize: getProportionateScreenWidth(16),
              color: Colors.white
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                KeyboardUtil.hideKeyboard(context);
                if(errors.length == 0) {
                  widget.signInWithEmail();
                }
              }
            }
          ),
          SizedBox(height: getProportionateScreenHeight(25)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  widget.showForgotPassword();
                },
                child: Text(
                  "Signup",
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.showForgotPassword();
                },
                child: Text(
                  "Forgot Password?",
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPasswordFormField(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.only(left: getProportionateScreenHeight(20)),
      decoration:  BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: true,
        controller: controller,
        onChanged: (value) {
          if (value.isNotEmpty) {
            removeError(error: kPassNullError);
          } else if (value.length >= 8) {
            removeError(error: kShortPassError);
          }
          return null;
        },
        validator: (value) {
          if (value.isEmpty) {
            addError(error: kPassNullError);
            return null;
          } else if (value.length < 8) {
            addError(error: kShortPassError);
            return null;
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "Password",
          // filled: true,
          // fillColor: Colors.white,
          hintText: "Enter your password",
          // hintStyle: TextStyle(color: kTextColor),
          // If  you are using latest version of flutter then lable text and hint text shown like this
          // if you r using flutter less then 1.20.* then maybe this is not working properly
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Lock.svg"),
        ),
      )
    );
  }

  Widget buildEmailFormField(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.only(left: getProportionateScreenHeight(20)),
      decoration:  BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: controller,
        autocorrect: false,
        onChanged: (value) {
          if (value.isNotEmpty) {
            removeError(error: kEmailNullError);
          } else if (value.length < 4) {
            removeError(error: kInvalidEmailError);
          }
          return null;
        },
        validator: (value) {
          if (value.isEmpty) {
            addError(error: kEmailNullError);
            return null;
          } else if (value.length < 4) {
            addError(error: kInvalidEmailError);
            return null;
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: "Email or username",
          // filled: true,
          // fillColor: Colors.white,
          hintText: "Email or username",
          // hintStyle: TextStyle(color: kTextColor),
          // If  you are using latest version of flutter then lable text and hint text shown like this
          // if you r using flutter less then 1.20.* then maybe this is not working properly
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: CustomSuffixIcon(svgIcon: "assets/icons/Mail.svg"),
        ),
      )
    );
  }
}