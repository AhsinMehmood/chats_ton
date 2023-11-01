import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/status_provider.dart';
import 'package:chats_ton/UI/Widgets/add_status_card.dart';
import 'package:chats_ton/UI/Widgets/my_status_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Models/status_model.dart';
import '../../Providers/contacts_provider.dart';
import 'other_user_status_card.dart';

class StatusList extends StatelessWidget {
  const StatusList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);

    DateTime twentyFourHoursAgo =
        DateTime.now().subtract(const Duration(hours: 24));

    return Container(
      padding: const EdgeInsets.only(left: 10),
      height: 85,
      width: Get.width,
      // color: Colors.red,
      child: Row(
        children: [
          AddStatusCard(context: context),
          if (userModel.statusList.isNotEmpty) MyStatusCard(context: context),
          StreamBuilder<List<UserModel>>(
              stream: StatusProvider().statusStream(userModel.phoneNumber),
              builder: (context, AsyncSnapshot<List<UserModel>> snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                List<UserModel> usersWithRecentStatuses =
                    snapshot.data!.where((user) {
                  if (userModel.contacts.contains(user.phoneNumber)) {
                    return user.statusList.any((status) {
                      DateTime statusTime = DateTime.parse(status.timestamp);

                      bool isRecent = statusTime.isAfter(twentyFourHoursAgo);
                      bool isAllowedToSee =
                          status.contactsList.contains(userModel.phoneNumber);

                      if (isRecent && isAllowedToSee) {
                        return true;
                      } else {
                        return false;
                      }
                    });
                  } else {
                    return false;
                  }
                }).toList();
                // usersWithRecentStatuses.sort((a, b)=> a.statusList.any((element) => false));
                return Expanded(
                  child: ListView.builder(
                      itemCount: usersWithRecentStatuses.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        UserModel userDataStatus =
                            usersWithRecentStatuses[index];
                        List<StatusModel> userStatuses =
                            userDataStatus.statusList;
                        userStatuses
                            .sort((a, b) => a.timestamp.compareTo(b.timestamp));
                        return OtherUserStatusCard(
                            context: context,
                            statusModel: userStatuses,
                            userData: userDataStatus);
                      }),
                );
              }),
        ],
      ),
    );
  }
}
