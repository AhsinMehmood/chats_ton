// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class FullScreenVideoPlayer extends StatefulWidget {
//   final VideoPlayerController controller;

//   const FullScreenVideoPlayer({super.key, required this.controller});

//   @override
//   // ignore: library_private_types_in_public_api
//   _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
// }

// class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.play();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: widget.controller.value.aspectRatio,
//           child: VideoPlayer(widget.controller),
//         ),
//       ),
//     );
//   }
// }
