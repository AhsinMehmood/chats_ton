// import 'dart:async';
// import 'dart:math';
// import 'package:rxdart/rxdart.dart' as rx;

// // import 'package:audioplayers/audioplayers.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:chats_ton/Global/color.dart';
// import 'package:chats_ton/Models/conversation_model.dart';

// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:just_audio/just_audio.dart';
// // ignore: library_prefixes
// // import 'package:just_audio/just_audio.dart';
// // ignore: library_prefixes
// // import 'package:just_audio/just_audio.dart' as jsAudio;

// import 'conversation_widget.dart';

// /// This is the main widget.
// // ignore: must_be_immutable
// class VoiceMessage extends StatefulWidget {
//   VoiceMessage({
//     Key? key,
//     required this.me,
//     this.audioSrc,
//     required this.playerController,
//     this.meBgColor = AppColors.pink,
//     this.contactBgColor = const Color(0xffffffff),
//     this.contactFgColor = AppColors.pink,
//     this.contactCircleColor = Colors.red,
//     this.mePlayIconColor = Colors.black,
//     this.contactPlayIconColor = Colors.black26,
//     this.radius = 12,
//     this.contactPlayIconBgColor = Colors.grey,
//     this.meFgColor = const Color(0xffffffff),
//     this.played = false,
//     required this.messageList,
//     this.onPlay,
//   }) : super(key: key);

//   final String? audioSrc;
//   final AudioPlayer playerController;
//   final double radius;

//   final List<ConversationModel> messageList;
//   final Color meBgColor,
//       meFgColor,
//       contactBgColor,
//       contactFgColor,
//       contactCircleColor,
//       mePlayIconColor,
//       contactPlayIconColor,
//       contactPlayIconBgColor;
//   final bool played, me;
//   Function()? onPlay;
//   String Function(Duration duration)? formatDuration;

//   @override
//   // ignore: library_private_types_in_public_api
//   _VoiceMessageState createState() => _VoiceMessageState();
// }

// class _VoiceMessageState extends State<VoiceMessage> {
//   // AudioPlayer player = AudioPlayer();
//   // PlayerController controller = PlayerController();
//   int duration = 0;

//   @override
//   void initState() {
//     super.initState();
//     // ambiguate(WidgetsBinding.instance)!.addObserver(this);
//     preparePlayer();
//   } // Initialise

//   preparePlayer() async {
//     // Listen to errors during playback.
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());
//     // File file = await DefaultCacheManager().getSingleFile(widget.audioSrc!);
//     final audioSource = LockCachingAudioSource(Uri.parse(widget.audioSrc!));

//     await widget.playerController.setAudioSource(audioSource);
//     // await widget.playerController
//     //     .preparePlayer(
//     //         path: file.path,
//     //         shouldExtractWaveform: true,
//     //         noOfSamples: 100,
//     //         volume: 1.0)
//     //     .then((value) async {
//     //   widget.playerController.onCurrentDurationChanged.listen((event) {

//     //     widget.playerController.stopAllPlayers();
//     //     widget.playerController.onCompletion.listen((event) {
//     //       widget.playerController.seekTo(0);
//     //       print('Player Completed');
//     //       setState(() {
//     //         duration = 0;
//     //         playing = false;
//     //         playerPlaying = false;
//     //       });
//     //     });
//     //   });

//     // });
//   }

//   Stream<PositionData> get _positionDataStream =>
//       rx.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           widget.playerController.positionStream,
//           widget.playerController.bufferedPositionStream,
//           widget.playerController.durationStream,
//           (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));
//   String formatMilliseconds(int milliseconds) {
//     final int seconds = milliseconds;
//     final int minutes = (seconds / 60).truncate();
//     final int remainingSeconds = seconds % 60;

//     String twoDigits(int n) {
//       if (n >= 10) {
//         return '$n';
//       } else {
//         return '0$n';
//       }
//     }

//     return '${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';
//   }

//   @override
//   void dispose() {
//     widget.playerController.dispose();
//     // ambiguate(WidgetsBinding.instance)!.removeObserver(this);

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => _sizerChild(context);

