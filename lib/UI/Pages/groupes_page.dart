import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/UI/Pages/create_group_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Providers/group_get_controller.dart';
import '../../Models/user_model.dart';
import 'group_message_page.dart';
import 'message_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class GroupesPages extends StatefulWidget {
  const GroupesPages({super.key});

  @override
  State<GroupesPages> createState() => _GroupesPagesState();
}

class _GroupesPagesState extends State<GroupesPages> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    // getData();
  }

  @override
  Widget build(BuildContext context) {
    AppColor app = AppColor();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Get.height,
            padding: const EdgeInsets.all(13),
            width: Get.width,
            color: app.changeColor(color: app.purpleColor),
            child: upperCard(context),
          ),
          Positioned(
            top: 100,
            child: Container(
              height: Get.height,
              padding: const EdgeInsets.all(10),
              width: Get.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: lowerCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget lowerCard(context) {
    // final List<GroupModel> groups =
    //     Provider.of<GroupController>(context).groups;
    final UserModel userModel = Provider.of<UserModel>(context);

    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'My Groups',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Expanded(
            child: StreamBuilder<List<GroupModel>>(
          stream: GroupService().getGroupListStream(userModel.userId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final groups = snapshot.data ?? [];
              if (groups.isEmpty) {
                return const Center(child: Text('No Groups Yet!'));
              }
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];

                  return groupsChatCard(group);
                },
              );
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No Groups Yet!'));
            } else {
              return const CircularProgressIndicator();
            }
          },
        )),
      ],
    );
  }

  Widget groupsChatCard(GroupModel groupModel) {
    final UserModel userModel = Provider.of<UserModel>(context);

    final lastMessage = groupModel.getLastMessage();
    final int unreadCount = groupModel.getUnreadMessageCount(userModel.userId);

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
      child: ListTile(
        onTap: () {
          Get.to(() => GroupChannelPage(
                groupModel: groupModel,
              ));
          for (Message element in groupModel.messages.values) {
            if (element.senderId != userModel.userId) {
              if (element.status != 'read') {
                GroupService().updateMessageStatus(
                    element.messageId, groupModel.groupChatId, 'read');
              }
            }
          }
        },
        // isThreeLine: true,
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(250),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(250),
            child: CachedNetworkImage(
              imageUrl: groupModel.groupImage,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          groupModel.groupName,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeago.format(
                DateTime.fromMillisecondsSinceEpoch(
                    lastMessage == null ? 0 : lastMessage.timestamp * 1000),
              ),
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 10),
            ),
            unreadCount == 0
                ? const SizedBox(
                    height: 18,
                    width: 18,
                  )
                : Container(
                    height: 18,
                    width: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(200),
                    ),
                    padding: const EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        unreadCount.toString(),
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
          ],
        ),
        subtitle: Text(
          lastMessage == null ? '' : lastMessage.text,
          maxLines: 1,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w400,
              color: AppColor().changeColor(color: '797C7B')),
        ),
      ),
    );
  }

  Widget upperCard(context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.search,
              color: Colors.white,
            ),
            Text(
              'Groups',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => const CreateGroupPage());
              },
              icon: const Icon(
                Icons.add,
              ),
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}
