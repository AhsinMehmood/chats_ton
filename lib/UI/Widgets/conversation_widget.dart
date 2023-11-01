import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/conversation_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/conversation_provider.dart';
import 'package:chats_ton/Providers/message_provider.dart';
import 'package:chats_ton/UI/Widgets/video_control_panel.dart';
import 'package:chats_ton/UI/Widgets/voice_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'call_message_widget.dart';
import 'full_image_widget.dart';

ScrollController scrollController = ScrollController();
bool playerPlaying = false;

class ConversationWidget extends StatefulWidget {
  // final UserModel secondUserModel;
  final String chatid;
  const ConversationWidget({super.key, required this.chatid});

  @override
  State<ConversationWidget> createState() => _ConversationWidgetState();
}

class _ConversationWidgetState extends State<ConversationWidget> {
  // final String currentUserId = 'user1';
  // final String secondUserId = 'user2';
  int limitdocuments = 30;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // prepare();
  }

  prepare() async {
    Provider.of<MessageProvider>(context, listen: false)
        .initializeStream(widget.chatid);
  }

  @override
  Widget build(BuildContext context) {
    final ConversationProvider conversationProvider =
        Provider.of<ConversationProvider>(context);
    final UserModel userModel = Provider.of<UserModel>(context);
    // final MessageProvider messageProvider =
    //     Provider.of<MessageProvider>(context);
    AppColor app = AppColor();
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollController.position.extentAfter == 0) {
          print('end');
          setState(() {
            limitdocuments = limitdocuments + 20;
          });
          // User has reached the end of the page
          // Place your code to handle this event here
        }
        return false; // Return true if you want to absorb the notification
      },
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatid)
              .collection('conversation')
              .orderBy('timestamp', descending: true)
              .limit(limitdocuments)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            List<ConversationModel> conversations = [];
            if (!snapshot.hasData) {
              return const Text('no');
            }
            for (int i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot doc = snapshot.data!.docs.elementAt(i);

              // Check manually if the data you're referring to is coming from the cache.
              print(doc.metadata.isFromCache ? "Cached" : "Not Cached");
            }
            for (var i = 0; i < snapshot.data!.docs.length; i++) {
              conversations.add(ConversationModel.fromJson(
                  snapshot.data!.docs[i].data(), snapshot.data!.docs[i].id));
            }
            final groupedConversations =
                conversationProvider.groupConversationByDate(conversations);
            return ListView.builder(
              itemCount: groupedConversations.keys.length,
              reverse: true,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              controller: scrollController,
              itemBuilder: (context, index) {
                final date = groupedConversations.keys.elementAt(index);
                final messages = groupedConversations[date];
                messages!.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: app.changeColor(color: 'F8FBFA'),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: messages.reversed.length,
                        itemBuilder: (context, messageIndex) {
                          final List<ConversationModel> message =
                              messages.reversed.toList();
                          if (message[messageIndex].senderId ==
                              userModel.userId) {
                            return message[messageIndex].messageType ==
                                    'voice_call'
                                ? CallMessageWidget(
                                    message: message[messageIndex],
                                  )
                                : senderMessageWidget(message, messageIndex);
                          } else {
                            return message[messageIndex].messageType ==
                                    'voice_call'
                                ? CallMessageWidget(
                                    message: message[messageIndex],
                                  )
                                : receiverMessageWidget(message, messageIndex);
                          }
                          // return ListTile(
                          //   title: Text(message.text),
                          //   // Render other message details here.
                          // );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }

  Widget senderMessageWidget(List<ConversationModel> message, int index) {
    AppColor app = AppColor();
    DateTime now = DateTime.parse(message[index].timestamp);
    String formattedTime = DateFormat.jm().format(now);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Card(
              color: app.changeColor(color: app.purpleColor),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: message[index].messageType == 'text'
                    ? textMessageType(message[index])
                    : message[index].messageType == 'image'
                        ? imageMessageType(message[index])
                        : message[index].messageType == 'audio'
                            ? audioMessageType(message, index)
                            : message[index].messageType == 'video'
                                ? ConversationVideoPlayer(
                                    message: message[index])
                                : message[index].messageType == 'document'
                                    ? documentMessageType(message[index])
                                    : textMessageType(message[index]),
              ),
            ),
            Text(
              formattedTime,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: app.changeColor(
                    color: '797C7B',
                  )),
            )
          ],
        ),
      ],
    );
  }

  Widget audioMessageType(List<ConversationModel> message, int index) {
    // print(message.imageUrl);
    AppColor app = AppColor();
    final UserModel userModel = Provider.of<UserModel>(context);
    // PlayerController playerController = PlayerController();
    // ConversationProvider().addController(playerController);
    return Row(
      children: [
        // VoiceMessage(
        //   audioSrc: message[index].documentUrl,
        //   // index: index,
        //   playerController: message[index].audioPlaying,
        //   messageList: message,
        //   contactBgColor: Colors.transparent,
        //   meBgColor: app.changeColor(color: app.purpleColor),
        //   played: false, // To show played badge or not.
        //   me: message[index].senderId == userModel.userId, // Set message side.
        //   onPlay: () {}, // Do something when voice played.
        // )
      ],
    );
  }

  Widget documentMessageType(ConversationModel message) {
    print(message.imageUrl);
    return Row(
      children: [
        Text(
          'document message',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget imageMessageType(ConversationModel message) {
    print(message.imageUrl);
    final UserModel userModel = Provider.of<UserModel>(context);

    return message.imageUrl.isEmpty
        ? Container(
            height: 245,
            width: 245,
            child: Center(
              child: CircularProgressIndicator(
                color: message.senderId == userModel.userId
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          )
        : Container(
            height: 245,
            width: 245,
            child: InkWell(
              onTap: () {
                // if(){}

                Get.to(
                    () => FullImageWidget(
                          imageUrl: message.imageUrl,
                        ),
                    fullscreenDialog: true);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FastCachedImage(
                  url: message.imageUrl,
                  fit: BoxFit.cover,
                  height: 245,
                  width: 245,
                  fadeInDuration: const Duration(milliseconds: 200),
                  errorBuilder: (context, exception, stacktrace) {
                    return Text(stacktrace.toString());
                  },
                  loadingBuilder: (context, progress) {
                    return Center(
                      child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                              color: message.senderId == userModel.userId
                                  ? Colors.white
                                  : Colors.black,
                              strokeWidth: 2,
                              value: progress.progressPercentage.value)),
                    );
                  },
                ),
              ),
            ),
          );
  }

  Widget textMessageType(ConversationModel message) {
    final UserModel userModel = Provider.of<UserModel>(context);

    return Row(
      children: [
        Text(
          message.text,
          style: GoogleFonts.poppins(
            color: message.senderId == userModel.userId
                ? Colors.white
                : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget receiverMessageWidget(List<ConversationModel> message, int index) {
    AppColor app = AppColor();
    DateTime now = DateTime.parse(message[index].timestamp);
    String formattedTime = DateFormat.jm().format(now);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: app.changeColor(color: 'F2F7FB'),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: message[index].messageType == 'text'
                    ? textMessageType(message[index])
                    : message[index].messageType == 'image'
                        ? imageMessageType(message[index])
                        : message[index].messageType == 'audio'
                            ? audioMessageType(message, index)
                            : message[index].messageType == 'video'
                                ? ConversationVideoPlayer(
                                    message: message[index])
                                : message[index].messageType == 'document'
                                    ? documentMessageType(message[index])
                                    : textMessageType(message[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 40,
              ),
              child: Text(
                formattedTime,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: app.changeColor(
                      color: '797C7B',
                    )),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class ConversationVideoPlayer extends StatefulWidget {
  const ConversationVideoPlayer({
    super.key,
    required this.message,
  });

  final ConversationModel message;

  @override
  State<ConversationVideoPlayer> createState() =>
      _ConversationVideoPlayerState();
}

class _ConversationVideoPlayerState extends State<ConversationVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    print(widget.message.videoUrl);
    return Column(
      children: [
        Container(
            height: 250,
            width: 250,
            // aspectRatio: _controller.value.aspectRatio,
            child: InkWell(
              onTap: () {
                // if (isPlaying) {
                //   player.pause();
                //   setState(() {
                //     isPlaying = false;
                //   });
                // }

                if (widget.message.videoUrl.isEmpty) {
                } else {
                  Get.to(
                      () => VideoControlPanel(
                            message: widget.message,
                          ),
                      fullscreenDialog: true);
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.message.imageUrl == ''
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.message.imageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                      top: 5,
                      // right: 0,
                      left: 1,
                      child: SvgPicture.asset('assets/Video_icon.svg')),
                  Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(4),
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(120),
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.play_arrow)),
                        ],
                      )),
                ],
              ),
            ))
      ],
    );
  }
}
