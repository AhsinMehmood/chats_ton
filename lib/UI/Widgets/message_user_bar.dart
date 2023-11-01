// import 'dart:developer';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chats_ton/Global/color.dart';
// import 'package:chats_ton/Models/user_model.dart';
// import 'package:chats_ton/Providers/conversation_provider.dart';
// import 'package:chats_ton/Providers/message_provider.dart';
// import 'package:chats_ton/Providers/voice_call_provider.dart';
// import 'package:chats_ton/UI/Calling/voice_calling_page.dart';
// import 'package:chats_ton/UI/Widgets/voice_message.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/entities.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart' as stv;
// import 'package:timeago/timeago.dart' as timeAgo;
// // import 'package:provider/provider.dart';

// class MessageUserBar extends StatefulWidget {
//   final Member member;
//   const MessageUserBar({super.key, required this.member});

//   @override
//   State<MessageUserBar> createState() => _MessageUserBarState();
// }

// class _MessageUserBarState extends State<MessageUserBar> {
//   AppColor app = AppColor();
//   @override
//   Widget build(BuildContext context) {
//     final UserModel currentUserModel = Provider.of<UserModel>(context);
//     final User user = widget.member.user!;
//     final channel = StreamChannel.of(context).channel;

//     String lastActive = timeAgo.format(user.lastActive!);
//     return Container(
//       height: 100,
//       padding: const EdgeInsets.all(10),
//       width: Get.width,
//       color: app.changeColor(color: app.purpleColor),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const SizedBox(
//             height: 30,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               InkWell(
//                 onTap: () {
//                   // player.pause();
//                   Get.back();
//                 },
//                 child: SvgPicture.asset('assets/Back_icon.svg'),
//               ),
//               Row(
//                 children: [
//                   Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(200),
//                         child: CachedNetworkImage(
//                           imageUrl: widget.member.user!.image!,
//                           height: 44,
//                           width: 44,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Positioned(
//                           bottom: 4,
//                           right: 4,
//                           child: Container(
//                             height: 8,
//                             width: 8,
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(200),
//                                 color:
//                                     user.online ? Colors.green : Colors.yellow),
//                           ))
//                     ],
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.name,
//                         style: GoogleFonts.poppins(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Text(
//                         lastActive,
//                         style: GoogleFonts.poppins(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w300,
//                           color: Colors.white,
//                         ),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//               // const SizedBox(
//               //   width: 10,
//               // ),
//               Row(
//                 children: [
//                   IconButton(
//                       onPressed: () async {
//                         try {
//                           stv.Call call = stv.StreamVideo.instance
//                               .makeCall(type: 'default', id: channel.id!);

//                           await call.getOrCreate();
//                           Get.to(() => CallScreen(call: call));
//                         } catch (e) {
//                           debugPrint('Error joining or creating call: $e');
//                           debugPrint(e.toString());
//                         }
//                       },
//                       icon: SvgPicture.asset('assets/Video_icon.svg')),
//                   IconButton(
//                       onPressed: () async {
//                         // VoiceCallProvider().initiateCall(
//                         //     'Voice Call', currentUserModel, userModel);
//                         // MessageProvider().sendCallMessage(
//                         //     currentUserModel,
//                         //     userModel,
//                         //     'Voice Call',
//                         //     widget.chatId,
//                         //     'voice_call',
//                         //     'Voice Call');
//                       },
//                       icon: SvgPicture.asset('assets/call_icon.svg')),
//                 ],
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
