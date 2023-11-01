import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/chats_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Pages/message_page.dart';

class ChatsCard extends StatelessWidget {
  final ChatsModel chatsModel;
  const ChatsCard({
    super.key,
    required this.chatsModel,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    DateTime timestamp =
        DateTime.parse(chatsModel.timestamp); // Replace with your timestamp
    String formattedTime = timeago.format(timestamp, allowFromNow: true);

    AppColor app = AppColor();
    return ListTile(
      onTap: () {
        // Get.to(() => MessagePage(
        //     // chatId: chatsModel.chatId,
        //     // secondUserId: chatsModel.conversationModel.receiverId,
        //     ));
      },
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: CachedNetworkImage(
              imageUrl: chatsModel.secondUserData.imageUrl,
              height: 52,
              width: 52,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: chatsModel.secondUserData.activeStatus == 'Active'
                        ? Colors.green
                        : Colors.yellow),
              ))
        ],
      ),
      title: Text(
        '${chatsModel.secondUserData.firstName} ${chatsModel.secondUserData.lastName}',
        style: GoogleFonts.poppins(
          color: app.changeColor(color: '000E08'),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        chatsModel.conversationModel.text,
        style: GoogleFonts.poppins(
          color: app.changeColor(color: '797C7B'),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formattedTime,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: app.changeColor(color: '797C7B'),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: app.changeColor(color: '925FE2'),
              ),
              width: 22,
              child: Center(
                  child: Text(
                chatsModel.secondUsernreadMessages.length.toString(),
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ))),
        ],
      ),
    );
  }
}
