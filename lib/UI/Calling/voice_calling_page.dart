import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/voice_call_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class CallScreen extends StatefulWidget {
  final bool isVideo;
  final String channelId;
  final List<Member> members;
  const CallScreen({
    Key? key,
    required this.isVideo,
    required this.members,
    required this.channelId,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
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
    call = StreamVideo.instance.makeCall(type: 'video', id: widget.channelId);
    await call.getOrCreate(participantIds: [userModel.userId]).then((value) {
      setState(() {
        callInitialized = true;
      });
    });
    List<Member> withoutCurrentUserMamaber = widget.members
        .where((element) => element.userId != userModel.userId)
        .toList();
    // await Future.delayed(Duration(seconds: 3));
    for (Member element in withoutCurrentUserMamaber) {
      await VoiceCallProvider().sendCallNotification(
          element.user!.extraData['pushToken'].toString(),
          // userModel.pushToken,
          userModel,
          widget.channelId,
          'audio');
    }
  }

  @override
  Widget build(BuildContext context) {
    // widget.call.joinLobby();
    return Scaffold(
      body: callInitialized
          ? StreamCallContainer(
              call: call,
              // outgoingCallBuilder: (context, call, callState) {
              //   return Scaffold(
              //     appBar: AppBar(),
              //   );
              // },
              callConnectOptions: CallConnectOptions(
                // camera: TrackOption.enabled(),
                microphone: TrackOption.enabled(),
              ),
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
                        // FlipCameraOption(
                        //   call: call,
                        //   localParticipant: localParticipant,
                        // ),
                        ToggleSpeakerphoneOption(
                          call: call,
                        ),
                        ToggleMicrophoneOption(
                          call: call,
                          localParticipant: localParticipant,
                        ),
                        // if (!widget.isVideo)
                        //   ToggleCameraOption(
                        //     call: call,
                        //     localParticipant: localParticipant,
                        //   ),
                        LeaveCallOption(
                          call: call,
                        ),
                      ],
                    );
                  },
                );
              },
            )
          : Scaffold(),
    );
  }
}
