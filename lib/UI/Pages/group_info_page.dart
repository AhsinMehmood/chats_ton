import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/Providers/group_get_controller.dart';
import 'package:chats_ton/UI/Calling/video_calling_page.dart';
import 'package:chats_ton/UI/Pages/group_access.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Models/user_model.dart';
import '../Calling/voice_calling_page.dart';

class GroupInfoPage extends StatefulWidget {
  final GroupModel groupModel;
  final List<UserModel> membersData;
  const GroupInfoPage(
      {super.key, required this.groupModel, required this.membersData});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  AppColor app = AppColor();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app.changeColor(color: app.purpleColor),
      body: Stack(
        children: [
          upperContainer(),
          Align(
            child: lowerCard(),
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }

  lowerCard() {
    List<Member> members = [];

    widget.groupModel.members.forEach((key, value) {
      members.add(value);
    });
    UserModel userModel = Provider.of<UserModel>(context);
    return Container(
      height: Get.height * 0.6,
      padding: const EdgeInsets.all(15),
      width: Get.width,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          )),
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 3,
            width: 30,
            decoration: BoxDecoration(
              color: app.changeColor(color: 'E6E6E6'),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     'Description',
          //     style: GoogleFonts.poppins(
          //       color: app.changeColor(color: '797C7B'),
          //       fontSize: 14,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     'Family Members group chat Here',
          //     style: GoogleFonts.poppins(
          //       color: Colors.black,
          //       fontSize: 16,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group Members',
                style: GoogleFonts.poppins(
                  color: app.changeColor(color: app.purpleColor),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                members.length.toString(),
                style: GoogleFonts.poppins(
                  color: app.changeColor(color: app.purpleColor),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: widget.membersData.length,
                  // padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final Member member = members[index];
                    return StreamBuilder<UserModel>(
                        initialData: widget.membersData[index],
                        stream: memberStream(member.memberId),
                        builder: (context, AsyncSnapshot<UserModel> snapshot) {
                          UserModel memberUserModel = snapshot.data!;
                          return Column(
                            children: [
                              ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(200),
                                  child: CachedNetworkImage(
                                    imageUrl: memberUserModel.imageUrl,
                                    height: 52,
                                    width: 52,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  '${memberUserModel.firstName} ${memberUserModel.lastName}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Text(member.role),
                                subtitle: Text(memberUserModel.bio),
                              ),
                            ],
                          );
                        });
                  }))
        ],
      ),
    );
  }

  Stream<UserModel> memberStream(String memberId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(memberId)
        .snapshots()
        .map((event) => UserModel.fromJson(event.data()!, event.id));
  }

  upperContainer() {
    UserModel userModel = Provider.of<UserModel>(context);
    GroupService groupService = GroupService();
    return Container(
      height: Get.height,
      width: Get.width,
      decoration: BoxDecoration(
        color: app.changeColor(color: app.purpleColor),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: CachedNetworkImage(
                      imageUrl: widget.groupModel.groupImage,
                      height: 82,
                      width: 82,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.groupModel.groupName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'ID: ${widget.groupModel.id}',
                    style: GoogleFonts.poppins(
                      color: app.changeColor(color: 'C7BEBE'),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.white,
                        ),
                        child: IconButton(
                            onPressed: () async {
                              String messageId = await groupService.sendMessage(
                                  widget.groupModel.groupChatId,
                                  'Calling...',
                                  userModel.userId,
                                  'call',
                                  widget.membersData,
                                  userModel,
                                  widget.groupModel);
                              Get.to(() => GroupAudioCall(
                                    isVideo: false,
                                    messageId: messageId,
                                    groupId: widget.groupModel.groupChatId,
                                    members: widget.membersData,
                                  ));
                            },
                            icon: SvgPicture.asset(
                              'assets/call_icon.svg',
                              color: app.changeColor(color: app.purpleColor),
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            Get.to(() => VideoCallPage(
                                  groupId: widget.groupModel.groupChatId,
                                ));
                          },
                          icon: SvgPicture.asset(
                            'assets/Video_icon.svg',
                            color: app.changeColor(color: app.purpleColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.to(() => GroupAcces(
                            group: widget.groupModel,
                            membersData: widget.membersData));
                      },
                      icon: const Icon(
                        Icons.more_vert_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
