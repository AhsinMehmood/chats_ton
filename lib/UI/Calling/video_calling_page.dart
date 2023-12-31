import 'package:chats_ton/Models/group_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show AppBar, BuildContext, Key, Scaffold, State, StatefulWidget, Widget
    show AppBar, BuildContext, Key, Scaffold, State, StatefulWidget, Widget;
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

import '../../Models/user_model.dart';
import '../../Providers/voice_call_provider.dart';

class VideoCallPage extends StatefulWidget {
  final String groupId;

  const VideoCallPage({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late Call call;
  bool callInitialized = false;
  @override
  void initState() {
    initlizeAudioCall();
    super.initState();
  }

  initlizeAudioCall() async {
    final UserModel userModel = Provider.of<UserModel>(context, listen: false);

    // final channel = StreamChannel.of(context).channel;
    call = StreamVideo.instance.makeCall(type: 'video', id: widget.groupId);
    await call.getOrCreate(participantIds: [userModel.userId]).then((value) {
      setState(() {
        callInitialized = true;
      });
    });

    // List<Member> withoutCurrentUserMamaber = widget.
    //     .where((element) => element.userId != userModel.userId)
    //     .toList();

    // for (Member element in withoutCurrentUserMamaber) {
    //   await VoiceCallProvider().sendCallNotification(
    //       element.user!.extraData['pushToken'].toString(),
    //       userModel,
    //       widget.channelId,
    //       'video');
    // }
  }

  notifyMembers() async {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: callInitialized
          ? StreamCallContainer(
              call: call,
              // outgoingCallBuilder: (context, call, callState) {
              //   return Scaffold(
              //     appBar: AppBar(),
              //   );
              // },

              callContentBuilder: (
                BuildContext context,
                Call call,
                CallState callState,
              ) {
                return StreamCallContent(
                  call: call,
                  callState: callState,
                  callControlsBuilder: (
                    BuildContext context,
                    Call call,
                    CallState callState,
                  ) {
                    final localParticipant = callState.localParticipant!;
                    return StreamCallControls(
                      options: [
                        // if (widget.isVideo == false)
                        FlipCameraOption(
                          call: call,
                          localParticipant: localParticipant,
                        ),
                        ToggleSpeakerphoneOption(
                          call: call,
                        ),
                        ToggleMicrophoneOption(
                          call: call,
                          localParticipant: localParticipant,
                        ),
                        // if (!widget.isVideo)
                        ToggleCameraOption(
                          call: call,
                          localParticipant: localParticipant,
                        ),
                        LeaveCallOption(
                          call: call,
                          onLeaveCallTap: () {
                            call.leave();
                            Get.back();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )
          : Scaffold(
              body: Column(
                children: [],
              ),
            ),
    );
  }
}
