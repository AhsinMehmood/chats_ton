import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/status_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'circle_story_widget.dart';
import 'view_other_user_status.dart';

class OtherUserStatusCard extends StatelessWidget {
  const OtherUserStatusCard({
    super.key,
    required this.context,
    required this.statusModel,
    required this.userData,
  });

  final BuildContext context;
  final List<StatusModel> statusModel;
  final UserModel userData;
  bool isUserInViewerIds(List<StatusModel> statusList, String userId) {
    for (StatusModel status in statusList) {
      if (status.viewerIds.contains(userId)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    // final AppProvider appProvider = Provider.of<AppProvider>(context);
    // final ContactsProvider contactsProvider =
    //     Provider.of<ContactsProvider>(context);
    // int currentIndex = userData.statusList
    //     .indexWhere((status) => status.viewerIds.contains(userModel.userId));

    // print(statusModel.length);
    // print(contactsProvider.userContacts.length);
    // UserModel secondUserModel = UserModel.fromJson({}, 'id');

    // UserModel otherUserProfile = contactsProvider.userContacts
    //     .where((element) => element.userId == statusModel.postedById)
    //     .toList()
    //     .first;

    AppColor app = AppColor();

    // Use the indexWhere method to find the index of the first status with the current user's ID in viewerIds.
    int indexOfStatus = statusModel
        .indexWhere((status) => !status.viewerIds.contains(userModel.userId));

    if (indexOfStatus != -1) {
      print('Status found at index $indexOfStatus.');

      // indexOfStatus;
    } else {
      print('Status not found. $indexOfStatus');
    }
    if (indexOfStatus == -1) {
      // indexOfStatus = 0;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: InkWell(
        onTap: () {
          Get.to(() => OtherUserStatusView(
                statusList: userData.statusList,
                userData: userData,
              ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatusView(
              radius: 30,
              spacing: 15,
              strokeWidth: 2,
              indexOfSeenStatus: indexOfStatus,
              numberOfStatus: statusModel.length,
              padding: 3,
              centerImageUrl: userData.imageUrl,
              seenColor: Colors.grey,
              unSeenColor: app.changeColor(color: 'FFC746'),
            ),
            Text(
              userData.firstName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
