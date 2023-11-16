import 'package:chats_ton/Models/conversation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class VideoControlPanel extends StatefulWidget {
  final ConversationModel message;

  const VideoControlPanel({
    super.key,
    required this.message,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VideoControlPanelState createState() => _VideoControlPanelState();
}

class _VideoControlPanelState extends State<VideoControlPanel> {
  double _volume = 1.0;
  late VideoPlayerController _controller;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    initMethod();
  }

  //FlickManager? flickManager;

  initMethod() async {
    print(widget.message.videoUrl);
    final CacheManager cacheManager = CacheManager(
        Config(widget.message.videoUrl, fileService: HttpFileService()));

    final videoFile = await cacheManager.getSingleFile(widget.message.videoUrl);
    // flickManager = FlickManager(
    //   videoPlayerController: VideoPlayerController.file(videoFile),
    // );
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
}
