import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/call_service_provider.dart';
import 'package:chats_ton/Providers/group_get_controller.dart';
import 'package:chats_ton/Providers/voice_call_provider.dart';
import 'package:chats_ton/UI/Pages/group_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:stream_video_flutter/stream_video_flutter.dart';

class GroupAudioCall extends StatefulWidget {
  final bool isVideo;
  final String groupId;
  final String messageId;
  final List<UserModel> members;
  const GroupAudioCall({
    Key? key,
    required this.isVideo,
    required this.members,
    required this.messageId,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupAudioCall> createState() => _GroupAudioCallState();
}

class _GroupAudioCallState extends State<GroupAudioCall> {
  @override
  void initState() {
    initlizeAudioCall();
    super.initState();
  }

  initlizeAudioCall() async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);
    final CallServiceProvider callService =
        Provider.of<CallServiceProvider>(context, listen: false);

    //     List<> groupModel =
    callService.initializeCall(widget.groupId, 'voice', userModel.userId,
        widget.messageId, userModel, widget.members);
  }

  bool dialogOpen = false;
  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final CallServiceProvider callService =
        Provider.of<CallServiceProvider>(context);
    final GroupService groupService = Provider.of<GroupService>(context);
    // call.setAudioOutputDevice(RtcMediaDevice(id: id, label: label, kind: kind));
    // widget.call.joinLobby();
    return Scaffold(
      body: StreamBuilder<GroupModel>(
          stream: groupService.groupStream(widget.groupId),
          builder: (context, snapshot) {
            GroupModel groupModel = snapshot.data!;
            Message callMessage = groupModel.messages.values
                .where((message) => message.messageId == widget.messageId)
                .first;

            return Stack(
              children: [
                SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: CachedNetworkImage(
                    imageUrl: groupModel.groupImage,
                    width: Get.width,
                    height: Get.height,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: Get.height,
                  width: Get.width,
                  color: Colors.black.withOpacity(0.4),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: CachedNetworkImage(
                                imageUrl: groupModel.groupImage,
                                fit: BoxFit.cover,
                                height: 126,
                                width: 126,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              groupModel.groupName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              callMessage.callMessageState,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: () {
                                callService.loudSpeaker();
                              },
                              child: Card(
                                color: callService.isLoudSpeaker
                                    ? app.changeColor(color: app.purpleColor)
                                    : Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200)),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: Center(
                                    child:
                                        SvgPicture.asset('assets/speaker.svg'),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: () => callService.endCall(),
                              child: Card(
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200)),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.call_end,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: () => callService.micOnOff(),
                              child: Card(
                                color: callService.isMicEnabled
                                    ? app.changeColor(color: app.purpleColor)
                                    : Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200)),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.mic_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
