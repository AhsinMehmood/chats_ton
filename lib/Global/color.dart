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

/// document will be added
class AppColors {
  //* Pink.
  static const Color pink = Color(0xFFFF4550);
  static Color pink100 = pink.withOpacity(.1);
  static Color pink300 = pink.withOpacity(.3);
  static Color pink400 = pink.withOpacity(.4);
}
