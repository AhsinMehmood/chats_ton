import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BigButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;
  const BigButton(
      {super.key,
      required this.color,
      required this.text,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.8,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color,
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
