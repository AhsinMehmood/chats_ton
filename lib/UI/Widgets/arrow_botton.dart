import 'package:chats_ton/Global/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ArrowButton extends StatelessWidget {
  final Color color;
  final String icon;

  const ArrowButton({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2.0,
      shadowColor: AppColor().changeColor(color: AppColor().purpleColor),
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: color),
        child: Center(
          child: SvgPicture.asset(icon),
        ),
      ),
    );
  }
}
