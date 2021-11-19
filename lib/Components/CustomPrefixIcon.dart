import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trimmz/SizeConfig.dart';

class CustomPrefixIcon extends StatelessWidget {
  const CustomPrefixIcon({
    Key key,
    @required this.svgIcon,
  }) : super(key: key);

  final String svgIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0, 
        getProportionateScreenWidth(0),
        getProportionateScreenWidth(0),
        getProportionateScreenWidth(0),
      ),
      child: SvgPicture.asset(
        svgIcon,
        height: getProportionateScreenWidth(8)
      ),
    );
  }
}