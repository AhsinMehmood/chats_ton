import 'package:chats_ton/Global/color.dart';

import 'package:chats_ton/Models/user_model.dart';

import 'package:chats_ton/UI/Pages/my_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:status_view/status_view.dart';

class MyStatusCard extends StatelessWidget {
  const MyStatusCard({
    super.key,
    required this.context,
    // required this.statusModel,
  });

  final BuildContext context;
  // final List<StatusModel> statusModel;

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);

    // print(statusModel.length);
    // print(contactsProvider.userContacts.length);
    // UserModel secondUserModel = UserModel.fromJson({}, 'id');

    // UserModel otherUserProfile = contactsProvider.userContacts
    //     .where((element) => element.userId == statusModel.postedById)
    //     .toList()
    //     .first;

    AppColor app = AppColor();
    return InkWell(
      onTap: () {
        Get.to(() => const MyStatusView());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatusView(
            radius: 30,
            spacing: 15,
            strokeWidth: 2,
            indexOfSeenStatus: 0,
            numberOfStatus: userModel.statusList.length,
            padding: 3,
            centerImageUrl: userModel.imageUrl,
            seenColor: Colors.grey,
            unSeenColor: app.changeColor(color: 'FFC746'),
          ),
          Text(
            'My Status',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
