import 'package:flutter/material.dart'
    show AppBar, BuildContext, Key, Scaffold, State, StatefulWidget, Widget
    show AppBar, BuildContext, Key, Scaffold, State, StatefulWidget, Widget;
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoCallPage extends StatefulWidget {
  final Call call;
  final bool isVideo;

  const VideoCallPage({
    Key? key,
    required this.call,
    required this.isVideo,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamCallContainer(
        call: widget.call,
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
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