//   Container _sizerChild(BuildContext context) => Container(
//         // padding: EdgeInsets.symmetric(horizontal: .8.w()),
//         // constraints: BoxConstraints(maxWidth: 100.w() * .8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(widget.radius),
//             bottomLeft: widget.me
//                 ? Radius.circular(widget.radius)
//                 : const Radius.circular(4),
//             bottomRight: !widget.me
//                 ? Radius.circular(widget.radius)
//                 : const Radius.circular(4),
//             topRight: Radius.circular(widget.radius),
//           ),
//           color: widget.me ? widget.meBgColor : widget.contactBgColor,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // _playButton(context),
//               StreamBuilder<PlayerState>(
//                 stream: widget.playerController.playerStateStream,
//                 builder: (context, snapshot) {
//                   final playerState = snapshot.data;
//                   final processingState = playerState?.processingState;
//                   final playing = playerState?.playing;
//                   if (processingState == ProcessingState.loading ||
//                       processingState == ProcessingState.buffering) {
//                     return Container(
//                       padding: const EdgeInsets.all(4.0),
//                       width: 28.0,
//                       height: 28.0,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(200),
//                         color: Colors.white,
//                       ),
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 1,
//                       ),
//                     );
//                   } else if (playing != true) {
//                     return Container(
//                       padding: const EdgeInsets.all(4.0),
//                       // width: 24.0,
//                       // height: 24.0,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(200),
//                         color: widget.me
//                             ? widget.meFgColor
//                             : AppColor()
//                                 .changeColor(color: AppColor().purpleColor),
//                       ),
//                       child: InkWell(
//                         onTap: () async {
//                           setState(() {
//                             loading = true;
//                           });

//                           widget.playerController.pause();
//                           widget.playerController.play();
//                         },
//                         child: Icon(
//                           Icons.play_arrow,
//                           size: 24.0,
//                           color: widget.me ? Colors.black : Colors.white,
//                         ),
//                       ),
//                     );
//                   } else if (processingState != ProcessingState.completed) {
//                     return Container(
//                       padding: const EdgeInsets.all(4.0),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(200),
//                         color: widget.me
//                             ? widget.meFgColor
//                             : AppColor()
//                                 .changeColor(color: AppColor().purpleColor),
//                       ),
//                       child: InkWell(
//                         onTap: widget.playerController.pause,
//                         child: Icon(
//                           Icons.pause,
//                           size: 24.0,
//                           color: widget.me ? Colors.black : Colors.white,
//                         ),
//                       ),
//                     );
//                   } else {
//                     return Container(
//                       padding: const EdgeInsets.all(4.0),
//                       // width: 24.0,
//                       // height: 24.0,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(200),
//                         color: widget.me
//                             ? widget.meFgColor
//                             : AppColor()
//                                 .changeColor(color: AppColor().purpleColor),
//                       ),
//                       child: InkWell(
//                         onTap: () {
//                           widget.playerController.seek(Duration.zero);
//                         },
//                         child: Icon(
//                           Icons.replay,
//                           size: 24.0,
//                           color: widget.me ? Colors.black : Colors.white,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//               const SizedBox(width: 10),
//               // AudioFileWaveforms(
//               //   // enableGesture: true,
//               //   size: Size(Get.width * 0.35, 35),
//               //   // enableSeekGesture: false,
//               //   playerController: widget.playerController,
//               //   // playerWaveStyle: ,
//               //   playerWaveStyle: const PlayerWaveStyle(
//               //     fixedWaveColor: Colors.white54,
//               //     liveWaveColor: Colors.white,
//               //     spacing: 8,
//               //   ),
//               //   decoration: BoxDecoration(
//               //     borderRadius: BorderRadius.circular(12.0),
//               //     color: Colors.transparent,
//               //   ),
//               //   padding: const EdgeInsets.only(left: 5),
//               //   margin: const EdgeInsets.symmetric(horizontal: 15),
//               // ),
//               StreamBuilder<PositionData>(
//                 stream: _positionDataStream,
//                 builder: (context, snapshot) {
//                   final positionData = snapshot.data;
//                   return SeekBar(
//                     duration: positionData?.duration ?? Duration.zero,
//                     position: positionData?.position ?? Duration.zero,
//                     me: widget.me,
//                     bufferedPosition:
//                         positionData?.bufferedPosition ?? Duration.zero,
//                     onChangeEnd: widget.playerController.seek,
//                   );
//                 },
//               ),
//               StreamBuilder<double>(
//                 stream: widget.playerController.speedStream,
//                 builder: (context, snapshot) => IconButton(
//                   icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
//                       style: GoogleFonts.poppins(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: widget.me ? Colors.white : Colors.black,
//                       )),
//                   onPressed: () {
//                     showSliderDialog(
//                       context: context,
//                       title: "Adjust speed",
//                       divisions: 10,
//                       min: 0.5,
//                       max: 2.0,
//                       value: widget.playerController.speed,
//                       stream: widget.playerController.speedStream,
//                       onChanged: widget.playerController.setSpeed,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//   bool loading = false;
//   bool playing = false;
// }

