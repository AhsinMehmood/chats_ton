import 'package:flutter/material.dart';

class AppColor {
  // Parse the hex color and create a Color object
  Color changeColor({required String color}) {
    String hexColor = color;

    if (hexColor[0] == '#') {
      hexColor = hexColor.substring(1);
    }

    Color myColor = Color(int.parse('0xFF$hexColor'));
    return myColor;
  }

  final String purpleColor = '#925FE2';
  final String purpleColorDim = 'B390EB';
}
