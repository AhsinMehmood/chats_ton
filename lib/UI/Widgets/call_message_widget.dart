import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/conversation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CallMessageWidget extends StatelessWidget {
  final ConversationModel message;
  const CallMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.parse(message.timestamp);
    String formattedTime = DateFormat.jm().format(now);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          // width: 70,
          // width: Get.width * 0.6,

          margin: const EdgeInsets.only(left: 20, right: 20),
          // padding:
          //     const EdgeInsets.only(left: 20, right: 20, bottom: 4, top: 4),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 4, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(Icons.call_missed, ),
                  Text(
                    message.messageStatus,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColor().changeColor(
                          color: '797C7B',
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    formattedTime,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColor().changeColor(
                          color: '797C7B',
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