// class SeekBar extends StatefulWidget {
//   final Duration duration;
//   final Duration position;
//   final Duration bufferedPosition;
//   final ValueChanged<Duration>? onChanged;
//   final ValueChanged<Duration>? onChangeEnd;
//   final bool me;

//   const SeekBar({
//     Key? key,
//     required this.duration,
//     required this.me,
//     required this.position,
//     required this.bufferedPosition,
//     this.onChanged,
//     this.onChangeEnd,
//   }) : super(key: key);

//   @override
//   SeekBarState createState() => SeekBarState();
// }

// class SeekBarState extends State<SeekBar> {
//   double? _dragValue;
//   late SliderThemeData _sliderThemeData;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     _sliderThemeData = SliderTheme.of(context).copyWith(
//       trackHeight: 2.0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             thumbShape: HiddenThumbComponentShape(),
//             activeTrackColor: Colors.white,
//             inactiveTrackColor: Colors.grey.shade300,
//           ),
//           child: ExcludeSemantics(
//             child: Slider(
//               min: 0.0,
//               thumbColor: Colors.white,
//               max: widget.duration.inMilliseconds.toDouble(),
//               value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
//                   widget.duration.inMilliseconds.toDouble()),
//               onChanged: (value) {
//                 setState(() {
//                   _dragValue = value;
//                 });
//                 if (widget.onChanged != null) {
//                   widget.onChanged!(Duration(milliseconds: value.round()));
//                 }
//               },
//               onChangeEnd: (value) {
//                 if (widget.onChangeEnd != null) {
//                   widget.onChangeEnd!(Duration(milliseconds: value.round()));
//                 }
//                 _dragValue = null;
//               },
//             ),
//           ),
//         ),
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             inactiveTrackColor: Colors.transparent,
//           ),
//           child: Slider(
//             min: 0.0,
//             max: widget.duration.inMilliseconds.toDouble(),
//             value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
//                 widget.duration.inMilliseconds.toDouble()),
//             onChanged: (value) {
//               setState(() {
//                 _dragValue = value;
//               });
//               if (widget.onChanged != null) {
//                 widget.onChanged!(Duration(milliseconds: value.round()));
//               }
//             },
//             onChangeEnd: (value) {
//               if (widget.onChangeEnd != null) {
//                 widget.onChangeEnd!(Duration(milliseconds: value.round()));
//               }
//               _dragValue = null;
//             },
//           ),
//         ),
//         Positioned(
//           right: 16.0,
//           bottom: 0.0,
//           child: Text(
//             RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
//                     .firstMatch("$_remaining")
//                     ?.group(1) ??
//                 '$_remaining',
//             style: GoogleFonts.poppins(
//               color: widget.me ? Colors.white : Colors.black,
//               fontSize: 12,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Duration get _remaining => widget.duration - widget.position;
// }

// class HiddenThumbComponentShape extends SliderComponentShape {
//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     required Animation<double> activationAnimation,
//     required Animation<double> enableAnimation,
//     required bool isDiscrete,
//     required TextPainter labelPainter,
//     required RenderBox parentBox,
//     required SliderThemeData sliderTheme,
//     required TextDirection textDirection,
//     required double value,
//     required double textScaleFactor,
//     required Size sizeWithOverflow,
//   }) {}
// }

// class PositionData {
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;

//   PositionData(this.position, this.bufferedPosition, this.duration);
// }

// void showSliderDialog({
//   required BuildContext context,
//   required String title,
//   required int divisions,
//   required double min,
//   required double max,
//   String valueSuffix = '',
//   // TODO: Replace these two by ValueStream.
//   required double value,
//   required Stream<double> stream,
//   required ValueChanged<double> onChanged,
// }) {
//   showDialog<void>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text(title, textAlign: TextAlign.center),
//       content: StreamBuilder<double>(
//         stream: stream,
//         builder: (context, snapshot) => SizedBox(
//           height: 100.0,
//           child: Column(
//             children: [
//               Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
//                   style: const TextStyle(
//                       fontFamily: 'Fixed',
//                       fontWeight: FontWeight.bold,
//                       fontSize: 24.0)),
//               Slider(
//                 divisions: divisions,
//                 min: min,
//                 max: max,
//                 value: snapshot.data ?? value,
//                 onChanged: onChanged,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// T? ambiguate<T>(T? value) => value;
